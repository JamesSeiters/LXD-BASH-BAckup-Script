#!/bin/bash

###########################################
# Backup Images                           #
# Purpose: Backup images data.            #
# Inputs: None.                           #
# Ouput : None.                           #
# Version: 0.0.1                          #
# Date: 2023-30-07                        #
###########################################

# Dump images so you don't have to download them again.

if [[ $skip_images == "false" ]]; then
	print_pretty "Checking for existing images to backup..."
	declare -a lxd_images=($( lxc 2>/dev/null image list --format json --project "$project" | jq 2>/dev/null -r '.[]|"\(.fingerprint[0:12])"' ))
	
	if [[ ${#lxd_images[@]} -ge 1 ]]; then
		print_pretty "Found ${#lxd_images[@]} images to backup:"

		for image in "${lxd_images[@]}"; do
			print_pretty "Checking for aliases for ${image}..."
			declare -a aliases=($( lxc image list "$image" --format json --project "$project" 2>/dev/null | jq 2>/dev/null -r '"\(.[].aliases[].name)"' ))
			
			if [[ ${#aliases[@]} -ge 1 ]]; then
				print_pretty "Creating script to add aliases for $image (${backup_directory}/add-aliases-${image}.sh)."
				cat <<-EOF > "${backup_directory}/add-aliases-${image}.sh"
				#!/bin/bash
				for i in $(lxc image list "$image" --format json --project "$project" 2>/dev/null | jq 2>/dev/null -r '"\(.[].aliases[].name)"' | paste -sd" "); do
				    printf "Adding alias \"\${i}\" to image ${image}\n"
				    #echo lxc image alias create local:\"\${i}\" "$image"
					lxc image alias create local:\"\${i}\" "$image" --project "$project"
				done
				EOF
				chmod +x "${backup_directory}/add-aliases-${image}.sh"
			else
				print_pretty "No aliases found for ${image}."
			fi

			print_pretty "Exporting image $image as ${backup_directory}/${image}(.root)"
			lxc image export "$image" "${backup_directory}/${image}" --project "$project"
		done

	else
		print_pretty "No images to backup."
	fi
fi
