Feature: git-town sync --all: handling merge conflicts between feature branch and its tracking branch

  Background:
    Given my repository has the feature branches "feature-1" and "feature-2"
    And the following commits exist in my repository
      | BRANCH    | LOCATION      | MESSAGE                 | FILE NAME        | FILE CONTENT             |
      | main      | remote        | main commit             | main_file        | main content             |
      | feature-1 | local         | feature-1 local commit  | conflicting_file | feature-1 local content  |
      |           | remote        | feature-1 remote commit | conflicting_file | feature-1 remote content |
      | feature-2 | local, remote | feature-2 commit        | feature2_file    | feature-2 content        |
    And I am on the "main" branch
    And my workspace has an uncommitted file
    When I run "git-town sync --all"


  Scenario: result
    Then it runs the commands
      | BRANCH    | COMMAND                              |
      | main      | git fetch --prune --tags             |
      |           | git add -A                           |
      |           | git stash                            |
      |           | git rebase origin/main               |
      |           | git checkout feature-1               |
      | feature-1 | git merge --no-edit origin/feature-1 |
    And it prints the error:
      """
      To abort, run "git-town abort".
      To continue after having resolved conflicts, run "git-town continue".
      To continue by skipping the current branch, run "git-town skip".
      """
    And I end up on the "feature-1" branch
    And my uncommitted file is stashed
    And my repo now has a merge in progress


  Scenario: aborting
    When I run "git-town abort"
    Then it runs the commands
      | BRANCH    | COMMAND           |
      | feature-1 | git merge --abort |
      |           | git checkout main |
      | main      | git stash pop     |
    And I end up on the "main" branch
    And my workspace has the uncommitted file again
    And my repository now has the following commits
      | BRANCH    | LOCATION      | MESSAGE                 | FILE NAME        |
      | main      | local, remote | main commit             | main_file        |
      | feature-1 | local         | feature-1 local commit  | conflicting_file |
      |           | remote        | feature-1 remote commit | conflicting_file |
      | feature-2 | local, remote | feature-2 commit        | feature2_file    |


  Scenario: skipping
    When I run "git-town skip"
    Then it runs the commands
      | BRANCH    | COMMAND                              |
      | feature-1 | git merge --abort                    |
      |           | git checkout feature-2               |
      | feature-2 | git merge --no-edit origin/feature-2 |
      |           | git merge --no-edit main             |
      |           | git push                             |
      |           | git checkout main                    |
      | main      | git push --tags                      |
      |           | git stash pop                        |
    And I end up on the "main" branch
    And my workspace has the uncommitted file again
    And my repository now has the following commits
      | BRANCH    | LOCATION      | MESSAGE                            | FILE NAME        |
      | main      | local, remote | main commit                        | main_file        |
      | feature-1 | local         | feature-1 local commit             | conflicting_file |
      |           | remote        | feature-1 remote commit            | conflicting_file |
      | feature-2 | local, remote | feature-2 commit                   | feature2_file    |
      |           |               | main commit                        | main_file        |
      |           |               | Merge branch 'main' into feature-2 |                  |


  Scenario: continuing without resolving the conflicts
    When I run "git-town continue"
    Then it runs no commands
    And it prints the error:  
      """
      You must resolve the conflicts before continuing
      """
    And I am still on the "feature-1" branch
    And my uncommitted file is stashed
    And my repo still has a merge in progress


  Scenario: continuing after resolving the conflicts
    Given I resolve the conflict in "conflicting_file"
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH    | COMMAND                              |
      | feature-1 | git commit --no-edit                 |
      |           | git merge --no-edit main             |
      |           | git push                             |
      |           | git checkout feature-2               |
      | feature-2 | git merge --no-edit origin/feature-2 |
      |           | git merge --no-edit main             |
      |           | git push                             |
      |           | git checkout main                    |
      | main      | git push --tags                      |
      |           | git stash pop                        |
    And I end up on the "main" branch
    And my workspace has the uncommitted file again
    And my repository now has the following commits
      | BRANCH    | LOCATION      | MESSAGE                                                        | FILE NAME        |
      | main      | local, remote | main commit                                                    | main_file        |
      | feature-1 | local, remote | feature-1 local commit                                         | conflicting_file |
      |           |               | feature-1 remote commit                                        | conflicting_file |
      |           |               | Merge remote-tracking branch 'origin/feature-1' into feature-1 |                  |
      |           |               | main commit                                                    | main_file        |
      |           |               | Merge branch 'main' into feature-1                             |                  |
      | feature-2 | local, remote | feature-2 commit                                               | feature2_file    |
      |           |               | main commit                                                    | main_file        |
      |           |               | Merge branch 'main' into feature-2                             |                  |


  Scenario: continuing after resolving the conflicts and committing
    Given I resolve the conflict in "conflicting_file"
    And I run "git commit --no-edit"
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH    | COMMAND                              |
      | feature-1 | git merge --no-edit main             |
      |           | git push                             |
      |           | git checkout feature-2               |
      | feature-2 | git merge --no-edit origin/feature-2 |
      |           | git merge --no-edit main             |
      |           | git push                             |
      |           | git checkout main                    |
      | main      | git push --tags                      |
      |           | git stash pop                        |
    And I end up on the "main" branch
    And my workspace has the uncommitted file again
    And my repository now has the following commits
      | BRANCH    | LOCATION      | MESSAGE                                                        | FILE NAME        |
      | main      | local, remote | main commit                                                    | main_file        |
      | feature-1 | local, remote | feature-1 local commit                                         | conflicting_file |
      |           |               | feature-1 remote commit                                        | conflicting_file |
      |           |               | Merge remote-tracking branch 'origin/feature-1' into feature-1 |                  |
      |           |               | main commit                                                    | main_file        |
      |           |               | Merge branch 'main' into feature-1                             |                  |
      | feature-2 | local, remote | feature-2 commit                                               | feature2_file    |
      |           |               | main commit                                                    | main_file        |
      |           |               | Merge branch 'main' into feature-2                             |                  |
