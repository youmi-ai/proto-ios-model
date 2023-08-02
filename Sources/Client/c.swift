import ArgumentParser
import GRPC
import YoumiRPCModelLongevityExt
import NIOCore
import NIOPosix
import NIOHPACK
import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
@main
struct HelloWorld: AsyncParsableCommand {
  @Option(help: "The port to connect to")
  var port: Int = 443

  @Argument(help: "The name to greet")
  var name: String?

  func run() async throws {
    // Setup an `EventLoopGroup` for the connection to run on.
    //
    // See: https://github.com/apple/swift-nio#eventloops-and-eventloopgroups
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

    // Make sure the group is shutdown when we're done with it.
    defer {
      try! group.syncShutdownGracefully()
    }

    let channel = try GRPCChannelPool.with(
      target: .host("grpc-changshou.youmibots.com", port: self.port),
      transportSecurity: .tls(GRPCTLSConfiguration.makeClientConfigurationBackedByNIOSSL()),
      eventLoopGroup: group
    )

    // Close the connection when we're done with it.
    defer {
      try! channel.close().wait()
    }

    // Provide the connection to the generated client.
    let client = Longevityext_LongevityExtAsyncClient(channel: channel)            

    // Form the request with the name, if one was provided.
    let request = Longevityext_StoreHealthDataRequest.with {
      $0.uid = "llll"
      $0.version = "test1"
      $0.data = "{}"
    }

    do {
      if let authToken = ProcessInfo.processInfo.environment["GRPC_SERVER_TOKEN"] {
        print("call use token: \(authToken)")
        let headers: HPACKHeaders = ["authorization": "Bearer \(authToken)"]
        let callOptions = CallOptions(customMetadata: headers, timeLimit: TimeLimit.timeout(.seconds(30)))
        let resp = try await client.storeAppleWatchHealthData(request, callOptions: callOptions)
        print("client received: \(resp.status.code)")
      }

    } catch {
      print("client failed: \(error)")
    }
  }
}
