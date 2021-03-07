//
//  SlackBackApp.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/6/21.
//

import SwiftUI
import Suite
import UIKit

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

		NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification).eraseToAnyPublisher()
			.onCompletion { result in
				UIApplication.shared.currentWindow?.rootViewController?.presentedest.present(UIAlertController(title: "Hello", message: "Screen Shot", button: "OK"), animated: true, completion: nil)
			}

		NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).eraseToAnyPublisher()
			.onCompletion { result in
				print("Active: \(result)")
			}

		NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).eraseToAnyPublisher()
			.onCompletion { result in
				print("Inactive: \(result)")
			}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
