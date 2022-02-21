from typer.testing import CliRunner
from ..config import Config

runner = CliRunner()


def test_valid_products():
    config = Config("installer/test/examples/config.tfvars")
    assert "confluence" in config.get_products()
    assert "bamboo" not in config.get_products()

