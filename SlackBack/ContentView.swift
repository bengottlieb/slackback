//
//  ContentView.swift
//  SlackBack
//
//  Created by Ben Gottlieb on 3/6/21.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack() {
			Text("Hello, world!")
				.padding()
			
			Button("Button goes here") {
				print("button")
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
