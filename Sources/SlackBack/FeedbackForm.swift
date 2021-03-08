//
//  FeedbackForm.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/7/21.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import Suite

class FeedbackForm {
	static weak var feedbackController: UIViewController?
	static var grabber: ScreenshotGrabber?
	
	static func present(date: Date?) {
		guard let date = date else { return }
		
		self.grabber = ScreenshotGrabber(date: date)
		
		self.grabber?.updateAsset()
			.filter { $0 != nil }
			.eraseToAnyPublisher()
			.onSuccess() { _ in
				self.present(grabber: grabber!)
			}
	}
	
	static func present(grabber: ScreenshotGrabber) {
		if feedbackController != nil { return }
		guard let window = UIApplication.shared.currentScene?.mainWindow, let root = window.rootViewController else { return }
		let controller = UIHostingController(rootView: FeedbackView(presenter: root, image: grabber.image))
		window.rootViewController?.present(controller, animated: true, completion: nil)
		
		feedbackController = controller
	}
}
