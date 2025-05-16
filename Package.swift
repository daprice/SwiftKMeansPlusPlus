// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftKMeansPlusPlus",
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "SwiftKMeansPlusPlus",
			targets: ["SwiftKMeansPlusPlus"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.1.4")),
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftKMeansPlusPlus",
			dependencies: [
				.product(name: "OrderedCollections", package: "swift-collections")
			]
		),
		.testTarget(
			name: "SwiftKMeansPlusPlusTests",
			dependencies: ["SwiftKMeansPlusPlus"]
		),
    ]
)
