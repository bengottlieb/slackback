//
//  FeedbackView.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/8/21.
//

import SwiftUI

struct FeedbackView: View {
	let presenter: UIViewController
	@State var image: UIImage?
	@State var text = ""
	
	@State var isEditing = false
	
	var body: some View {
		Group() {
			ZStack() {
				Color(UIColor.systemBackground)
					.edgesIgnoringSafeArea(.all)
				
				VStack() {
					if isEditing {
						
						
					} else {
						Text("Enter your comments below.")
							.multilineTextAlignment(.center)
							.font(.title)
							.padding()
						
						TextEditor(text: $text)
							.padding()
						
					}
					if let image = image {
						Spacer()
						canvas(for: image)
							.border(Color.gray, width: 0.5)
							.overlay(editButtonOverlay)
							.padding(isEditing ? 16 : 0)
					}
					
					Spacer()
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
		.onDisappear() { ScreenshotListener.instance.reset() }
	}
	
	func canvas(for image: UIImage) -> PencilView {
		PencilView(backgroundImage: image)
	}

	var editButtonOverlay: some View {
		ZStack(alignment: .topTrailing) {
			Color.clear
			
			Button(action: {
				if let image = image, let drawing = canvas(for: image).drawingImage() {
					self.image = image.overlaying(drawing)
					self.image = image
					canvas(for: image).clearImage()
				}
				withAnimation() { isEditing.toggle() }
			}) {
				Image(isEditing ? .x_circle : .pencil_circle)
					.imageScale(.large)
					.background(Circle().fill(Color(UIColor.systemBackground)))
					.padding(5)
			}
			.offset(x: 15, y: -15)
		}
	}
	
	func sendFeedback() {
		presenter.dismiss(animated: true, completion: nil)
		guard let image = image else { return }
		
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


struct FeedbackView_Previews: PreviewProvider {
	static var previews: some View {
		FeedbackView(presenter: UIViewController(), image: ScreenshotGrabber.testImage!)
	}
}
