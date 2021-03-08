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

class FeedbackForm {
	static weak var feedbackController: UIViewController?
	static var currentShot: UIImage?
	
	static func present(date: Date?) {
		guard let date = date else { return }
		ScreenshotGrabber.instance.fetchAllScreenshots(since: date)
			.compactMap { $0.last }
			.flatMap { asset in asset.image() }
			.compactMap { $0 }
			.eraseToAnyPublisher()
			.onSuccess { image in
				self.present(image: image)
			}
	}
	
	static func present(image: UIImage) {
		if feedbackController != nil { return }
		guard let window = UIApplication.shared.currentScene?.mainWindow, let root = window.rootViewController else { return }
		Self.currentShot = image
		let imageBinding = Binding<UIImage>(get: { currentShot ?? image }, set: { _ in })
		//feedbackWindow = UIWindow.floating(hosting: FeedbackView(image: imageBinding))
		let controller = UIHostingController(rootView: FeedbackView(presenter: root, image: imageBinding))
		window.rootViewController?.present(controller, animated: true, completion: nil)
		
		feedbackController = controller
	}
}



struct FeedbackView: View {
	let presenter: UIViewController
	@State var text = ""
	@Binding var image: UIImage
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
						
						Image(uiImage: image)
							.resizable()
							.aspectRatio(contentMode: .fit)
						
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
	}
	
	func sendFeedback() {
		presenter.dismiss(animated: true, completion: nil)
		guard let image = FeedbackForm.currentShot else { return }
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

