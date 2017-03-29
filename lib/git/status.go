package git

import (
	"fmt"
	"os"

	"github.com/Originate/git-town/lib/util"
)

func EnsureDoesNotHaveConflicts() {
	if HasConflicts() {
		util.ExitWithErrorMessage("You must resolve the conflicts before continuing")
	}
}

func GetRootDirectory() string {
	return util.GetCommandOutput("git", "rev-parse", "--show-toplevel")
}

func HasConflicts() bool {
	return util.DoesCommandOuputContain([]string{"git", "status"}, "Unmerged paths")
}

func HasOpenChanges() bool {
	return util.GetCommandOutput("git", "status", "--porcelain") != ""
}

func IsMergeInProgress() bool {
	_, err := os.Stat(fmt.Sprintf("%s/.git/MERGE_HEAD", GetRootDirectory()))
	return err == nil
}

func IsRebaseInProgress() bool {
	return util.DoesCommandOuputContain([]string{"git", "status"}, "rebase in progress")
}