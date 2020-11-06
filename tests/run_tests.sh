#!/bin/bash
#
# Testing script for the CleverCSV pre-commit hook
#
# Simulates creating a repo, adding the hook, and trying to commit some poorly 
# formatted CSV files (which pre-commit is expected to stop)
#
# Author: G.J.J. van den Burg
#

set -u -x

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VERSION=$(cat ${HERE}/../.version)
TEMP_REPO=$(mktemp -d)

# Switch to a temporary directory
pushd ${TEMP_REPO}

# Initialize a git repo
git init

# Copy some test csv files
cp ${HERE}/*.csv .

# Add the pre-commit configuration
cat <<EOF > .pre-commit-config.yaml
repos:
  - repo: https://github.com/alan-turing-institute/CleverCSV-pre-commit
    rev: ${VERSION}
    hooks:
      - id: clevercsv-standardize
EOF

# Commit the pre-commit config
git add .pre-commit-config.yaml
git commit -m "add pre-commit configuration"

# Install the pre-commit hook
pre-commit install

# Add and try to commit the CSV files
git add *.csv
git commit -m "try to add some bad CSVs"

# This is not supposed to work, so we check that git commit failed
if [ $? -eq 0 ]
then
	echo "An error occurred, pre-commit didn't stop the commit as expected"
	exit 1
fi

# Now add them again (as clevercsv standardize has edited them)
git add *.csv
git commit -m "commit the correct CSVs"

# This is supposed to work, if it doesn't something went wrong
if [ $? -ne 0 ]
then
	echo "Something went wrong with the commit that was supposed to work."
	exit 2
fi

# Go back to the original directory
popd

# Delete the temporary repo
rm -rf ${TEMP_REPO}
