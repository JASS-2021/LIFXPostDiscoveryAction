import Foundation
import NIOLIFX
import NIO

/// A codable twin of NIOLIFXs `Device.Group`.
public struct CodableGroup: Codable {
    public let id: String
    public let label: String
    public let updatedAt: UInt64
    
    enum CodingKeys: String, CodingKey {
        case id, label, updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let ids = try values.decode([UInt8].self, forKey: .id)
        self.id = ids.reduce(into: "", { result, value in
            result.append(String(value))
        })
        self.label = try values.decode(String.self, forKey: .label)
        self.updatedAt = try values.decode(UInt64.self, forKey: .updatedAt)
    }
    
    public init(from group: Device.Group) {
        self.id = group.description.replacingOccurrences(of: "\0", with: "")
        self.label = group.label.replacingOccurrences(of: "\0", with: "")
        self.updatedAt = group.updatedAt
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(label, forKey: .label)
        try values.encode(updatedAt, forKey: .updatedAt)
    }
}
