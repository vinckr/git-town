Feature: git-extract with multiple commits and open changes

  Background:
    Given I have a feature branch named "feature"
    And the following commits exist in my repository
      | branch  | location | message            | file name        |
      | main    | remote   | remote main commit | remote_main_file |
      | feature | local    | feature commit     | feature_file     |
      | feature | local    | refactor1 commit   | refactor1_file   |
      | feature | local    | refactor2 commit   | refactor2_file   |
    And I am on the "feature" branch
    And I have an uncommitted file with name: "uncommitted" and content: "stuff"
    When I run `git extract refactor` with the last two commit shas


  Scenario: result
    Then I end up on the "refactor" branch
    And I still have an uncommitted file with name: "uncommitted" and content: "stuff"
    And I have the following commits
      | branch   | location         | message            | files            |
      | main     | local and remote | remote main commit | remote_main_file |
      | feature  | local            | feature commit     | feature_file     |
      | feature  | local            | refactor1 commit   | refactor1_file   |
      | feature  | local            | refactor2 commit   | refactor2_file   |
      | refactor | local and remote | remote main commit | remote_main_file |
      | refactor | local and remote | refactor1 commit   | refactor1_file   |
      | refactor | local and remote | refactor2 commit   | refactor2_file   |
    And now I have the following committed files
      | branch   | files                                            |
      | main     | remote_main_file                                 |
      | feature  | feature_file, refactor1_file, refactor2_file     |
      | refactor | remote_main_file, refactor1_file, refactor2_file |