package steps

import (
  "github.com/Originate/gt/lib/script"
)


type StashOpenChangesStep struct {}


func (step StashOpenChangesStep) CreateAbortStep() Step {
  return NoOpStep{}
}


func (step StashOpenChangesStep) CreateContinueStep() Step {
  return NoOpStep{}
}


func (step StashOpenChangesStep) CreateUndoStep() Step {
  return RestoreOpenChangesStep{}
}


func (step StashOpenChangesStep) Run() error {
  err := script.RunCommand("git", "add", "-A")
  if err != nil {
    return err
  }
  return script.RunCommand("git", "stash")
}
