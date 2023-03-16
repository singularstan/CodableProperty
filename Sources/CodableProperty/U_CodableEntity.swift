//
//  U_DecodableEntity.swift
//  Utility
//  Created by Stanislav Reznichenko on 10.07.2021.
//

import Foundation

public protocol CodableEntity: Codable
{
    associatedtype KeyPathListType: ICodableKeyPathList where KeyPathListType.Target == Self
    static var codableKeyPaths: KeyPathListType { get }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public extension CodableEntity where Self: DefaultConstructible
{
    init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        try Self.codableKeyPaths.decode(&self, container: container)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        try Self.codableKeyPaths.encode(target: self, container: &container)
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


