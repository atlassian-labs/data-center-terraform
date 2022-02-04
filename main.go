package main

import (
	"fmt"
	"github.com/urfave/cli/v2"
	"log"
	"os"
)

func main() {
	app := &cli.App{
		Name:    "atldc",
		Usage:   "Deploy infrastructure and Atlassian Data Center on Kubernetes",
		Version: "0.0.1",
		Commands: []*cli.Command{
			{
				Name:    "install",
				Aliases: []string{"i"},
				Usage:   "run installation",
				Action:  install(),
			},
			{
				Name:    "uninstall",
				Aliases: []string{"u"},
				Usage:   "uninstall all resources",
				Action:  uninstall(),
			},
		},
	}

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}

func install() func(c *cli.Context) error {
	return func(c *cli.Context) error {
		fmt.Println("added task: ", c.Args().First())
		return nil
	}
}

func uninstall() func(c *cli.Context) error {
	return func(c *cli.Context) error {
		fmt.Println("completed task: ", c.Args().First())
		return nil
	}
}
