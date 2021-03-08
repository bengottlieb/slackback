//
//  ScreenshotToast.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/7/21.
//

import UIKit
import SwiftUI
import Combine

class ScreenshotToast {
	static var toastWindow: UIWindow?
	
	static func promptForComment(duration: TimeInterval = 7, tapped: @escaping (Bool) -> Void) {
		let view = ToastView(duration: duration, tapped: tapped) { CommentPrompt() }
		toastWindow = UIWindow.floating(hosting: view)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + duration + 2) {
			toastWindow?.isHidden = true
			toastWindow = nil
		}
	}
	
	static func presentResults(error: Error?, duration: TimeInterval = 5) {
		let view = ToastView(duration: 2, tapped: { _ in }) { UploadResultsView(error: error) }
		toastWindow = UIWindow.floating(hosting: view)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + duration + 2) {
			toastWindow?.isHidden = true
			toastWindow = nil
		}
	}
}

struct UploadResultsView: View {
	let error: Error?
	
	var body: some View {
		VStack(spacing: 3) {
			if let err = error {
				Text("Upload Failed").font(.body)
				Text(err.localizedDescription).font(.caption)
			} else {
				Text("Feedback Submitted!")
			}
		}
	}
}

struct CommentPrompt: View {
	var body: some View {
		VStack(spacing: 3) {
			Text("Screenshot Taken").font(.body)
			Text("Tap to Edit and Send Feedback").font(.caption)
		}
	}
}

struct ToastView<Content: View>: View {
	@State var showing = false
	@State var yOffset: CGFloat = 0.0
	var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let contentView: Content
	
	init(duration: TimeInterval, tapped: @escaping (Bool) -> Void, content: () -> Content) {
		contentView = content()
		timer = Timer.publish(every: duration, on: .main, in: .common).autoconnect()
		self.tapped = tapped
	}
	var tapped: (Bool) -> Void
	
	var body: some View {
		VStack() {
			if showing {
				contentView
					.padding(.horizontal, 8)
					.padding(8)
					.background(RoundedRectangle(cornerRadius: 8)
												.fill(Color(UIColor.systemBackground)))
					.overlay(RoundedRectangle(cornerRadius: 8)
										.stroke(Color(UIColor.label), lineWidth: 0.5))
					.foregroundColor(Color(UIColor.label).opacity(0.8))
					.gesture(dragGesture)
					.onTapGesture {
						tapped(false)
						withAnimation() { showing = false }
					}
					.transition(.move(edge: .top))
					.offset(y: yOffset)
				Spacer()
			}
		}
		.onAppear() { withAnimation() { showing = true } }
		.onReceive(timer) { _ in withAnimation() { showing = false } }
	}
	
	var dragGesture: some Gesture {
		DragGesture()
			.onChanged { info in
				yOffset = info.translation.height
			}
			.onEnded { info in
				if info.translation.height < -5 {
					withAnimation(.linear(duration: 0.1)) { showing = false }
					tapped(true)
				} else {
					withAnimation() { yOffset = 0 }
				}
			}
	}
}
