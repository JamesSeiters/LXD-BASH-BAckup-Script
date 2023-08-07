#!/bin/bash

####################
# LXD Backup Usage #
####################

usage() {
	printf "Backup your LXD config in a modular fashion.\n\n"
	printf "Usage: ${0##*/} [ Options ]\n\n"
	printf '\t%s\t%s\n'\
	       "-c | --compress" "Compress containers (Default: ${default_option})"\
	       "-d | --dir" "Set backup directory (Default: ${default_directory})"\
		   "-h | --help" "Show this help message and exit."\
	       "--no-config" "Skip backing up LXD configuration (Default: ${default_option})"\
	       "--no-containers" "Skip backing up containers (Default: ${default_option})"\
	       "--no-images" "Skip backing up images (Default: ${default_option})"\
	       "--no-profiles" "Skip backing up profiles (Default: ${default_option})"\
	       "--no-remotes" "Skip backing up remotes (Default: ${default_option})"
}
