// Copyright 2025 Daniel C Brotsky.  All rights reserved.
//
// All material in this project and repository is licensed under the
// GNU Affero General Public License v3. See the LICENSE file for details.

import Foundation
import SystemConfiguration

let computerName = getComputerName()
let bundleID = Bundle.main.bundleIdentifier ?? "io.clickonetwo.easy-backup-and-eject"
let scriptURL = ensureScriptURL()
let agentURL = ensureLaunchAgentURL()
let logURL = ensureLogURL()

var errorMessage: String = ""

func checkInstallationState() -> Bool? {
	let fileManager = FileManager.default
	guard let scriptURL = scriptURL, let agentURL = agentURL else {
		print("Failure due an earlier error: \(errorMessage)")
		return nil
	}
	if !fileManager.fileExists(atPath: scriptURL.path) {
		return false
	}
	if !FileManager.default.fileExists(atPath: agentURL.path) {
		return false
	}
	return true
}

func tryInstall(_ driveName: String) -> Bool {
	return tryInstallScript(driveName) && tryInstallAgent()
}


func tryInstallScript(_ driveName: String) -> Bool {
	let fileManager = FileManager.default
	guard let scriptURL = scriptURL else {
		print("Failure due an earlier error: \(errorMessage)")
		return false
	}
	print("Installing script...")
	var script: String = ""
	script += "#!/bin/sh\n"
	script += "drive='\(driveName)'\n"
	script += """
		date
		if mount | grep "$drive" ; then
			echo "Volume '$drive' mounted, starting backup..."
			tmutil startbackup -b
			diskutil unmount "$drive"
		else
			echo "Volume '$drive' not mounted, skipping backup."
		fi
		"""
	do {
		guard let data = script.data(using: .utf8) else {
			errorMessage = "Installation of script failed with error: Could not get data from UTF-8 string?"
			print(errorMessage)
			return false
		}
		try data.write(to: scriptURL)
	}
	catch {
		errorMessage = "Installation of script failed with error: \(error)"
		print(errorMessage)
		return false
	}
	print("Setting attributes of script...")
	do {
		let attributes = try fileManager.attributesOfItem(atPath: scriptURL.path)
		let mode = attributes[.posixPermissions] as? Int32
		let newMode: Int32 = (mode ?? 0x644) | 0o111
		try fileManager.setAttributes([.posixPermissions: newMode], ofItemAtPath: scriptURL.path)
	}
	catch {
		errorMessage = "Installation of script permissions failed with error: \(error)"
		print(errorMessage)
		return false
	}
	print("Installation of script succeeded.")
	return true
}

func tryInstallAgent() -> Bool {
	let fileManager = FileManager.default
	guard let scriptURL = scriptURL, let agentURL = agentURL, let logURL = logURL else {
		print("Failure due an earlier error: \(errorMessage)")
		return false
	}
	if fileManager.fileExists(atPath: agentURL.path) {
		print("Unloading existing agent...")
		execLaunchCtl("unload", agentURL.path)
	}
	print("Installing agent...")
	let agent: String = """
		<?xml version="1.0" encoding="UTF-8"?>
		<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
		<plist version="1.0">
			<dict>
				<key>Label</key>
				<string>\(bundleID)</string>
				<key>StartOnMount</key>
				<true/>
				<key>Program</key>
				<string>\(scriptURL.path)</string>
				<key>StandardOutPath</key>
				<string>\(logURL.path)</string>
				<key>StandardErrorPath</key>
				<string>\(logURL.path)</string>
			</dict>
		</plist>
		"""
	do {
		guard let data = agent.data(using: .utf8) else {
			errorMessage = "Installation failed with error: Could not get data from UTF-8 string?"
			print(errorMessage)
			return false
		}
		try data.write(to: agentURL)
	}
	catch {
		errorMessage = "Installation failed with error: \(error)"
		print(errorMessage)
		return false
	}
	print("Loading new agent...")
	if !execLaunchCtl("load", agentURL.path) {
		errorMessage = "Installation failed loading agent: " + errorMessage
		print(errorMessage)
		return false
	}
	print("Installation of agent succeeded.")
	return true
}

func tryUninstall() -> Bool {
	guard let scriptURL = scriptURL, let agentURL = agentURL else {
		print("Failure due an earlier error: \(errorMessage)")
		return false
	}
	let fileManager = FileManager.default
	print("Uninstalling...")
	if fileManager.fileExists(atPath: agentURL.path) {
		print("Unloading existing agent...")
		execLaunchCtl("unload", agentURL.path)
		print("Removing agent...")
		do {
			try fileManager.removeItem(at: agentURL)
		}
		catch {
			errorMessage = "Uninstallation of agent failed with error: \(error)"
			print(errorMessage)
			return false
		}
	}
	if fileManager.fileExists(atPath: scriptURL.path) {
		print("Removing script...")
		do {
			try fileManager.removeItem(at: scriptURL)
		}
		catch {
			errorMessage = "Uninstallation of script failed with error: \(error)"
			print(errorMessage)
			return false
		}
	}
	print("Uninstallation complete.")
	return true
}

func ensureScriptURL() -> URL? {
	let fileManager = FileManager.default
	if let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
		let clickOneTwoDirectory = appSupportDirectory.appending(component: "ClickOneTwo", directoryHint: .isDirectory)
		var isDir: ObjCBool = false
		if fileManager.fileExists(atPath: clickOneTwoDirectory.path, isDirectory: &isDir) {
			guard isDir.boolValue else {
				errorMessage = "ClickOneTwo Application Support directory appears to be a file?"
				print(errorMessage)
				return nil
			}
		} else {
			do {
				try fileManager.createDirectory(at: clickOneTwoDirectory, withIntermediateDirectories: false, attributes: nil)
			} catch {
				errorMessage = "Can't create ClickOneTwo app support directory: \(error)"
				print(errorMessage)
				return nil
			}
		}
		let val = clickOneTwoDirectory.appending(component: "easy-backup-and-eject.sh")
		print("Script URL is: \(val)")
		return val
	}
	else {
		errorMessage = "Error: Could not find the Application Support directory."
		print(errorMessage)
		return nil
	}
}

func ensureLaunchAgentURL() -> URL? {
	let fileManager = FileManager.default
	if let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
		let agentDirectory = libraryDirectory.appending(component: "LaunchAgents", directoryHint: .isDirectory)
		var isDir: ObjCBool = false
		if fileManager.fileExists(atPath: agentDirectory.path, isDirectory: &isDir) {
			guard isDir.boolValue else {
				errorMessage = "The LaunchAgents library directory appears to be a file?"
				print(errorMessage)
				return nil
			}
		} else {
			do {
				try fileManager.createDirectory(at: agentDirectory, withIntermediateDirectories: false, attributes: nil)
			} catch {
				errorMessage = "Can't create LaunchAgents directory: \(error)"
				print(errorMessage)
				return nil
			}
		}
		let val = agentDirectory.appending(component: "\(bundleID).plist")
		print("Agent URL is: \(val)")
		return val
	}
	else {
		errorMessage = "Could not find Library directory."
		print(errorMessage)
		return nil
	}
}

func ensureLogURL() -> URL? {
	let fileManager = FileManager.default
	if let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
		let logsDirectory = libraryDirectory.appending(component: "Logs", directoryHint: .isDirectory)
		var isDir: ObjCBool = false
		if fileManager.fileExists(atPath: logsDirectory.path, isDirectory: &isDir) {
			guard isDir.boolValue else {
				errorMessage = "The Logs library directory appears to be a file?"
				print(errorMessage)
				return nil
			}
		} else {
			do {
				try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: false, attributes: nil)
			} catch {
				errorMessage = "Can't create Logs directory: \(error)"
				print(errorMessage)
				return nil
			}
		}
		let val = logsDirectory.appending(component: "\(bundleID).log")
		print("Log URL is: \(val)")
		return val
	}
	else {
		errorMessage = "Could not find Logs directory."
		print(errorMessage)
		return nil
	}
}

@discardableResult
func execLaunchCtl(_ args: String...) -> Bool {
	print("Running launchctl \(args)")
	let task = Process()
	let pipe = Pipe()
	task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
	task.arguments = args
	task.standardError = pipe
	var errorData: Data?
	do {
		try task.run()
		errorData = try pipe.fileHandleForReading.readToEnd()
		task.waitUntilExit()
	}
	catch {
		errorMessage = "Failed to \(args[0]) launch agent: \(error)"
		print(errorMessage)
		return false
	}
	if let data = errorData, let output = String(data: data, encoding: .utf8), !output.isEmpty {
		errorMessage = "Failed to \(args[0]) launch agent: \(output)"
		print(errorMessage)
		return false
	}
	if task.terminationStatus != 0 {
		errorMessage = "Failed to \(args[0]) launch agent: non-zero termination status \(task.terminationStatus)"
		print(errorMessage)
		return false
	}
	return true
}

func getComputerName() -> String {
	let name: CFString? = SystemConfiguration.SCDynamicStoreCopyComputerName(nil, nil)
	if let name = name {
		return name as String
	}
	return "MyMac"
}
