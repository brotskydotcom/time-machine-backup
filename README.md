# Easy Backup and Eject

This is a utility that facilitates making disaster-recovery backups on macOS laptops. Even if you use a cloud-storage facility for your important documents, having a Time Machine backup that’s reasonably up-to-date is critical for macOS users because Time Machine is the only backup mechanism that does a good job of capturing all your preferences for the system and other apps, including things like window position (which some of us spend a lot of time getting “just the way we like it” :-).

The problem with doing automatic Time Machine backups on a laptop is that it means you need to leave your backup drive mounted on your laptop at all times. This forces you, every time you want to move your laptop somewhere, to carefully eject your backup drive before disconnecting it. And doing this ejection can be difficult and time consuming, especially if your laptop has been sleeping or is in the middle of a backup.

With this utility installed, and your Time Machine backups set to “Manual” rather than on a schedule, that problem goes away. Instead, you just plug your backup drive into your laptop whenever it’s convenient to do so, and the utility will immediately do a Time Machine backup and then eject (aka unmount) the backup drive. You can then physically (and safely) disconnect the drive whenever (immediately after the backip completes or days later when you next move your laptop). I don’t know about you, but I move my laptop around a decent amount, so just plugging the drive back in whenever I get back to my desk ensures that I have a Time Machine backup that’s at most a few days old.

## Installation

There are two ways to install or uninstall this utility. One of them is to [run this Application](https://www.brotsky.com/downloads/time-machine-backup/easy-backup-and-eject.dmg). The other is to issue a command in the Mac Terminal. For installation, use this command:

```bash
curl https://www.brotsky.com/downloads/time-machine-backup/install.sh | /bin/bash
```

For uninstallation, use this command:

```bash
curl https://www.brotsky.com/downloads/time-machine-backup/install.sh | /bin/bash
```

It’s best not to install the utility until you’ve already configured your backup drive, as described under [Usage](#usage). However, the utility can be uninstalled and reinstalled as many times as you want, so if you want to practice installing and uninstalling before you configure your backup drive, that’s fine. The utility will do nothing unless it sees you insert your configured Time Machine backup drive.

## Usage

In order to use this utility, you must first configure an external drive as your Time Machine backup drive. I recommend that you configure the drive and make an initial backup _before_ you install the utility. That first backup takes a really long time, and you will want to make sure that it succeeded before you automatically backup when connecting your disk.

* If you’re going to use the installer program to install the utility, you can name your drive whatever you want, and then tell the installer what it’s called. 

* If you’re going to use the Terminal to install the utility, the name of the drive must be the name of your machine followed by a space and the word `backup`. For example, if the name of my machine were `Hoboken`, then my backup drive must be called `Hoboken backup`. In fact, the name of my machine is `dan`, so my backup drive is named `dan backup`.

  * I’m talking about the name of your machine as configured in **System Preferences>General>About**, not your machine’s `hostname` or DNS name.

  - In the terminal, you can see your machine’s name via `scutil --get ComputerName`.
  - Case matters: if your machine name is has capital letters, the name of your drive must have the same capitalized letters in the same places.

As you’re configuring your backup drive, configure your Time Machine _not_ to do automatic backups. In **System Preferences>General>Time Machine**, go to **Options…** and set the **Backup Frequency** to be **Manually**.

Once you’ve configured your backup drive and Time Machine, go ahead and install the utility using the [instructions above](#installation). Now, every time you connect your backup drive, a Time Machine backup will be performed. You can keep track of the progress of the backup by using the Time Machine item in the menu bar, or the spinning icon next to your drive in a Finder window sidebar. When the backup is done, your backup drive will be ejected (aka unmounted), so it will disappear from the Finder, and you can physically disconnect it safely.

## Restoring from Backup

Since you need to insert the drive in order to use Time Machine to do a restore, but inserting the drive will start a backup and then eject the drive, you must uninstall this utility *before* you can restore. Either method of uninstallation will work, regardless of how you installed.

Once you have uninstalled, you can connect/mount your drive normally and then do your restore (or anything else you want to do). Once you’re done with your restore, just disconnect your drive and reinstall the utility the way you did originally.

## Multi-user Scenarios

This utility works on a per-user launch basis, so each user on the same machine who wants to use it while they are logged in must install it themselves. I have no idea what will happen on a machine with multiple users who are logged in at the same time and who all have installed this utility. If you run into issues trying such a scenario, let me know via an issue in this repository and I will take a look.

## Implementation Details

The actual work of doing the backup and then ejecting the drive is done by a bash script installed in the per-user Application Support directory: 

​	`~/Library/"Application Support"/ClickOneTwo/easy-backup-and-eject.sh`

There is a per-user launch agent installed which watches for disk mounts:

​	`~/Library/LaunchAgents/io.clickonetwo.easy-backup-and-eject.plist`

Whenever the mounted disk is your backup disk, the agent invokes the bash script above, directing all its output to a log file which you can look at to see what’s been happening:

​	` ~/Library/Logs/io.clickonetwo.easy-backup-and-eject.log`

Both `stdout` and `stderr` go into the same log file.

If you install the utility via the application, then the name of your backup disk is written directly into the shell script, which is why you can use any name you want. If you install via the Terminal command, the name of the backup disk is deduced from your machine name, which is why you have to use the format described in the [Usage](#usage) section. Every installation completely replaces the previous installation, so it’s only the last installation that is active.

## License

This entire repository is available for use under the MIT License found in the [LICENSE](LICENSE) file. Bug reports and other contributions are always welcome. Have fun!
