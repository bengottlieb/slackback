//
//  ScreenshotListener.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/7/21.
//

import UIKit

public class ScreenshotListener {
	public static let instance = ScreenshotListener()
	
	static let screenShotHoverDuration: TimeInterval = 6
	var lastScreenshotTakenAt: Date?
	weak var screenshotPromptTimer: Timer?
	
	func startListening(withToken token: String, channel: String) {
		ImageUploadRequest.authToken = token
		ImageUploadRequest.defaultChannel = channel
		
		NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification).eraseToAnyPublisher()
			.onSuccess { _ in
				self.lastScreenshotTakenAt = Date()

				DispatchQueue.main.async {
					ScreenshotToast.promptForComment() { cancelled in
						if cancelled {
							self.lastScreenshotTakenAt = nil
						} else {
							FeedbackForm.present(date: self.lastScreenshotTakenAt) }
					}
				}

				self.screenshotPromptTimer = Timer.scheduledTimer(withTimeInterval: Self.screenShotHoverDuration, repeats: false) { [unowned self] _ in
					self.checkForRecentScreenshot(at: self.lastScreenshotTakenAt)
				}
			}

		NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).eraseToAnyPublisher()
			.onSuccess { result in
				self.checkForRecentScreenshot(at: self.lastScreenshotTakenAt)
			}

		NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).eraseToAnyPublisher()
			.onSuccess { result in
				self.screenshotPromptTimer?.invalidate()
			}
	}
	
	func checkForRecentScreenshot(at date: Date?) {
		FeedbackForm.present(date: date)
	}
	
	func reset() {
		lastScreenshotTakenAt = nil
	}
}
