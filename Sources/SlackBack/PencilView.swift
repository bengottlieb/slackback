//
//  PencilView.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/8/21.
//

import SwiftUI
import PencilKit

struct PencilView: View {
	@Environment(\.undoManager) private var undoManager

	var backgroundImage: UIImage
	
	@State var inkColor = UIColor.red
	@State var cleared = false
	@State var canvas: PKCanvasView?
	
	func drawingImage() -> UIImage? {
		guard let drawing = canvas?.drawing else { return nil }
		return drawing.image(from: drawing.bounds, scale: UIScreen.main.scale)
	}
	
	func clearImage() {
		canvas?.drawing = PKDrawing()
	}
	
	var body: some View {
		Image(uiImage: backgroundImage).resizable().aspectRatio(contentMode: .fit)
				.overlay(PKCanvas(color: $inkColor, canvas: $canvas))
				.overlay(VStack() {
					Spacer()
					HStack() {
						Button(action: {undoManager?.undo() }) { Image(.arrow_uturn_left_circle).background(Circle().fill(Color(UIColor.systemBackground))).offset(x: -25, y: 20).padding(15) }
						Spacer()
						Button(action: {undoManager?.redo() }) { Image(.arrow_uturn_right_circle).background(Circle().fill(Color(UIColor.systemBackground))).offset(x: 25, y: 20).padding(15) }
					}
				})
	}
}

struct PKCanvas: UIViewRepresentable {
	@Binding var color: UIColor
	@Binding var canvas: PKCanvasView?
	
	class Coordinator: NSObject, PKCanvasViewDelegate {
		var pkCanvas: PKCanvas
		
		init(_ pkCanvas: PKCanvas) {
			self.pkCanvas = pkCanvas
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIView(context: Context) -> PKCanvasView {
		let canvas = PKCanvasView()
		canvas.backgroundColor = .clear
		canvas.drawingPolicy = .anyInput
		canvas.tool = PKInkingTool(.pen, color: color, width: 10)
		
		canvas.delegate = context.coordinator
		canvas.drawing = PKDrawing()
		canvas.tool = PKInkingTool(.pen, color: color, width: 10)

		updateCanvas(with: canvas)
		return canvas
	}
	
	func updateUIView(_ canvasView: PKCanvasView, context: Context) {
		updateCanvas(with: canvasView)
	}
	
	func updateCanvas(with canvasView: PKCanvasView) {
		if canvas == canvasView { return }
		DispatchQueue.main.async {
			canvas = canvasView
		}
	}
}

struct PencilView_Previews: PreviewProvider {
	static var previews: some View {
		PencilView(backgroundImage: ScreenshotGrabber.testImage!)
	}
}
