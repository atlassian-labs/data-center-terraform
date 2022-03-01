package dylan

import (
	"github.com/go-git/go-git/v5"
	"os"
)

func main() {

	r, err := git.PlainClone("/tmp/foo", false, &git.CloneOptions{
		URL:      "git@github.com:atlassian-labs/data-center-terraform.git",
		Progress: os.Stdout,
	})
	if err != nil {
		println(err)
	}
	println(r)
}
