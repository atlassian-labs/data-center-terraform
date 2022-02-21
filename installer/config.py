import hcl2
import logging

log = logging.getLogger(__name__)


class Config:
    def __init__(self, config: str):
        self.config = self.read_config(config)

    # TODO is it static?
    def read_config(self, config):
        try:
            with open(config, "r") as file:
                log.info("Opening config: %s", config)
                config = hcl2.load(file)
                return config
        except Exception as e:
            log.error("Terraform configuration file '%s' not found!", config)
            log.error(e)
            exit()


    def get_products(self):
        return self.config["products"]
