# Makefile for CleverCSV pre-commit dummy package
#
# Author: G.J.J. van den Burg
# Copyright (c) 2020, The Alan Turing Institute
# License: MIT
# Date: 2020-11-06

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --no-builtin-rules

VENV_DIR=/tmp/clevercsv_precommit_venv

########
# Help #
########

.DEFAULT_GOAL := help

.PHONY: help

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		 awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m\
		 %s\n", $$1, $$2}'

################
# Bump version #
################

.PHONY: bump bump_nogit

bump: ./bump_version.sh ## Bump the CleverCSV version to that on PyPI
	./bump_version.sh

bump_nogit: ./bump_version.sh ## Bump the CleverCSV version, but don't git commit
	./bump_version.sh no-git

########
# Push #
########

.PHONY: push

push: ## Helper to remember to push _with_ tags
	git push -u --tags origin master

###########
# Testing #
###########

.PHONY: test

test: venv ## Run the tests for the pre-commit hook
	source $(VENV_DIR)/bin/activate && ./tests/run_tests.sh

###########
# Release #
###########

.PHONY: release

release: make_release.py ## Prepare a release of this package
	python $<
#######################
# Virtual environment #
#######################

.PHONY: venv

venv: $(VENV_DIR)/bin/activate ## Set up the virtual environment

$(VENV_DIR)/bin/activate:
	test -d $(VENV_DIR) || python -m venv $(VENV_DIR)
	source $(VENV_DIR)/bin/activate && pip install pre-commit
	touch $(VENV_DIR)/bin/activate

clean_venv: ## Clean up the virtual environment
	rm -rf $(VENV_DIR)
