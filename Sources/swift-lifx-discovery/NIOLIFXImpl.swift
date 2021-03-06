//
// This source file is part of the JASS open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the JASS project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser
import Logging
import NIOLIFX
import NIO
import LifxDiscoveryCommon

@main
struct NIOLIFXImpl: ParsableCommand {
    @Argument(help: "The directory the file should be saved at")
    var filePath: String = CommandLine.arguments[0]
    
    @Option(help: "The file name")
    var fileName: String = "lifx_devices"
    
    @Option(help: "On this network interface the discovery is run.")
    var networkInterface: String = "wlan0"
    
    @Flag(help: "Write only the number of found devices to disk")
    var numberOnly = false

    /// Runs the `NIOLIFX` device discovery and persists found devices.
    func run() throws {
        let logger = Logger(label: "swift.nio.lifx")
        let fileUrl = URL(fileURLWithPath: filePath)
        let networkInterface = try findNetworkInterfaces()
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let deviceManager = try LIFXDeviceManager(using: networkInterface, on: group, logLevel: .info)
        try deviceManager.discoverDevices().wait()
        
        let codableDevices = try deviceManager.devices.map {
            try CodableDevice($0)
        }
        let fileLocation = fileUrl.appendingPathComponent(fileName)
        let data: Data
        if numberOnly {
            data = try JSONEncoder().encode(codableDevices.count)
        } else {
            data = try JSONEncoder().encode(codableDevices)
        }
        try data.write(to: fileLocation)
        logger.info("Wrote results to file: \(fileLocation.path)")
    }
    
    /// Returns the ethernet/wifi network interface of the executing device.
    private func findNetworkInterfaces() throws -> NIONetworkDevice {
        let interfaces = try System.enumerateDevices()
        for interface in interfaces {
            if case .v4 = interface.address, interface.name == networkInterface {
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
