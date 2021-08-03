import Foundation
import NIOLIFX

/// A codable represenation of NIOLIFXs `Device`. It contains codable twins of the basic information.
public struct CodableDevice: Codable {
    let address: UInt64
    let location: CodableLocation
    let group: CodableGroup
    
    init(_ device: Device) throws {
        self.address = device.address
        if let location = device.location.wrappedValue,
           let group = device.group.wrappedValue {
            self.location = CodableLocation(from: location)
            self.group = CodableGroup(from: group)
        } else {
            throw DiscoveryError.valuesNotFound
        }
    }
}

enum DiscoveryError: Error {
    case valuesNotFound
}
