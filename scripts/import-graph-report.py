#! /usr/bin/env python3

# This script compares the counts of dependencies between two JSON files.
# It takes three file paths (`base_file`, `head_file`, `changed_files`)
# as command line arguments, and a string (`separator`).
# It loads the counts from `base_file` and `head_file`, compares the counts,
# for each file appearing in `changed_files`.
# It identifies dependencies that have either decreased or increased,
# and generates a message with a summary of the changes.
# The message is printed to the console.
# The final string variable input (`separator`) is what gets printed instead
# of a backtick, since passing backticks into github variables makes it
# virtually impossible to escape them.
# The `separator` string gets later replaced by a backtick, when composing the final message.


import json
import sys

high_import_threshold = 2

def compare_counts(base_file, head_file, changed_files, separator):
    # Load the counts
    with open(head_file, 'r') as f:
        head_counts = json.load(f)
    with open(base_file, 'r') as f:
        base_counts = json.load(f)

    # Load the changed files
    with open(changed_files, 'r') as f:
        changed_files = [line.strip() for line in f]

    # Filter for .lean files, replace / with . in the path, and drop the .lean extension
    changed_files = [file.replace('/', '.').replace('.lean', '') for file in changed_files if file.endswith('.lean')]

    # Compute the number of new files
    new_files = len(set(head_counts.keys()) - set(base_counts.keys()))

    # Compare the counts
    changes = []
    high_pct = []
    for file in changed_files:
        base_count = base_counts.get(file, 0)
        head_count = head_counts.get(file, 0)
        if base_count == 0: # New file
            continue
        diff = head_count - base_count
        percent = (diff / base_count) * 100
        if high_import_threshold < percent:
            high_pct.append(f'| +{percent:.2f}% | {separator}{file}{separator} |')
        if diff < 0:  # Dependencies went down
            changes.append((file, base_count, head_count, diff, percent))
        elif diff > new_files:  # Dependencies went up by more than the number of new files
            changes.append((file, base_count, head_count, diff, percent))

    # Sort the changes by the absolute value of the percentage change
    changes.sort(key=lambda x: abs(x[4]), reverse=True)

    # Build the messages
    messages = []
    for file, base_count, head_count, diff, percent in changes:
        sign = "+" if diff > 0 else ""
        messages.append(f'| {separator}{file}{separator} | {base_count} | {head_count} | {sign}{diff} ({sign}{percent:.2f}%) |')

    # Build the message
    message = ''
    if messages:
        message += 'Dependency changes\n\n'
        message += '| File | Base Count | Head Count | Change |\n'
        message += '| --- | --- | --- | --- |\n'
        message += '\n'.join(messages)
    else:
        message += 'No significant changes to the import graph'

    high_pct_report = ''
    if high_pct:
        high_pct_report += f'Import changes exceeding {high_import_threshold}%\n\n'
        high_pct_report += '| %      | File |\n'
        high_pct_report += '| -      | -    |\n'
        high_pct_report += '\n'.join(high_pct)
    return (message, high_pct_report)

if __name__ == '__main__':
    base_file = sys.argv[1]
    head_file = sys.argv[2]
    changed_files = sys.argv[3]
    separator = sys.argv[4]
    (message, high_pct) = compare_counts(base_file, head_file, changed_files, separator)
    print(message)
    print(high_pct)
