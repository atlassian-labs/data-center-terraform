import logging
from os import chdir
from python_terraform import Terraform


log = logging.get_logger(__name__)

def create_update_infrastructure():
    """
    Create or update the infrastructure.
    """
    log.info("Starting to analyze the infrastructure...")

    t = Terraform()
    t.apply(auto_approve=True, chdir="root")