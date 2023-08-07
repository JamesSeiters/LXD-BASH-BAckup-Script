#!/bin/bash

###########################################
# Backup Containers                       #
# Purpose: Backup container data.         #
# Inputs: None.                           #
# Ouput : None.                           #
# Version: 0.0.1                          #
# Date: 2023-30-07                        #
###########################################

# Snapshot containers, publish to image, export, and remove published image

if [[ $skip_containers == "false" ]]; then
	print_pretty "Checking for existing containers to backup..."
	declare -a lxd_containers=($( lxc 2>/dev/null list -cn --format json --project $project| jq 2>/dev/null -r '.[].name' ))

	if [[ ${#lxd_containers[@]} -ge 1 ]]; then
		printf "Found ${#lxd_containers[@]} containers to backup:"

		for container in "${lxd_containers[@]}"; do
			print_pretty "Backing up container ${container}:"
			id=$(uuidgen)
			id=${id%%-*}
			backup="lxdbackup_$id"

			print_pretty "Creating snapshot of $container called ${backup}."
			lxc snapshot "$container" "$backup" --project $project
			print_pretty "Publishing snapshot ${container}/$backup as image ${container}-$backup"
			lxc publish "$compress_arg" "${container}/$backup" --alias "${container}-$backup" --project $project
			
			[[ $compress == "true" ]] && print_pretty "Exporting image ${container}-$backup as ${backup_directory}/${container}-${backup}.tar.gz"
			[[ $compress == "false" ]] && print_pretty "Exporting image ${container}-$backup as ${backup_directory}/${container}-${backup}.tar"
			lxc image export "${container}-$backup" "${backup_directory}/${container}-$backup" --project $project
			
			print_pretty "Deleting published image ${container}-$backup"
			lxc image delete "${container}-$backup" --project $project
			print_pretty "Deleting snapshot ${container}/$backup"
			lxc delete "${container}/$backup" --project $project
		done

	else
		print_pretty "No containers to backup."
	fi

fi
