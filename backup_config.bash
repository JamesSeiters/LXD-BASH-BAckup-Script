#!/bin/bash

###########################################
# Backup LXD Configuration                #
# Purpose: Backup LXD configuration data. #
# Inputs: None.                           #
# Ouput : None.                           #
# Version: 0.0.1                          #
# Date: 2023-27-07                        #
###########################################

backup_directory="$LXD_BACKUP_DIRECTORY"/config
make_directory "$backup_directory"

if [[ $skip_config == "false" ]]; then
	print_pretty "Dumping LXD Configuration YAML to ${backup_directory}/lxd-init-preseed.yaml"
	lxd init --dump | tee 1>/dev/null "${backup_directory}/lxd-init-preseed.yaml"
fi
