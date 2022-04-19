from pathlib import Path
from typing import Optional
from constants import INSTALLER_HELP, UNINSTALLER_HELP
import typer
import terraform
from tfconfig import Config


app = typer.Typer()


@app.command(help=INSTALLER_HELP)
def install(
    config_file: Path = "config.tfvars", force: bool = typer.Option(False, hidden=True)
):
    typer.echo(f"Config file {config_file}")

    config = Config.read_config(config_file)

    terraform.create_update_infrastructure()

    typer.echo(f"Installing the products {config.get_products()}")


@app.command(help=UNINSTALLER_HELP)
def uninstall(name: Optional[str] = None):
    typer.echo(f"Uninstalling product {name}")


if __name__ == "__main__":
    app()
