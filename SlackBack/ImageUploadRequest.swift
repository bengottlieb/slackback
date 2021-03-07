//
//  ImageUploadRequest.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/6/21.
//

import Foundation
import Combine
import Marcel

// curl -F file=@shot.png -F "initial_comment=Screen shot" -F channels=test -H "Authorization: Bearer xoxb-XXXXXXXXXXXXXXXX" https://slack.com/api/files.upload

public struct ImageUploadRequest {
	public static var authToken: String?
	public static var session = URLSession.shared
	
	public enum UploadError: Error, LocalizedError { case noToken, failedToConstructURL, filePayloadNotFound, slackError(String)
		public var errorDescription: String? {
			switch self {
			case .noToken: return "Missing token"
			case .failedToConstructURL: return "Unable to build a URL"
			case .filePayloadNotFound: return "Upload file not found"
			case .slackError(let msg): return msg
			}
		}
	}
	
	static let endpoint = "https://slack.com/api/files.upload"
	
	let file: URL
	let channel: String
	let comment: String
	
	public init?(file: URL, channel: String, comment: String) {
		self.file = file
		self.channel = channel
		self.comment = comment
		
		var isDirectory: ObjCBool = false
		if !file.isFileURL || !FileManager.default.fileExists(atPath: file.path, isDirectory: &isDirectory) || isDirectory.boolValue { return nil }
	}
	
	public func upload() -> AnyPublisher<UploadedImage, Error> {
		guard let token = Self.authToken else { return Fail(outputType: UploadedImage.self, failure: UploadError.noToken).eraseToAnyPublisher() }
		guard let data = try? Data(contentsOf: file) else { return Fail(outputType: UploadedImage.self, failure: UploadError.filePayloadNotFound).eraseToAnyPublisher() }
		let url = URL(string: Self.endpoint)!
		var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
		
		components.queryItems = []
		components.queryItems?.append(URLQueryItem(name: "channels", value: channel))
		components.queryItems?.append(URLQueryItem(name: "initial_comment", value: comment))

		guard let finalURL = components.url else { return Fail(outputType: UploadedImage.self, failure: UploadError.failedToConstructURL).eraseToAnyPublisher() }
		var request = URLRequest(url: finalURL)
		let mime = MIMEBundle(content: [
			MIMEBundle.Chunk(content: data, name: "file", filename: file.lastPathComponent, contentType: "image/jpeg"),
		])
		
		request.addValue("Bearer " + token.trimmingCharacters(in: .whitespacesAndNewlines), forHTTPHeaderField: "Authorization")
		request.addValue("multipart/form-data; boundary=\(mime.boundary)", forHTTPHeaderField: "Content-Type")
		request.httpBody = mime.data
		request.httpMethod = "POST"
		
		return Self.session.dataTaskPublisher(for: request)
			.map { data, response in return data }
			.decode(type: UploadedImage.self, decoder: JSONDecoder())
			.tryMap { image in
				if let err = image.error { throw UploadError.slackError(err) }
				return image
			}
			.eraseToAnyPublisher()
	}
    
	public struct UploadedImage: Codable {
		let ok: Bool
		let error: String?
	}
}


/* results
 
 {
     "ok": true,
     "file": {
         "id": "F0TD00400",
         "created": 1532293501,
         "timestamp": 1532293501,
         "name": "dramacat.gif",
         "title": "dramacat",
         "mimetype": "image/jpeg",
         "filetype": "gif",
         "pretty_type": "JPEG",
         "user": "U0L4B9NSU",
         "editable": false,
         "size": 43518,
         "mode": "hosted",
         "is_external": false,
         "external_type": "",
         "is_public": false,
         "public_url_shared": false,
         "display_as_bot": false,
         "username": "",
         "url_private": "https://.../dramacat.gif",
         "url_private_download": "https://.../dramacat.gif",
         "thumb_64": "https://.../dramacat_64.gif",
         "thumb_80": "https://.../dramacat_80.gif",
         "thumb_360": "https://.../dramacat_360.gif",
         "thumb_360_w": 360,
         "thumb_360_h": 250,
         "thumb_480": "https://.../dramacat_480.gif",
         "thumb_480_w": 480,
         "thumb_480_h": 334,
         "thumb_160": "https://.../dramacat_160.gif",
         "image_exif_rotation": 1,
         "original_w": 526,
         "original_h": 366,
         "permalink": "https://.../dramacat.gif",
         "permalink_public": "https://.../More-Path-Components",
         "comments_count": 0,
         "is_starred": false,
         "shares": {
             "private": {
                 "D0L4B9P0Q": [
                     {
                         "reply_users": [],
                         "reply_users_count": 0,
                         "reply_count": 0,
                         "ts": "1532293503.000001"
                     }
                 ]
             }
         },
         "channels": [],
         "groups": [],
         "ims": [
             "D0L4B9P0Q"
         ],
         "has_rich_preview": false
     }
 }
 */
