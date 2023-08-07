#!/bin/bash

#########################################################
# Make Directory                                        #
# Purpose: Create Backup Directories in LXD_BACKUP_DIRECTORY. #
# Inputs : $1 - Directory to create.                    #
# Ouput  : None.                                        #
# Version: 0.0.1                                        #
# Date   : 2023-28-07                                   #
#########################################################

make_directory() {
	if [[ ! -d $1 ]]; then
		mkdir -p "$1"

		if [[ $? -ne 0 ]]; then
			print_pretty "error" "Failed to create directory: $1"
			exit 1
		fi
		
		print_pretty "Created directory: $1"
	fi
}
