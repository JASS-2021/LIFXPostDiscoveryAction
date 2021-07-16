import Foundation
import NIOLIFX

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
