#!/bin/bash
#
# Set the .version file version to the PyPI version of CleverCSV
#
# Author: G.J.J. van den Burg
# Date: 2020-11-06
#

set -e -u

DO_GIT=true

if [ $# -gt 1 ]
then
	if [ "$1" == "no-git" ]
	then
		DO_GIT=false
	fi
fi

VERSION_FILE=".version"
PYPI_JSON_URL="https://pypi.org/pypi/clevercsv/json"

latest=$(curl -s ${PYPI_JSON_URL} |  jq -r '.releases | keys | .[]' | sort -V | tail -n 1)

echo ${latest} > ${VERSION_FILE}

if [ ${DO_GIT} ]
then
	git add ${VERSION_FILE}
	git commit -m "[BUMP] Increment CleverCSV package version to ${latest}" ${VERSION_FILE}
	git tag -s -m "Bump CleverCSV pre-commit hook version" "v${latest}"
fi
