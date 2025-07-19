#!/bin/bash
function fail {
	echo $1
	exit 1
}
username="$(id -un)"
# install the shell script
echo "Installing the shell script..."
mkdir -p ~/Library/"Application Support"/ClickOneTwo || fail "Failed to create App Support directory"
script=~/Library/"Application Support"/ClickOneTwo/easy-backup-and-eject.sh
cat <<"SCRIPTEOF" > "$script"
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
SCRIPTEOF
[[ -f "$script" ]] || fail "Failed to create script"
chmod a+x "$script"
# install the launch agent
echo "Installing the launch agent..."
plist=~/Library/LaunchAgents/io.clickonetwo.easy-backup-and-eject.plist
[[ -f "$plist" ]] && launchctl unload "$plist"
cat <<"AGENTEOF" > /tmp/agent.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>io.clickonetwo.easy-backup-and-eject</string>
		<key>StartOnMount</key>
		<true/>
		<key>Program</key>
		<string>/Users/USERNAME/Library/Application Support/ClickOneTwo/easy-backup-and-eject.sh</string>
		<key>StandardOutPath</key>
		<string>/Users/USERNAME/Library/Logs/io.clickonetwo.easy-backup-and-eject.log</string>
		<key>StandardErrorPath</key>
		<string>/Users/USERNAME/Library/Logs/io.clickonetwo.easy-backup-and-eject.log</string>
	</dict>
</plist>
AGENTEOF
[[ -f /tmp/agent.plist ]] || fail "Failed to create plist"
awk "{gsub(/USERNAME/, \"$username\"); print}" /tmp/agent.plist > "$plist"
[[ -f "$plist" ]] || fail "Failed to create agent"
rm /tmp/agent.plist
launchctl load "$plist"
echo "Easy Backup and Eject is installed and running"
