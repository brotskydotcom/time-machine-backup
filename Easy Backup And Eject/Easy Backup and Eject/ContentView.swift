// Copyright 2025 Daniel C Brotsky.  All rights reserved.
//
// All material in this project and repository is licensed under the
// MIT License. See the LICENSE file for details.

import SwiftUI

struct ContentView: View {
	@Environment(\.openURL) var openURL

	@State var internalError: Bool = false
	@State var driveName: String = getComputerName() + " backup"
	@State var actionCount: Int = 0
	@State var isInstalled: Bool = false
	@State var installText: String = "Install"
	@State var uninstallText: String = "Uninstall"

    var body: some View {
		VStack(spacing: 2) {
			Text("This app install or uninstalls a macOS utility that watches for you to connect your Time Machine backup drive, then automatically backs up your Mac and ejects your drive.\n\nYou will need to uninstall the utility before you can do a restore from your backup drive. Once you've completed the restore, you can reinstall the utility.\n\nTo install, enter the name of your backup drive and tap the 'Install' button.\n\nTo uninstall, tap the 'Uninstall' button.")
			HStack(spacing: 2) {
				Text("Your backup drive name: ")
				TextField("My backup", text: $driveName)
			}
			.padding()
			HStack {
				Spacer()
				Button(installText, action: attemptInstall)
					.disabled(driveName.isEmpty)
				Spacer()
				Button(uninstallText, action: attemptUninstall)
				Spacer()
			}
			.alert("Internal Error", isPresented: $internalError)
			{
				Button("OK") {}.keyboardShortcut(.defaultAction)
				Button("Report") {
					openURL(URL(string: "mailto:dan@clickonetwo.io")!)
				}
			}
			message: {
				Text(errorMessage + "\n\nSometimes restarting your machine and trying again will fix the problem. If not, please report the problem to the developer.")
			}
			Text(LocalizedStringResource("The utility is currently **\(isInstalled ? "installed" : "not installed")**"))
				.padding()
        }
		.frame(maxWidth: 450)
        .padding()
		.onChange(of: actionCount, initial: true, updateInstallationState)
    }

	func updateInstallationState() {
		if let state = checkInstallationState() {
			isInstalled = state
		} else {
			isInstalled = false
			internalError = true
		}
	}

	func attemptInstall() {
		if !tryInstall(driveName) {
			internalError = true
		}
		actionCount += 1
	}

	func attemptUninstall() {
		if !tryUninstall() {
			internalError = true
		}
		actionCount += 1
	}
}

#Preview {
    ContentView()
}
