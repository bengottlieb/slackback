//
//  PHAsset.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/7/21.
//

import Photos
import Combine
import UIKit

extension PHAsset {
	func image(size: CGSize = UIScreen.main.bounds.size) -> AnyPublisher<UIImage?, Never> {
		Future() { promise in
			let imageManager = PHCachingImageManager()
			imageManager.stopCachingImagesForAllAssets()
			imageManager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: nil) { image, error in
				promise(.success(image))
			}
		}
		.eraseToAnyPublisher()
	}
	
	func editedImage() -> AnyPublisher<UIImage?, Never> {
		Future() { promise in
			let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
			options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in return true }
			
			self.requestContentEditingInput(with: options) { contentEditingInput, info in
				guard let url = contentEditingInput?.fullSizeImageURL else {
					promise(.success(nil))
					return
				}
				
				let image = UIImage(contentsOf: url)
				promise(.success(image))
			}
		}
		.eraseToAnyPublisher()
	}
}
