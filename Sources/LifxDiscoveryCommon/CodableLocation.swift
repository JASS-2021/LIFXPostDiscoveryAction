//
// This source file is part of the JASS open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the JASS project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import NIOLIFX
import NIO

/// A codable twin of NIOLIFXs `Device.Location`.
public struct CodableLocation: Codable {
    public let id: String
    public let label: String
    public let updatedAt: UInt64
    
    enum CodingKeys: String, CodingKey {
        case id, label, updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.label = try values.decode(String.self, forKey: .label)
        self.updatedAt = try values.decode(UInt64.self, forKey: .updatedAt)
    }
    
    public init(from location: Device.Location) {
        self.id = location.description.replacingOccurrences(of: "\0", with: "")
        self.label = location.label.replacingOccurrences(of: "\0", with: "")
        self.updatedAt = location.updatedAt
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(label, forKey: .label)
        try values.encode(updatedAt, forKey: .updatedAt)
    }
}
