//
//  FeedbackView.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/8/21.
//

import SwiftUI

struct FeedbackView: View {
	let presenter: UIViewController
	@ObservedObject var grabber: ScreenshotGrabber
	@State var text = ""
	@State var canvas: PencilView.Canvas?
	
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
					if let image = grabber.image {
						Spacer()
						PencilView(backgroundImage: image, disabled: $isEditing.inverted)
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
		.onPreferenceChange(PencilViewDrawingKey.self) { newCanvas in
			canvas = newCanvas
		}
	}
	
	var editButtonOverlay: some View {
		ZStack(alignment: .topTrailing) {
			Color.clear
			
			Button(action: {
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
		guard var image = grabber.image else { return }
		
		if let drawing = canvas?.image {
			image = image.overlaying(drawing)
		}

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
		FeedbackView(presenter: UIViewController(), grabber: ScreenshotGrabber(image: ScreenshotGrabber.testImage!))
	}
}
