#!/bin/bash

#############################
# LXD Backup Main           #
# Purpose: Backup LXD data. #
# Inputs: None.             #
# Ouput : None.             #
# Version: 0.0.1            #
# Date: 2023-27-07          #
#############################

##################
# Bash Framework #
##################
if [[ -z $BASH_FRAMEWORK_DIRECTORY ]]; then
	printf '\n%s\n\n' "BASH_FRAMEWORK_DIRECTORY is not set. Exiting."
	exit 1
fi

for file in "$BASH_FRAMEWORK_DIRECTORY"/*; do
	. "$file"
done

###########
# Globals #
###########
# Sets a default backup directory. Can be overridden with the -d option.
readonly default_directory="/Development/Shared/Backup/ITTestServ00000"
readonly default_option="false"
[[ -z $LXD_BACKUP_DIRECTORY ]] && LXD_BACKUP_DIRECTORY="$default_directory"
readonly directories=("profiles" "images" "containers")
readonly short_options="cd:h"
readonly long_options="compress,dir:,no-profiles,no-images,no-containers,no-remotes,no-config,help"
compress="$default_option"
skip_profiles="$default_option"
skip_images="$default_option"
skip_containers="$default_option"
skip_remotes="$default_option"
skip_config="$default_option"
compress_arg='--compression=none'

####################
# Script Functions #
####################
. usage.bash
. process_options.bash
. make_directory.bash

process_options "$short_options" "$long_options" "$@"

#######################
# Local Sanity Checks #
#######################
# Root/sudo check. If the lxc remotes command is executed with sudo the backup will fail to find any non-default remotes.
if [[ $(id -u) -ne 0 ]]; then
	print_pretty "warning" "Not running as sudo, make sure you have access to the backup directories."
fi

# Ensure jq is installed.
if [[ -z "$(command 2>/tmp/error -v jq)" ]]; then
	print_pretty "error" "$(</tmp/error)."
	exit 1
fi

# Ensure the backup directory array is defined.
if [[ ${#directories[@]} -eq 0 ]]; then
	print_pretty "error" "The backup directories array is not defined."
	exit 1
fi

################
# Main Program #
################
# Ensure the backup directory variable is defined.
if [[ -z $LXD_BACKUP_DIRECTORY ]]; then
	print_pretty "error" "The LXD backup directory variable is not defined."
	exit 1
fi

. backup_config.bash
. backup_remotes.bash
. get_projects.bash

for project in "${projects[@]}"; do
	print_pretty "Backing up project ${project}:"

	for directory in "${directories[@]}"; do
		backup_directory="${LXD_BACKUP_DIRECTORY}/${project}/$directory"
		make_directory "$backup_directory"
		. "backup_${directory}.bash"
	done

	print_pretty "Done."
done

# Show information
#### TODO: Is this needed?
print_pretty "LXD-Backup script has completed."
[[ -n $(which tree) ]] && { tree -hDC "$LXD_BACKUP_DIRECTORY" || { du -sh "$LXD_BACKUP_DIRECTORY" | awk '{print $2,$1}'; }
