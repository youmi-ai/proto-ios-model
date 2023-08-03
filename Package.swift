// swift-tools-version:5.8

import PackageDescription

extension Target.Dependency {
    // Target dependencies; external
    static let grpc: Self = .product(name: "GRPC", package: "grpc-swift")
    static let argumentParser: Self = .product(
        name: "ArgumentParser",
        package: "swift-argument-parser"
    )
    static let nio: Self = .product(name: "NIO", package: "swift-nio")
    static let nioCore: Self = .product(name: "NIOCore", package: "swift-nio")
    static let nioPosix: Self = .product(name: "NIOPosix", package: "swift-nio")
    static let protobuf: Self = .product(name: "SwiftProtobuf", package: "swift-protobuf")

    // Target dependencies; internal
    static let youmiRPCModelLongevityExt: Self = .target(name: "YoumiRPCModelLongevityExt")
    static let youmiRPCModelSys: Self = .target(name: "YoumiRPCModelSys")
}

extension Product {
  static let youmiRPCModel: Product = .library(
    name: "youmiRPCModel",
    targets: ["YoumiRPCModelLongevityExt", "YoumiRPCModelSys"]
  )
}

let package = Package(
  name: "youmi-grpc-client",
  products: [
    .youmiRPCModel,
  ],

  dependencies: [
    .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.18.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.27.0"),
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.20.2"),
    .package(
        url: "https://github.com/apple/swift-argument-parser.git",
        // Version is higher than in other Package@swift manifests: 1.1.0 raised the minimum Swift
        // version and indluded async support.
        from: "1.1.1"
    ),
  ],
  targets: [
    .target(
        name: "YoumiRPCModelSys",
        dependencies: [
        .grpc,
        .nio,
        .protobuf,
        ],
        sources: ["Sources/Model/sys/status.pb.swift"]
    ),     
    .target(
        name: "YoumiRPCModelLongevityExt",
        dependencies: [
        .grpc,
        .nio,
        .protobuf,
        .youmiRPCModelSys,
        ],
        path: "Sources/Model/longevityext"
    ),
    .executableTarget(
        name: "YoumiRPCallClient",
        dependencies: [
        .grpc,
        .youmiRPCModelLongevityExt,
        .youmiRPCModelSys,
        .nioCore,
        .nioPosix,
        .argumentParser,
        ],
        path: "Sources/Client"
    ),
  ]
)
