# PR Summary Action

This GitHub Action generates PR summaries, labels, and comments for pull requests.

## Features
- Counts transitive dependencies
- Detects declaration differences
- Generates import graph reports
- Calculates technical debt metrics
- Updates the pull request with a comment and/or labels

## Usage

Create a workflow in your repository (e.g., `.github/workflows/pr_summary.yml`):

```yaml
name: PR Summary
on:
  pull_request:

jobs:
  pr-summary:
    runs-on: ubuntu-latest
    steps:
      - uses: adomani/pr-summary-action@v1
        with:
          GITHUB_TOKEN: # optional, defaults to `github.token`
          MAIN_BRANCH: # optional, defaults to the base branch of the PR
          ROOT_DIR: # optional, defaults to the dir that is the repo name, with first letter capitalized
          IMPORT_DIFF: # optional, whether or not the import diff should be reported, defaults to true
          DECLARATION_SUMMARY: # optional, whether or not the declarations diff should be reported, defaults to true
          TECH_DEBT_SUMMARY: # optional, whether or not the tech debt summary should be reported, defaults to true
          REMOVED_FILE_SUMMARY: # optional, whether or not the removed files should be reported, defaults to true
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
│ ├── technical-debt-metrics.sh
│ └── update_PR_comment.sh
```
