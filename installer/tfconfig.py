import logging
import os
from pathlib import Path
import hcl2

log = logging.getLogger(__name__)


class Config:
    def __init__(self, config: dict):
        self.config = config

    @classmethod
    def read_config(cls, config_file: Path):
        try:
            with open(config_file, "r") as file:
                log.info("Opening config: %s", config_file)
                config = hcl2.load(file)
                Config.validate_config(config)
                return Config(config)
        except Exception as e:
            log.error("Terraform configuration file '%s' not found!", config_file)
            exit()

    @classmethod
    def validate_config(cls, config: dict):
        if len(config.get("environment_name", "")) > 24:
            raise Exception(
                f"The environment name '{ config['environment_name'] }' is too long. The maximum length is 24 characters."
            )

        if "bamboo" in config["products"]:
            Config.validate_bamboo_config(config)

    @classmethod
    def validate_bamboo_config(cls, config):
        if (
            config.get("bamboo_license") is None
            and os.getenv("TF_VAR_bamboo_license") is None
        ):
            raise Exception("Bamboo license is not set!")

        if (
            config["bamboo_admin_password"] is None
            and os.getenv("TF_VAR_bamboo_admin_password") is None
        ):
            raise Exception("Bamboo admin password is not set!")

    def get_products(self):
        return self.config["products"]

    def get_region(self):
        return self.config["region"]

    def get_environment_name(self):
        return self.config["environment_name"]
