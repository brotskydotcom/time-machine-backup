# source this in the local directory after putting app into the dmg-source
# directory and copying the AppIcon.icns file into the local directory
#
create-dmg \
	--volname "Easy Backup and Eject" \
	--volicon "AppIcon.icns" \
	--window-pos 200 120 \
	--window-size 800 400 \
	--icon-size 100 \
	--icon "Easy Backup and Eject.app" 200 190 \
	--hide-extension "Easy Backup and Eject.app" \
	--app-drop-link 600 185 \
	--filesystem APFS \
	"easy-backup-and-eject.dmg" \
	"dmg-source/"
