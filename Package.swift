// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "HTTPClient",
    platforms: [.macOS(.v10_12),
                .iOS(.v10),
                .tvOS(.v10),
                .watchOS(.v3)],
    products: [
        .library(name: "HTTPClient", targets: ["HTTPClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: .init(5, 6, 1))),
    ],
    targets: [
        .target(name: "HTTPClient", dependencies: [.product(name: "Alamofire", package: "Alamofire")], path: "Source")
    ]
)
