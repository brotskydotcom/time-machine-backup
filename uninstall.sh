#!/bin/bash
function fail {
	echo $1
	exit 1
}
echo "Uninstalling launch agent..."
agent=~/Library/LaunchAgents/com.brotsky.backup.plist
[[ -f "$agent" ]] && launchctl unload "$agent"
rm -f "$agent"
[[ ! -f "$agent" ]] || fail "Failed to remove launch agent"
echo "Uninstalling script..."
scriptDir=~/.backup.brotsky.com
rm -rf "$scriptDir"
[[ ! -d "$scriptDir" ]] || fail "Failed to remove script directory"
echo "com.brotsky.backup stopped and uninstalled"
