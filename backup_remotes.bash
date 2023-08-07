#!/bin/bash

#####################################
# Backup Remotes                    #
# Purpose: Backup LXD remotes list. #
# Inputs: None.                     #
# Ouput : None.                     #
# Version: 0.0.1                    #
# Date: 2023-27-07                  #
#####################################

backup_directory="${LXD_BACKUP_DIRECTORY}/remotes"
make_directory "$backup_directory"

if [[ $skip_remotes == "false" ]]; then
	print_pretty "Checking for remotes to backup:"
	declare -a lxd_remotes=($(su - $(get_user) -c 'lxc 2>/dev/null remote list --format json|jq 2>/dev/null -r '\''.|to_entries[]|select((.value.Addr=="https://images.linuxcontainers.org") or (.value.Addr=="unix://") or (.value.Addr=="https://cloud-images.ubuntu.com/releases") or (.value.Addr=="https://cloud-images.ubuntu.com/daily")|not)|"\(.key)"'\'''))

	if [[ ${#lxd_remotes[@]} -ge 1 ]]; then
		print_pretty  "Found ${#lxd_remotes[@]} (non-default) remotes to backup"
		print_pretty  "Backing up the following remotes to ${backup_directory}/add-lxd-remotes.sh$( printf '\t - %s\n' ${lxd_remotes[@]} )"
		echo '#!/bin/bash' | tee 1>/dev/null "${backup_directory}/add-lxd-remotes.sh"
		loginuser=$(get_user)
		echo $loginuser
		su - $loginuser -c 'lxc remote list --format json | jq 2>/dev/null -r '\''to_entries[]|select(.value.Addr=="https://images.linuxcontainers.org" or .value.Addr=="unix://" or .value.Addr=="https://cloud-images.ubuntu.com/releases" or .value.Addr=="https://cloud-images.ubuntu.com/daily"|not)|"lxc remote add \(.key) \(.value.Addr) --protocol \(.value.Protocol) --public \(.value.Public)"'\''' | tee 1>/dev/null -a "${backup_directory}/add-lxd-remotes.sh"
		chmod +x "${backup_directory}/add-lxd-remotes.sh"

	else
		print_pretty "No non-default remotes to backup."
	fi

fi
