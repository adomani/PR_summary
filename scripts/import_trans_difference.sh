#!/usr/bin/env bash

# Make this script robust against unintentional errors.
# See e.g. http://redsymbol.net/articles/unofficial-bash-strict-mode/ for explanation.
set -euo pipefail
IFS=$'\n\t'

 : <<'BASH_MODULE_DOCS'
`scripts/import_trans_difference.sh (-b mainBranch)? (-a)? (-x commit1)? (-y commit2)? (-p pathToPythonScript)? rootDir`
outputs a full diff of the change of transitive imports in all the files between
`commit1` and `commit2`, using `mainBranch` for the "reference" branch and looking at imports of
files contained in `rootDir`.

`mainBranch` defaults to `master` if not set.

If the commits are not provided, then the script uses the current commit as `commit1` and
the merge-base with `mainBranch` as `commit2`.

Internally, the script calls a companion python script: the `-p` flag can pass this explicitly.
Otherwise, the `import_trans_difference` script assumes that the python script is
the file count-trans-deps.py in the same dir as this file

Without the optional flag `a`, the script only displays the difference
if the output does not exceed 200 lines.

The output is of the form

|Files     |Import difference|
|-         |-                |
|RootDir...| -34             |
  ...
|RootDir...| 579             |

with collapsible tabs for file entries with at least 3 files.
BASH_MODULE_DOCS

mainBranch='master'
all='false'
commit1="$(git rev-parse HEAD)"
commit2=''
pythonCompanion="$(dirname $0)/count-trans-deps.py"

print_usage() {
  printf $'\nUsage: \'%s\' admits the following flags:

-a\n   if set, print all the output; the default cuts the output if it would not fit in a github comment

-b string\n   specifies the branch with respect to which the script computes the diff; the default is master

-p path\n   specifies the companion python script that counts transitive dependencies; the default is the file count-trans-deps.py in the same dir as this file

-x string\n   an optional main commit; the default is the current one

-y string\n   an optional reference commit; the default is the merge-base with mainBranch

-h\n   display this help message
' "${0}"
}

while getopts 'ab:s:x:y:h' flag; do
  case "${flag}" in
    a) all='true' ;;
    b) mainBranch="${OPTARG}" ;;
    s) pythonCompanion="${OPTARG}" ;;
    x) commit1="${OPTARG}" ;;
    y) commit2="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# `all=1` is the flag to print all import changes, without cut-off
#all=0
#if [ "${1:-}" == "all" ]
#then
#  all=1
#  shift
#fi

# Shift away the processed options
shift $((OPTIND - 1))

#mainBranch="${1:-}"
rootDir="${1:-}"

#commit1="${3:-"$(git rev-parse HEAD)"}"

commit2="${commit2:-"$(git merge-base "${mainBranch}" ${commit1})"}"

#printf 'commit1: %s\ncommit2: %s\n' "$commit1" "$commit2"

currCommit="$(git rev-parse --abbrev-ref HEAD)"
# if we are in a detached head, `currCommit` would be the unhelpful `HEAD`
# in this case, we fetch the commit hash
if [ "${currCommit}" == "HEAD" ]
then
  currCommit="$(git rev-parse HEAD)"
fi

>&2 printf $'Assuming that the companions script is \'%s\'.\n' "${pythonCompanion}"

getTransImports () {
  python3 "${pythonCompanion}" "${rootDir}" |
    # produce lines of the form `RootDir.ModelTheory.Algebra.Ring.Basic,-582`
    sed 's=\([0-9]*\)[},]=,'"${1:-}"'\1\n=g' |
    tr -d ' "{}:'
}

tmpDir="$(mktemp --directory)"

>&2 git checkout "${commit1}"
#git checkout "${mainBranch}" scripts/count-trans-deps.py
getTransImports > "${tmpDir}/transImports1.txt"
>&2 git checkout "${currCommit}"

>&2 git checkout "${commit2}"
#git checkout "${mainBranch}" scripts/count-trans-deps.py
getTransImports - > "${tmpDir}/transImports2.txt"
>&2 git checkout "${currCommit}"

printf '\n\n<details><summary>Import changes for all files</summary>\n\n%s\n\n</details>\n' "$(
  printf "|Files|Import difference|\n|-|-|\n"
  (gawk -F, -v all="${all}" -v ghLimit='261752' -v newFiles="$(
      # we pass the "A"dded files with respect to master, converting them to module names
      git diff --name-only --diff-filter=A "${mainBranch}" | tr '\n' , | sed 's=\.lean,=,=g; s=/=.=g'
    )" '
    BEGIN{
      # `arrayNewModules` maps integers to module names
      split(newFiles, arrayNewModules, ",")
      # `newModules` "just" stores the module names
      for(v in arrayNewModules) { newModules[arrayNewModules[v]]=0 }
    } { diff[$1]+=$2 } END {
    fileCount=0
    outputLength=0
    for(fil in diff) {
      if(!(diff[fil] == 0)) {
        fileCount++
        outputLength+=length(fil)+4
        nums[diff[fil]]++
        # we add "(new file)" next to the modules whose name appears in `newModules`
        # we separate entries with a line break, so that later we can sort the modules
        # with the same number of import differences easily
        reds[diff[fil]]=sprintf("%s `%s`%s\n", reds[diff[fil]], fil, (fil in newModules)? " (new file)" : "")
      }
    }
    if ((all == "false") && (ghLimit/2 <= outputLength)) {
      printf("There are %s files with changed transitive imports taking up over %s characters: this is too many to display!\nYou can run this locally by cloning <a href=\"https://github.com/adomani/PR_summary\">adomani/PR_summary</a> and then using `scripts/import_trans_difference.sh -a` locally to see the whole output.", fileCount, outputLength)
    } else {
      for(x in reds) {
        sorted=""
        split(reds[x], toSort, "\n")
        asort(toSort)
        for(i in toSort) {sorted=sorted toSort[i]}
        if (nums[x] <= 2) { printf("|%s|%s|\n", sorted, x) }
        else { printf("|<details><summary>%s files</summary>%s</details>|%s|\n", nums[x], sorted, x) }
      }
    }
  }' "${tmpDir}/transImports*.txt" | sort -t'|' -n -k3
  ))"

rm -rf "${tmpDir}"
