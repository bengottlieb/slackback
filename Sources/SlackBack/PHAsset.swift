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
			imageManager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: nil) { image, error in
				promise(.success(image))
			}
		}
		.eraseToAnyPublisher()
	}
}
