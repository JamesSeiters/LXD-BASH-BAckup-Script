#!/bin/bash

###########################################
# Backup Profiles                         #
# Purpose: Backup LXD profile data.       #
# Inputs: None.                           #
# Ouput : None.                           #
# Version: 0.0.1                          #
# Date: 2023-30-07                        #
###########################################

if [[ $skip_profiles == "false" ]]; then
	print_pretty "Checking for profiles to backup..."
	declare -a lxd_profiles=($( lxc 2>/dev/null profile list --format json --project "$project" | jq 2>/dev/null -r '.[].name' ))

	if [[ ${#lxd_profiles[@]} -ge 1 ]]; then
		print_pretty "Found ${#lxd_profiles[@]} profiles to backup:"
		export -f print_pretty
		parallel --trim r -d ' ' print_pretty '"Backing up "'{1}';' lxc profile show {1} --project {3} '>'{2}'/'{1}-lxd-profile.yaml ::: "${lxd_profiles[@]}" ::: "$backup_directory" ::: "$project"
	else
		print_pretty "No profiles to backup."
	fi

fi
