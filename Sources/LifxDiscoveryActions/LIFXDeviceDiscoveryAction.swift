//
//  File.swift
//  File
//
//  Created by Felix Desiderato on 14/08/2021.
//

import Foundation
import DeviceDiscovery
import NIO
import Logging
import LifxDiscoveryCommon

public extension ConfigurationProperty {
    /// A `ConfigurationProperty` for the deployment directory.
    static var deploymentDirectory = ConfigurationProperty("key_deploymentDirectory")
}

public struct LIFXDeviceDiscoveryAction: PostDiscoveryAction {
    @Configuration(.username)
    public var username: String

    @Configuration(.deploymentDirectory)
    public var deploymentDir: URL
    
    public static var identifier: ActionIdentifier {
        ActionIdentifier("LIFX")
    }

    private var tmpLifxDir: URL {
        deploymentDir.appendingPathComponent("tmp_lifx", isDirectory: true)
    }
    
    private var resourceURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources", isDirectory: true)
    }

    private let setupScriptFilename = "setup-script"
    private let resultsFilename = "lifx_devices"

    public func run(_ device: Device, on eventLoopGroup: EventLoopGroup, client: SSHClient?) throws -> EventLoopFuture<Int> {
        let eventLoop = eventLoopGroup.next()
        let logger = Logger(label: "de.swift-nio-lifx-impl.post-action")
        guard let sshClient = client else {
            return eventLoop.makeFailedFuture(
                DiscoveryError(
                    "Could not find ssh client. Check if you provided the necessary credentials in the config."
                )
            )
        }
        // Need to manually bootstrap the client, since we dont want to pass open connections around
        try sshClient.bootstrap()

        // Check if the setup script is in the res dir
        let scriptFileUrl = resourceURL.appendingPathComponent(setupScriptFilename)
        guard FileManager.default.fileExists(atPath: scriptFileUrl.path) else {
            throw DiscoveryError("Unable to find '\(setupScriptFilename)' resource in bundle")
        }

        // Create tmp sub dir in deployment dir for results
        try sshClient.fileManager.createDir(on: tmpLifxDir, permissions: 777)

        try copyResources(origin: scriptFileUrl.path, destination: rsyncHostname(device, path: tmpLifxDir.path))

        logger.info("executing script")
        try runOnRemote(
            args: ["bash \(tmpLifxDir.appendingPathComponent(setupScriptFilename)) \(tmpLifxDir.path)"],
            workingDirectory: tmpLifxDir,
            remoteDevice: device
        )

        logger.info("copying json back")
        let remoteResultsPath = tmpLifxDir.appendingPathComponent(resultsFilename)
        
        try copyResources(
            origin: rsyncHostname(device, path: remoteResultsPath.path),
            destination: resourceURL.path
        )

        let resultsPath = resourceURL.appendingPathComponent(resultsFilename).path
        guard let data = FileManager.default.contents(atPath: resultsPath) else {
            throw DiscoveryError("Could not find results file at \(scriptFileUrl)")
        }
        let foundDevices = try JSONDecoder().decode([CodableDevice].self, from: data)

        // Delete resource file local and remote dir after we read its data
        try FileManager.default.removeItem(atPath: resultsPath)
        logger.info("removed search result")
        sshClient.fileManager.remove(at: tmpLifxDir, isDir: true)
        logger.info("removed tmp search dir")

        return eventLoop.makeSucceededFuture(foundDevices.count)
    }

    public init() {}
}

// MARK: - Util methods
extension LIFXDeviceDiscoveryAction {
    func rsyncHostname(_ device: Device, path: String) -> String {
        guard let ipAddress = device.ipv4Address else {
            fatalError("Unable to find ip address for device \(device)")
        }
        "\(device.username)@\(ipAddress):\(path)"
    }
    
    func copyResources(origin: String, destination: String) throws {
        let task = try Task(
            "rsync",
            arguments: [
                "-avz",
                "-e",
                "'ssh'",
                origin,
                destination
            ]
        )
        try task.launch()
    }
    
    func runOnRemote(args: [String], workingDirectory: URL?, remoteDevice: Device) throws {
        let task = try Task(
            "ssh",
            arguments: args,
            workingDirectory: workingDirectory,
            remoteDevice: remoteDevice
        )
        try task.launch()
    }
}
