from tfconfig import Config
import pytest

def test_expected_products():
    config = Config.read_config("installer/test/examples/testconfig.tfvars")
    assert "confluence" in config.get_products()
    assert "jira" in config.get_products()
    

def test_environment_name_too_long():
    config = {"environment_name": "this_is_too_long_env_name"}
    with pytest.raises(Exception, match=r"The environment name .* is too long."):
        Config.validate_config(config)


def test_missing_bamboo_license():
    config = {"products": ["bamboo"]}
    with pytest.raises(Exception, match="Bamboo license is not set!"):
        Config.validate_bamboo_config(config)