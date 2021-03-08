//
//  ScreenshotGrabber.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/7/21.
//

import UIKit
import MediaPlayer
import Photos
import Combine

/*

NSMutableArray *mArray = [NSMutableArray array];

// fetch all image assets
PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
PHFetchResult *result = [PHAsset fetchAssetsWithOptions:fetchOptions];
[result enumerateObjectsUsingBlock:^(PHAsset * __nonnull asset, NSUInteger idx, BOOL * __nonnull stop) {
		// filter with subtype for screenshot
		if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoScreenshot) {
				[mArray addObject:asset];
		}
}];

// ex. retrieve image data
PHAsset *asset = result.firstObject;
PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
options.synchronous = YES;
[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * __nullable imageData, NSString * __nullable dataUTI, UIImageOrientation orientation, NSDictionary * __nullable info) {
		UIImage *image = [UIImage imageWithData:imageData];
		NSLog(@"%@", image);
		// stop at this point with breakpoint, you can see quicklook
}];

*/

class ScreenshotGrabber: NSObject, PHPhotoLibraryChangeObserver {
	static let instance = ScreenshotGrabber()
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		print(changeInstance)
	}
	
	func setup() {
		
	}
	
	func fetchAllScreenshots(since date: Date) -> AnyPublisher<[PHAsset], Never> {
		Future<[PHAsset], Never> { promise in
			let options = PHFetchOptions()
			
			print("Checking for \(date), Now: \(Date())")
			options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
			let result = PHAsset.fetchAssets(with: options)
			var snapshots: [PHAsset] = []
			let limit = date.addingTimeInterval(-1)
			
			result.enumerateObjects { asset, index, stop in
				if !asset.mediaSubtypes.contains(.photoScreenshot) { return }
				if let creationDate = asset.creationDate, creationDate >= limit { snapshots.append(asset) }
			}
			snapshots.sort { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }
		
			promise(.success(snapshots))
		}.eraseToAnyPublisher()
	}
}
