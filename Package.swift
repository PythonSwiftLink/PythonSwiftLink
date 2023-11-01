// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "PythonSwiftLink",
	platforms: [.macOS(.v11), .iOS(.v13)],
	products: [
		.library(
			name: "PythonSwiftCore",
			targets: ["PythonSwiftCore"]
		),
		.library(
			name: "PySwiftObject",
			targets: ["PySwiftObject"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/PythonSwiftLink/PythonCore", .upToNextMajor(from: .init(311, 0, 0)))
		//.package(url: "https://github.com/PythonSwiftLink/PythonTestSuite", branch: "master"),
	],
	
	targets: [
			.target(
				name: "PythonSwiftCore",
				dependencies: [
					"PythonCore",
					//"PythonTypeAlias"
				],
				resources: [
					
				],
				swiftSettings: [ ]
			),
		
			.target(
				name: "PySwiftObject",
				dependencies: [
					//"PythonCore",
					"PythonSwiftCore",
					//"PythonTypeAlias"
				],
				resources: [
					
				],
				swiftSettings: []
			),

//			.target(
//				name: "PythonCore",
//				dependencies: ["Python"],
//				path: "Sources/PythonCore",
//				linkerSettings: [
//					.linkedLibrary("ncurses"),
//					.linkedLibrary("sqlite3"),
//					.linkedLibrary("z"),
//				]
//			),
//			.target(
//				name: "PythonTypeAlias",
//				dependencies: [
//					"PythonCore",
//				]
//			),
			
//		.binaryTarget(name: "Python", path: "Sources/PythonCore/Python.xcframework"),

	]
)
