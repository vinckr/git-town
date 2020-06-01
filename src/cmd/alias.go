package cmd

import (
	"github.com/git-town/git-town/src/git"
	"github.com/git-town/git-town/src/util"
	"github.com/spf13/cobra"
)

var aliasCommand = &cobra.Command{
	Use:   "alias (true | false)",
	Short: "Adds or removes default global aliases",
	Long: `Adds or removes default global aliases

Global aliases make Git Town commands feel like native Git commands.
When enabled, you can run "git hack" instead of "git town hack".

Does not overwrite existing aliases.

This can conflict with other tools that also define Git aliases.`,
	Run: func(cmd *cobra.Command, args []string) {
		repo := git.NewProdRepo()
		toggle := util.StringToBool(args[0])
		var commandsToAlias = []string{
			"append",
			"hack",
			"kill",
			"new-pull-request",
			"prepend",
			"prune-branches",
			"rename-branch",
			"repo",
			"ship",
			"sync",
		}
		for _, command := range commandsToAlias {
			if toggle {
				addAlias(command, repo)
			} else {
				removeAlias(command, repo)
			}
		}
	},
	Args: func(cmd *cobra.Command, args []string) error {
		if len(args) == 1 {
			return validateBooleanArgument(args[0])
		}
		return cobra.ExactArgs(1)(cmd, args)
	},
}

func addAlias(command string, repo *git.ProdRepo) {
	result := repo.AddGitAlias(command)
	repo.LoggingShell.PrintCommand(result.Command(), result.Args()...)
}

func removeAlias(command string, repo *git.ProdRepo) {
	existingAlias := repo.GetGitAlias(command)
	if existingAlias == "town "+command {
		result := repo.RemoveGitAlias(command)
		repo.LoggingShell.PrintCommand(result.Command(), result.Args()...)
	}
}

func init() {
	RootCmd.AddCommand(aliasCommand)
}
