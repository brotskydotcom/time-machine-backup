# Time Machine Backup

This is a launch agent that facilitates easy backups on macOS. You use it as follows:

1. Configure an external drive as your Time Machine backup drive. The name of the drive should be the name of your machine, followed by a space and the word `backup`. For example, if the name of my machine were `Hoboken`, then my backup drive should be called `Hoboken backup`. In fact, the name of my machine is `dan`, so my backup drive is named `dan backup`.
   - We’re talking about the name of your machine as configured in **System Preferences>General>About**, not your machine’s `hostname` or DNS name.
   - In the terminal, you can see your machine’s name via `scutil --get ComputerName`.

2. Configure Time Machine not to do automatic backups. To do this, in **System Preferences>General>Time Machine**, go to **Options…** and set the **Backup Frequency** to be **Manually**.

3. Eject your backup drive.

4. Install this script with this terminal command:
   ```bash
   curl https://brotsky.com/downloads/time-machine-backup/install.sh | /bin/bash
   ```

Now, every time you connect your backup drive, a Time Machine backup will be performed. You can keep track of the progress of the backup by using the Time Machine item in the menu bar, or the spinning icon next to your drive in a Finder window sidebar. When the backup is done, your backup drive will be unmounted, so it will disappear from the Finder, and you can disconnect it safely.

But how, you may ask, can I then do a restore from my Time Machine backups? Excellent question! Since you need to insert the drive in order to do a restore, but inserting the drive will start a backup and then eject the drive, you must first uninstall this utility using the following Terminal command:

```bash
curl https://brotsky.com/downloads/time-machine-backup/uninstall.sh | /bin/bash
```

This will completely remove the launch agent, allowing you to connect/mount your drive normally and then do your restore (or anything else you want to do). Once you’re done with your restore, just disconnect your drive and reinstall the launch agent using the command in #4, above.

## Multi-user Scenarios

This utility is a per-user launch agent, so each user on the same machine who wants to use it while they are logged in must install it themselves. I have no idea what will happen on a machine with multiple users who are logged in at the same time and who all have installed this utility. If you run into issues trying such a scenario, let me know via an issue in this repository and I will take a look.

## License

This entire repository is available for use under the MIT License found in the [LICENSE](LICENSE) file. Bug reports and other contributions are always welcome. Have fun!
