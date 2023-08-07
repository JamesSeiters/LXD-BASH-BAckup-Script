#!/bin/bash

##############################################################################
# Get Projects                                                               #
# Purpose: Creates array of projects and creates directory for each project. #
# Inputs: None.                                                              #
# Ouput : None.                                                              #
# Version: 0.0.1                                                             #
# Date: 2023-27-07                                                           #
##############################################################################

projects=($(lxc project list --format json | jq -r '.[].name'))

# There should always be at least one project: the default one.
if [[ ${#projects[@]} -eq 0 ]]; then
	print_pretty "error" "No projects found."
	exit 1
fi
