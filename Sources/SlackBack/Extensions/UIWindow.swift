//
//  UIWindow.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/7/21.
//

import UIKit
import SwiftUI

extension UIWindow {
	static func floating<AView: View>(hosting content: AView) -> UIWindow? {
		guard let scene = UIApplication.shared.currentScene else { return nil }
		let window = UIWindow(windowScene: scene)
		window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 90)
		window.rootViewController = UIHostingController(rootView: content)
		window.windowLevel = UIWindow.Level.statusBar + 1
		window.rootViewController?.view?.backgroundColor = UIColor.clear
	
		window.makeKeyAndVisible()

		return window
	}
}
