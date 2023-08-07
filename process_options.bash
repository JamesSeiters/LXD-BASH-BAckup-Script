#!/bin/bash

#########################################################
# LXD Backup Options Handler                            #
# Purpose : Process options passed to the backup script.#
# Input   : 1 - short options                           #
#           2 - long options                            #
#           3 - arguments passed to main                #
# Output  : None.                                       #
# Version : 0.0.1                                       #
# Date    : 2023-27-07                                  #
#########################################################

process_options() {
	print_pretty "wait" "Processing options"
	local args
	args=$(getopt -n "LXD Backup" -o "$short_options" --long "$long_options" -- "$@" 2>/tmp/getopt.log ) 2>/dev/null

	if [[ $? -ne 0 ]]; then
		print_pretty "Failed."
		print_pretty "error" "Setting options failed. $(</tmp/getopt.log)"
		exit 1
	fi
	
	eval set -- "$args"

	while true ; do
		case "$1" in
			-c | --compress )
				compress="true"
				compress_arg=""
				shift 1
			;;
			-d | --dir )
				LXD_BACKUP_DIRECTORY="$2:-$LXD_BACKUP_DIRECTORY"
				shift 2
			;;
			--no-profiles )
				skip_profiles="true"
				shift 1
			;;
			--no-images )
				skip_images="true"
				shift 1
			;;
			--no-containers )
				skip_containers="true"
				shift 1
			;;
			--no-remotes )
				skip_remotes="true"
				shift 1
			;;
			--no-config )
				skip_config="true"
				shift 1
			;;
			-h | --help )
				print_pretty "Done."
				usage
				exit 0
			;;
			-- )
				shift
				break
			;;
			* ) 
				print_pretty "Failed."
				print_pretty "error" "Unexpected option: $1 - this should not happen."
			 	exit 1
			;;
		esac
	done
	print_pretty "Done."
}