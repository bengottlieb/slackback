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
		let controller = UIHostingController(rootView: FeedbackView(presenter: root, grabber: grabber))
		window.rootViewController?.present(controller, animated: true, completion: nil)
		
		feedbackController = controller
	}
}



struct FeedbackView: View {
	let presenter: UIViewController
	@ObservedObject var grabber: ScreenshotGrabber
	@State var text = ""
	
	@State var showing = false
	
	var body: some View {
		Group() {
			if showing {
				ZStack() {
					Color(UIColor.systemBackground)
						.edgesIgnoringSafeArea(.all)
					
					VStack() {
						Text("Please enter your comments below.")
							.font(.title)
							.padding()
						
						TextEditor(text: $text)
							.padding()
						
						if let image = grabber.image {
							Image(uiImage: image)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.border(Color.gray, width: 0.5)
						}
						
						Button(action: sendFeedback) {
							Text("Send Feedback")
								.font(.callout)
								.foregroundColor(.white)
						}
						.padding(.horizontal, 16)
						.padding(.vertical, 8)
						.background(
							RoundedRectangle(cornerRadius: 8)
								.fill(Color(UIApplication.shared.currentScene?.windows.first?.tintColor ?? .blue))
						)
					}
				}
				.transition(.move(edge: .bottom))
			}
		}
		.onAppear() { withAnimation() { showing = true } }
		.onDisappear() { ScreenshotListener.instance.reset() }
	}
	
	func sendFeedback() {
		presenter.dismiss(animated: true, completion: nil)
		guard let image = grabber.image else { return }
		
		ImageUploadRequest(image: image, filename: "Screen Shot", comment: text)?.upload()
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
			.onCompletion { result in
				switch result {
				case .failure(let err): ScreenshotToast.presentResults(error: err)
				case .success(_): ScreenshotToast.presentResults(error: nil)
				}
			}
	}
}

