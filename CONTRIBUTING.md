# Contributing to Terraform for Bamboo DC on K8s

Thank you for considering a contribution to Terraform for Bamboo DC on K8s. Pull requests, issues and comments are welcome. For pull requests, please:

* Add tests for new features and bug fixes
* Follow the existing style
* Separate unrelated changes into multiple pull requests
* Set pre-commit git hook before raising a pull request

### Git hooks

Install pre-commit Git hook to format all terraform files before commit

    (cd .git/hooks && ln -s ../../etc/git-hooks/pre-commit)

See [development guide](https://atlassian-labs.github.io/data-center-terraform/development/HOW_TO_START/).

### Note

See the existing issues for things to start contributing.

For bigger changes, please make sure you start a discussion first by creating an issue and explaining the intended change.


### Release process

Releases are usually performed every two weeks as part of the Atlassian team
sprint cadence. Any PRs merged during the previous sprint will be automatically
releases as part of this process.

#### Steps for performing a release

1. Create a branch for the release, containing a DC Clipper ticket number.
1. Update the files `CHANGELOG.md` with the new version and a list of changes.
1. Update `INSTALLATION.md` with the new version where appropriate.
1. Raise a PR for this branch.
1. On merge, create a release in the [Github releases page](https://github.com/atlassian-labs/data-center-terraform/releases)
1. (Optional) If the release contains significant or critical changes, create a
   post on the [Developer Community forums](https://community.developer.atlassian.com/).


### Contributor agreement

Atlassian requires contributors to sign a Contributor License Agreement, known as a CLA. This serves as a record stating that the contributor is entitled to contribute the code/documentation/translation to the project and is willing to have it used in distributions and derivative works (or is willing to transfer ownership).

Prior to accepting your contributions we ask that you please follow the appropriate link below to digitally sign the CLA. The Corporate CLA is for those who are contributing as a member of an organization and the individual CLA is for those contributing as an individual.

* [CLA for corporate contributors](https://opensource.atlassian.com/corporate)
* [CLA for individuals](https://opensource.atlassian.com/individual)
