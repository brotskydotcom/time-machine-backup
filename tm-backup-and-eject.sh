#!/bin/bash
hostname="$(scutil --get ComputerName)"
drive="$hostname backup"
date
if mount | grep "$drive" ; then
	echo "Volume '$drive' mounted, starting backup..."
	tmutil startbackup -b
	diskutil unmount "$drive"
else
	echo "Volume '$drive' not mounted, skipping backup."
fi
