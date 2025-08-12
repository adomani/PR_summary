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
      - uses: your-username/pr-summary-action@v1
```

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
