//
//  PencilView.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/8/21.
//

import SwiftUI
import PencilKit

struct PencilView: View {
	var backgroundImage: UIImage
	
	@State var inkColor = UIColor.red
	@Binding var disabled: Bool
	

	@Environment(\.undoManager) private var undoManager
	@StateObject var canvas = Canvas()
	
	class Canvas: ObservableObject, Equatable {
		let canvasView = PKCanvasView()
		
		static func ==(lhs: Canvas, rhs: Canvas) -> Bool { lhs.canvasView	== rhs.canvasView }
		
		var image: UIImage? {
			canvasView.drawing.image(from: canvasView.drawing.bounds, scale: UIScreen.main.scale)
		}
		
		func clearImage() {
			canvasView.drawing = PKDrawing()
		}
	}
	
	var body: some View {
		Image(uiImage: backgroundImage).resizable().aspectRatio(contentMode: .fit)
			.overlay(PKCanvas(color: $inkColor, disabled: $disabled, canvasView: canvas.canvasView))
				.overlay(VStack() {
					Spacer()
					HStack() {
						if !disabled {
							Button(action: {undoManager?.undo() }) { Image(.arrow_uturn_left_circle).imageScale(.large).background(Circle().fill(Color(UIColor.systemBackground))).offset(x: -25, y: 20).padding(15) }
							Spacer()
							Button(action: {undoManager?.redo() }) { Image(.arrow_uturn_right_circle).imageScale(.large).background(Circle().fill(Color(UIColor.systemBackground))).offset(x: 25, y: 20).padding(15) }
						}
					}
				})
			.preference(key: PencilViewDrawingKey.self, value: canvas)
	}
}

struct PKCanvas: UIViewRepresentable {
	@Binding var color: UIColor
	@Binding var disabled: Bool
	let canvasView: PKCanvasView
	
	class Coordinator: NSObject, PKCanvasViewDelegate {
		let canvasView: PKCanvasView
		
		init(_ canvas: PKCanvasView) {
			canvasView = canvas
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self.canvasView)
	}
	
	func makeUIView(context: Context) -> PKCanvasView {
		let canvas = context.coordinator.canvasView
		canvas.backgroundColor = .clear
		canvas.drawingPolicy = .anyInput
		canvas.tool = PKInkingTool(.pen, color: color, width: 10)
		
		canvas.delegate = context.coordinator
		canvas.drawing = PKDrawing()
		canvas.tool = PKInkingTool(.pen, color: color, width: 10)

		return canvas
	}
	
	func updateUIView(_ canvasView: PKCanvasView, context: Context) {
		canvasView.isUserInteractionEnabled = !disabled
	}
}

struct PencilView_Previews: PreviewProvider {
	static var previews: some View {
		PencilView(backgroundImage: ScreenshotGrabber.testImage!, disabled: .constant(false))
	}
}

struct PencilViewDrawingKey: PreferenceKey {
		static var defaultValue: PencilView.Canvas?

	static func reduce(value: inout PencilView.Canvas?, nextValue: () -> PencilView.Canvas?) {
				value = nextValue()
		}
}
