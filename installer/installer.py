from typing import Optional
from python_terraform import *
from .config import Config

import typer

app = typer.Typer(add_completion=False)


@app.command()
def install(config: Optional[str] = "config.tfvars"):
    config = Config(config)
    print(config.get_products())


@app.command()
def uninstall(config: Optional[str] = "config.tfvars"):
    config = Config(config)
    print(config.get_products())

    # tf = Terraform(working_dir='.')
    # print("------------")
    # print(tf.output())


def configure_logging():
    FORMAT = "%(levelname)s - %(asctime)s (%(name)s) %(message)s"
    logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"), format=FORMAT)


if __name__ == "__main__":
    configure_logging()
    app()
