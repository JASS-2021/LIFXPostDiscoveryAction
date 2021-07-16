import Foundation
import NIOLIFX
import NIO
import Logging

/// A codable represenation of NIOLIFXs `Device`. It contains codable twins of the basic information.
public struct CodableDevice: Codable {
    let address: UInt64
    let location: CodableLocation
    let group: CodableGroup
    
    init(_ device: Device) {
        self.address = device.address
        self.location = CodableLocation(from: device.location.wrappedValue!)
        self.group = CodableGroup(from: device.group.wrappedValue!)
    }
}

/// An Implementation of NIOLIFX that persists the basic information of the found `Device`s into a JSON.
class NIOLIFXImpl {
    /// The filename of the .json file.
    private static let fileName: String = "lifx_devices"
    /// A local logger instance.
    private static let logger = Logger(label: "swift.nio.lifx")

    /// Runs the `NIOLIFX` device discovery and persists found devices.
    static func run() throws {
        let networkInterface = try findNetworkInterfaces()
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let deviceManager = try LIFXDeviceManager(using: networkInterface, on: group, logLevel: .info)
        try deviceManager.discoverDevices().wait()
        
        let codableDevices = deviceManager.devices.map {
            CodableDevice($0)
        }
        let filePath = Bundle.main.bundleURL.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(codableDevices)
        try data.write(to: filePath)
        logger.info("Wrote results to file: \(filePath)")
    }
    /// Returns the ethernet/wifi network interface of the executing device.
    private static func findNetworkInterfaces() throws -> NIONetworkDevice {
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

try NIOLIFXImpl.run()
