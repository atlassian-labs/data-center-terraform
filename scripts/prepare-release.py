#!/usr/bin/env python3
"""
prepare-release.py - Prepare a new release for data-center-terraform.

Usage:
  python3 prepare-release.py [new_version] [options]

Options:
  --skip-rovo-changelog   Skip the changelog draft generation with Rovo
  --dry-run               Print changes without modifying files

Example:
  python3 prepare-release.py
  python3 prepare-release.py 2.9.16
  python3 prepare-release.py 2.9.16 --dry-run
"""

import argparse
import re
import subprocess
import sys
import tempfile
from datetime import date
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
CHANGELOG_FILE = REPO_ROOT / "CHANGELOG.md"
INSTALLATION_FILE = REPO_ROOT / "docs" / "docs" / "userguide" / "INSTALLATION.md"


def exit_error(message, exit_code=1):
    """
    Prints error message and raises SystemExit exception.
    Use as `raise exit_error('What went wrong')` to hint static code analyzers that invocation of this function
    will result in code execution to be interrupted.
    """
    print(f'ERROR: {message}')
    sys.exit(exit_code)


def run_git(*args: str, capture: bool = False, check: bool = True) -> subprocess.CompletedProcess:
    """Run a git command in the repo root."""
    return subprocess.run(
        ["git", *args],
        cwd=REPO_ROOT,
        capture_output=capture,
        text=capture,
        check=check,
    )


def infer_next_version(current: str) -> str:
    """Increment the patch component of a MAJOR.MINOR.PATCH version string."""
    major, minor, patch = current.split(".")
    return f"{major}.{minor}.{int(patch) + 1}"


def validate_version(version: str) -> None:
    """Validate that the version string follows the expected format (e.g. 2.9.16)."""
    if not re.match(r"^\d+\.\d+\.\d+$", version):
        raise exit_error(f"Invalid version format '{version}'. Expected format: MAJOR.MINOR.PATCH (e.g. 2.9.16)")


def get_latest_changelog_version(content: str) -> str:
    """Extract the latest version from the CHANGELOG. Exits with error if not found."""
    match = re.search(r"^## (\d+\.\d+\.\d+)", content, re.MULTILINE)
    if not match:
        raise exit_error("Could not find any version in CHANGELOG.md. Expected at least one '## X.Y.Z' header.")
    return match.group(1)


def update_changelog(content: str, new_version: str, today: str, new_changelog_items: str = "") -> str:
    """Prepend a new version section to the CHANGELOG after the title line."""
    body = new_changelog_items if new_changelog_items else "* ⚠️ TODO: populate changelog items"
    new_section = (
        f"## {new_version}\n"
        f"\n"
        f"**Release date:** {today}\n"
        f"\n"
        f"{body}\n"
        f"\n"
    )
    # Insert after the first line (# Change Log header)
    lines = content.split("\n", 1)
    if len(lines) == 2:
        return lines[0] + "\n\n" + new_section + lines[1].lstrip("\n")
    else:
        return content + "\n" + new_section


def update_installation_doc(content: str, new_version: str) -> str:
    """Update the git clone version tag in INSTALLATION.md."""
    updated = re.sub(
        r"(git clone -b )\d+\.\d+\.\d+( https://github\.com/atlassian-labs/data-center-terraform\.git)",
        rf"\g<1>{new_version}\2",
        content,
    )
    if updated == content:
        raise exit_error("Could not find git clone command with version tag in INSTALLATION.md.")

    return updated


def create_release_branch_and_commit(new_version: str, changed_files: list[str]) -> None:
    """Create a release branch and commit the changed files."""
    branch = f"release/{new_version}"

    # Create and switch to the release branch
    run_git("checkout", "-b", branch)
    print(f"  ✓ Created and switched to branch '{branch}'")

    # Stage the changed files
    run_git("add", *changed_files)

    # Commit
    commit_msg = f"Preparing release {new_version}"
    run_git("commit", "-m", commit_msg)
    print(f"  ✓ Committed changes: '{commit_msg}'")
    print(f"\n  To undo: git reset HEAD~1  (keeps changes staged)")
    print(f"  To amend: git commit --amend")


def git_tag_exists(tag: str) -> bool:
    return run_git("rev-parse", tag, capture=True, check=False).returncode == 0


def get_git_log_since(since_version: str) -> str:
    """Get git log of commits since the given version tag."""
    if not git_tag_exists(since_version):
        print(f"  Tag '{since_version}' not found locally, fetching tags...")
        run_git("fetch", "--tags")
        if not git_tag_exists(since_version):
            raise exit_error(f"Git tag '{since_version}' not found. Make sure previous releases are tagged.")

    print(f"  Using git tag '{since_version}' as cutoff.")
    result = run_git("log", f"{since_version}..HEAD", "--oneline", "--no-merges", capture=True)
    return result.stdout.strip()


def draft_changelog_with_rovo(git_log: str, new_version: str, latest_version: str) -> str:
    """
    Use Rovo to draft changelog bullet points from git commits.
    Streams Rovo output live to the terminal and writes the result to a temp file.
    Returns the drafted text, or exits with an error if acli fails.
    """
    # The temp directory must live under REPO_ROOT so that the Rovo can access it — Rovo is sandboxed to the workspace
    # and cannot reach system temp directories (e.g. /tmp).
    # The .gitignore entry for `.tmp_changelog_draft_*` ensures these are never committed.
    with tempfile.TemporaryDirectory(prefix=".tmp_changelog_draft_", dir=REPO_ROOT) as tmpdir:
        tmp_path = Path(tmpdir) / "changelog_draft.txt"
        prompt = (
            f"You are preparing a CHANGELOG entry for version {new_version} of the "
            f"data-center-terraform project (Terraform + Helm charts for Atlassian Data Center products on Kubernetes). "
            f"Based on the following git commits since version {latest_version}, "
            f"write a concise bullet-point list of user-facing changes suitable for a CHANGELOG. "
            f"Group related changes. Skip merge commits, version bumps, and purely internal/CI changes. "
            f"Format each bullet as: '* <description> [#PR](<url>)' if a PR number is visible in the commit, "
            f"otherwise just '* <description>'. "
            f"Write ONLY the bullet points (no headings or extra commentary) to the file: {tmp_path}\n"
            f"IMPORTANT: use tools dedicated for file manipulation to create output, do NOT use shell commands for this."
            f"\n"
            f"Git commits:\n{git_log}"
        )

        try:
            print('--- RUNNING ROVO DEV ---')
            result = subprocess.run(
                ["acli", "rovodev", "tui", prompt],
                cwd=REPO_ROOT,
                timeout=120,
            )
            print('------------------------')
            if result.returncode != 0:
                raise exit_error(f"acli rovodev exited with code {result.returncode}.", exit_code=1)

            if not tmp_path.exists():
                raise exit_error("Rovo did not produce a changelog draft — output file was not created.", exit_code=1)

            output = tmp_path.read_text().strip()
            if not output:
                raise exit_error("Rovo produced an empty changelog draft — output file is empty.", exit_code=1)

            return output
        except FileNotFoundError:
            raise exit_error("'acli' not found in PATH. Please install acli and try again.", exit_code=1)
        except subprocess.TimeoutExpired:
            raise exit_error("acli timed out while generating the changelog draft.", exit_code=1)


def prepare_release(
        new_version: str | None,
        dry_run: bool = False,
        skip_rovo_changelog: bool = False,
) -> None:
    changelog_content = CHANGELOG_FILE.read_text()
    latest_version = get_latest_changelog_version(changelog_content)

    if new_version:
        validate_version(new_version)
    else:
        new_version = infer_next_version(latest_version)
        print(f"No version specified — inferred next version: {new_version} (from {latest_version})")

    today = date.today().strftime("%Y-%m-%d")

    if dry_run:
        print("DRY RUN — no files will be modified.\n")

    # -------------------------------------------------------------------------
    # CHANGELOG
    # -------------------------------------------------------------------------
    changed_files = []

    if latest_version == new_version:
        raise exit_error(f"Version {new_version} already exists in CHANGELOG.md. Cannot create a duplicate release.")

    # Rovo changelog draft
    new_changelog_items = ""
    if not skip_rovo_changelog:
        print(f"\nGenerating changelog draft with Rovo...")
        git_log = get_git_log_since(latest_version)
        if git_log:
            new_changelog_items = draft_changelog_with_rovo(git_log, new_version, latest_version)
        else:
            raise exit_error("No git commits found since last version — cannot prepare CHANGELOG update!")

    updated_changelog = update_changelog(changelog_content, new_version, today, new_changelog_items)
    print(f"CHANGELOG.md: adding section for {new_version} (release date: {today})")
    print(f"  Previous latest version: {latest_version}")

    if not dry_run:
        CHANGELOG_FILE.write_text(updated_changelog)
        changed_files.append(str(CHANGELOG_FILE))
        print(f"  ✓ CHANGELOG.md updated")
    else:
        print(f"  [dry-run] would update CHANGELOG.md")

    # -------------------------------------------------------------------------
    # INSTALLATION.md
    # -------------------------------------------------------------------------
    print(f"INSTALLATION.md: updating git clone tag to {new_version}")
    installation_content = INSTALLATION_FILE.read_text()
    updated_installation = update_installation_doc(installation_content, new_version)

    if not dry_run:
        INSTALLATION_FILE.write_text(updated_installation)
        changed_files.append(str(INSTALLATION_FILE))
        print(f"  ✓ INSTALLATION.md updated")
    else:
        print(f"  [dry-run] would update INSTALLATION.md")

    # -------------------------------------------------------------------------
    # Git branch + commit
    # -------------------------------------------------------------------------
    if not dry_run and changed_files:
        print(f"\nCreating release branch and committing changes...")
        create_release_branch_and_commit(new_version, changed_files)

    # -------------------------------------------------------------------------
    # Summary
    # -------------------------------------------------------------------------
    print(f"\n{'DRY RUN complete' if dry_run else 'Release preparation complete'} for version {new_version}.")
    if not dry_run and changed_files:
        print("\nNext steps:")
        print(f"  1. Review CHANGELOG.md and edit the bullets if needed, then 'git commit --amend'.")
        print(f"  2. Push the branch: git push origin release/{new_version}")
        print(f"  3. Open a pull request and merge.")
        print(f"  4. After merge, tag the release: git tag {new_version} && git push origin {new_version}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Prepare a new release for data-center-terraform.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "new_version",
        nargs="?",
        help="New release version (e.g. 2.9.16). If omitted, patch version is auto-incremented.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would change without modifying any files",
    )
    parser.add_argument(
        "--skip-rovo-changelog",
        action="store_true",
        help="Skip the Rovo changelog draft generation",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    prepare_release(**args.__dict__)


if __name__ == "__main__":
    main()
