#!/bin/bash -e
cloud-init devel make-mime \
	-a user-data.yml:cloud-config \
	-a 01-remove-pkgs.sh:x-shellscript \
	-a 02-pam-session-tweaks.sh:x-shellscript \
	-a 10-freepbx-install.sh:x-shellscript | gzip -qnc > freepbx-user-data.gz
