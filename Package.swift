// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlackBack",
     platforms: [
              .iOS(.v14),
         ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SlackBack",
            targets: ["SlackBack"]),
    ],
    dependencies: [
			.package(url: "https://github.com/bengottlieb/Suite.git", from: "0.10.38"),
			.package(url: "https://github.com/bengottlieb/Marcel.git", from: "1.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "SlackBack", dependencies: ["Suite", "Marcel"]),
    ]
)
