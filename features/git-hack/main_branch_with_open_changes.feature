Feature: git-hack on the main branch with open changes

  Background:
    Given the following commit exists in my repository
      | BRANCH | LOCATION | MESSAGE     | FILE NAME |
      | main   | remote   | main_commit | main_file |
    And I am on the "main" branch
    And I have an uncommitted file with name: "uncommitted" and content: "stuff"
    When I run `git hack new_feature`


  Scenario: result
    Then it runs the Git commands
      | BRANCH      | COMMAND                          |
      | main        | git fetch --prune                |
      | main        | git stash -u                     |
      | main        | git rebase origin/main           |
      | main        | git checkout -b new_feature main |
      | new_feature | git stash pop                    |
    And I end up on the "new_feature" branch
    And I still have an uncommitted file with name: "uncommitted" and content: "stuff"
    And the branch "new_feature" has not been pushed to the repository
    And I have the following commits
      | BRANCH      | LOCATION         | MESSAGE     | FILES     |
      | main        | local and remote | main_commit | main_file |
      | new_feature | local            | main_commit | main_file |
    And now I have the following committed files
      | BRANCH      | FILES     |
      | main        | main_file |
      | new_feature | main_file |
