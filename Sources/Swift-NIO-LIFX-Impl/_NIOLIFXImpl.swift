import Foundation
import NIOLIFX
import NIO
import Logging

/// An Implementation of NIOLIFX that persists the basic information of the found `Device`s into a JSON.
struct _NIOLIFXImpl {
    /// The filename of the .json file.
    var fileName: String
    /// The path the file is saved at.
    var filePath: URL
    /// A local logger instance.
    private let logger = Logger(label: "swift.nio.lifx")

    /// Runs the `NIOLIFX` device discovery and persists found devices.
    func run() throws {
        let networkInterface = try findNetworkInterfaces()
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let deviceManager = try LIFXDeviceManager(using: networkInterface, on: group, logLevel: .info)
        try deviceManager.discoverDevices().wait()
        
        let codableDevices = deviceManager.devices.map {
            CodableDevice($0)
        }
        let filePath = filePath.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(codableDevices)
        try data.write(to: filePath)
        logger.info("Wrote results to file: \(filePath)")
    }
    /// Returns the ethernet/wifi network interface of the executing device.
    private func findNetworkInterfaces() throws -> NIONetworkDevice {
        let interfaces = try System.enumerateDevices()
        for interface in interfaces {
            if case .v4 = interface.address, interface.name == "en0" {
                return interface
            }
        }
        fatalError(
            """
            Could not find a suitable network interface. Please check your network!
            """
        )
    }
    
}
