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
