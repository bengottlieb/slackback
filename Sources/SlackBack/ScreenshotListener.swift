//
//  ScreenshotListener.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/7/21.
//

import UIKit

public class ScreenshotListener {
	public static let instance = ScreenshotListener()
	
	func startListening() {
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
}
