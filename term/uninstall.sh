#!/bin/bash
function fail {
	echo $1
	exit 1
}
echo "Uninstalling launch agent..."
# first remove the legacy location
agent=~/Library/LaunchAgents/com.brotsky.backup.plist
if [[ -f "$agent" ]]; then
	launchctl unload "$agent"
	rm -f "$agent"
	[[ ! -f "$agent" ]] || fail "Failed to remove launch agent"
fi
# next remove the current location
agent=~/Library/LaunchAgents/io.clickonetwo.easy-backup-and-eject.plist
[[ -f "$agent" ]] && launchctl unload "$agent"
rm -f "$agent"
[[ ! -f "$agent" ]] || fail "Failed to remove launch agent"
echo "Uninstalling script..."
# first remove the legacy location
scriptDir=~/.backup.brotsky.com
if [[ -d "$scriptDir" ]]; then
	rm -rf "$scriptDir"
	[[ ! -d "$scriptDir" ]] || fail "Failed to remove script directory"
	echo "com.brotsky.backup stopped and uninstalled"
fi
# next remove the current script
script=~/Library/"Application Support"/ClickOneTwo/easy-backup-and-eject.sh
rm -rf "$script"
[[ ! -d "$script" ]] || fail "Failed to remove script"
echo "Easy Backup and Eject stopped and uninstalled"
