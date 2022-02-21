from typer.testing import CliRunner
from ..manage import app

runner = CliRunner()


def test_installer():
    assert 1 == 1


def test_correct_config():
    result = runner.invoke(app, ["install", "--config", "installer/test/examples/config.tfvars"])
    assert result.exit_code == 0
    assert "confluence" in result.stdout

def test_incorrect_config():
    result = runner.invoke(app, ["install", "--config", "non-existing.tfvars"])
    assert result.exit_code != 0

