# PR Summary Action

This GitHub Action generates PR summaries, labels, and comments for pull requests.

## Features
- Counts transitive dependencies
- Detects declaration differences
- Generates import graph reports
- Calculates the output of a custom script
- Updates the pull request with a comment and/or labels

## Usage

Create a workflow in your repository (e.g., `.github/workflows/pr_summary.yml`):

### Available options
```yaml
- uses: adomani/PR_summary/@dev
  with:
    GITHUB_TOKEN: # optional, defaults to `github.token`
    MAIN_BRANCH: # optional, defaults to the base branch of the PR
    ROOT_DIR: # optional, defaults to the dir that is the repo name, with first letter capitalized
    IMPORT_DIFF: # optional, whether or not the import diff should be reported, defaults to true
    DECLARATION_DIFF: # optional, whether or not the declarations diff should be reported, defaults to true
    REMOVED_FILE_SUMMARY: # optional, whether or not the removed files should be reported, defaults to true
    CUSTOM_REPORT_SCRIPT: # optional, the path of a script in the base branch, whose output is appended to the report, defaults to ''
    CUSTOM_REPORT_SCRIPT_ARGUMENTS: # optional, the arguments to be passed to the script in `CUSTOM_REPORT_SCRIPT`, defaults to ''
```

### Sample action

```yaml
name: PR Summary
on:
  pull_request_target:

# Limit permissions for GITHUB_TOKEN for the entire workflow
permissions:
  contents: read
  pull-requests: write  # Only allow PR comments/labels
  # All other permissions are implicitly 'none'

jobs:
  pr-summary:
    runs-on: ubuntu-latest
    steps:
      - uses: adomani/PR_summary/@dev
        with:
          MAIN_BRANCH: master
          # We want to omit the reporting of removed files.
          REMOVED_FILE_SUMMARY: false
          # A local script whose output we want to add to the PR summary
          CUSTOM_REPORT_SCRIPT: ".src/technical-debt-metrics.sh"
          # The two inputs to the local script
          CUSTOM_REPORT_SCRIPT_ARGUMENTS: "${{ github.repository }} ${{ github.event.pull_request.number }}"
```

---

## Labels

The action assumes that the following labels exist:
* `merge-conflict`;
* `file-removed`;
* `large-import`.

---

## **Repository Structure**

```
pr-summary-action/
│
├── action.yml
├── README.md
├── scripts/
│ ├── count-trans-deps.py
│ ├── declarations_diff.sh
│ ├── import-graph-report.py
│ ├── import_trans_difference.sh
│ └── update_PR_comment.sh
```
