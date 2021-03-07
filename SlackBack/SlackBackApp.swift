//
//  SlackBackApp.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/6/21.
//

import SwiftUI
import Suite
import UIKit

/*
	Need to go to https://api.slack.com/apps/[YOUR APP ID]/install-on-team
	<Reinstall to Workspace>
	
	Then in the channel (web or app) select "More…" > "Add Apps", and add the test app to your channel
*/

@main
struct SlackBackApp: App {
	init() {
		guard
			let tokenURL = Bundle.main.url(forResource: "token", withExtension: "json", subdirectory: "tokens"),
			let data = try? Data(contentsOf: tokenURL),
			let token = String(data: data, encoding: .utf8)
		else {
			fatalError("Please grab a Slack token for your Slack app, and save it in a file called `token.json` in the `tokens` directory.")
		}
		
		ImageUploadRequest.authToken = token
		ScreenshotListener.instance.startListening()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
	
	func testUpload() {
		ImageUploadRequest(file: Bundle.main.url(forResource: "sample_upload", withExtension: "jpeg")!, channel: "test", comment: "Upload Test \(Date())")?.upload()
			.onCompletion { result in
				print(result)
			}
	}
}
