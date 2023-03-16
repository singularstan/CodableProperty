//
//  U_KeyedEncodingContainer+Ext.swift
//  Utility
//  Created by Stanislav Reznichenko on 16.07.2021.
//

import Foundation

extension KeyedEncodingContainer where Key == DynamicCodingKey
{
    mutating func encode<V, T: CodableTraits>(storedValue: V, using traits: T.Type, keyName: String) throws
    where V == T.StorableType {
        let key = DynamicCodingKey(key: keyName)
        if let codable = traits.createDecodable(storedValue) {
            try self.encode(codable, forKey: key)
        } else {
            var coding_path = self.codingPath
            coding_path.append(key)
            let ctx = EncodingError.Context(codingPath: coding_path, debugDescription: "can't convert stored to encoded")
            throw EncodingError.invalidValue(storedValue, ctx)
        }
    }
}
