//
//  U_KeyedDecodingContainer+Ext.swift
//  Utility
//  Created by Stanislav Reznichenko on 12.07.2021.
//

import Foundation

extension KeyedDecodingContainer where Key == DynamicCodingKey
{
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //all stable traits must use this function
    func decode<T: CodableTraits>(using traits: T.Type,
                                  key: String,
                                  mandatory: Bool,
                                  value: inout T.StorableType) throws {
        guard let coding_key = traits.findCodingKey(name: key, container: self)
        else {
            if mandatory {
                let ctx = DecodingError.Context(codingPath: self.codingPath, debugDescription: "key not found")
                throw DecodingError.keyNotFound(DynamicCodingKey(key: key), ctx)
            } else {
                return
            }
        }
        do {
            if (try? self.decodeNil(forKey: coding_key)) ?? false {
                if traits.assignStorableNil(from: self, dynamicKey: coding_key, mandatory: mandatory, value: &value) {
                    return
                } else {
                    var path = self.codingPath
                    path.append(coding_key)
                    let ctx = DecodingError.Context(codingPath: path,
                                                    debugDescription: "mandatory value not found")
                    throw DecodingError.valueNotFound(T.CodableType.self, ctx)
                }
            }
            let decoded_value = try traits.decode(from: self, coding_key)
            if let stored = traits.createStorable(decoded_value) {
                value = stored
            } else {
                var path = self.codingPath
                path.append(coding_key)
                let ctx = DecodingError.Context(codingPath: path, debugDescription: "can't convert decoded to stored")
                throw DecodingError.dataCorrupted(ctx)
            }
        } catch let error as DecodingError {
            switch error {
                case .typeMismatch, .dataCorrupted:
                    //sysLogPrint("typeMismatch! trying to recover decodable for:\(key)", .service(.info))
                    if let decoded = traits.fallback(from: self, coding_key) {
                        if let stored = traits.createStorable(decoded) {
                            value = stored
                        } else {
                            throw error
                        }
                    } else {
                        throw error
                    }
                default:
                    throw error
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func decode<T: CodableTraits, S: Sequence>(using traits: T.Type,
                                               path: S,
                                               mandatory: Bool,
                                               value: inout T.StorableType) throws
    where S.Element == String {
        do {
            let (nested_cnt, key_name) = try self.nestedContainer(using: traits, path: path)
            try nested_cnt.decode(using: traits, key: key_name, mandatory: mandatory, value: &value)
        } catch DecodingError.keyNotFound(let key, let context) {
            if mandatory {
                throw DecodingError.keyNotFound(key, context)
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func nestedContainer<T: CodableTraits, S: Sequence>(using traits: T.Type, path: S) throws -> (lastContainer:Self, lastKey:String)
    where S.Element == String {
        var iterator = path.makeIterator()
        var iterator2 = path.makeIterator()
        _ = iterator2.next()
        var nested_cnt = self
        while let key_name = iterator.next() {
            guard let coding_key = traits.findCodingKey(name: key_name, container: nested_cnt)
            else {
                var failed_path = self.codingPath
                failed_path.append(contentsOf: path.map({
                    DynamicCodingKey(key: $0)
                }))
                let ctx = DecodingError.Context(codingPath: failed_path,
                                                debugDescription: "failed to iterate path sequence. \(key_name) not found")
                throw DecodingError.keyNotFound(DynamicCodingKey(key: key_name), ctx)
            }
            if iterator2.next() != nil {
                do {
                    nested_cnt = try nested_cnt.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: coding_key)
                } catch DecodingError.typeMismatch {
                    var failed_path = self.codingPath
                    failed_path.append(contentsOf: path.map({
                        DynamicCodingKey(key: $0)
                    }))
                    let ctx = DecodingError.Context(codingPath: failed_path,
                                                    debugDescription: "failed to iterate path sequence. \(coding_key.stringValue) does not contain dictionary")
                    throw DecodingError.keyNotFound(DynamicCodingKey(key: iterator.next()!), ctx)
                }
            } else {
                return (nested_cnt, key_name)
            }
        }
        let ctx = DecodingError.Context(codingPath: nested_cnt.codingPath, debugDescription: "path is empty")
        throw DecodingError.keyNotFound(DynamicCodingKey(key: "<empty path>"), ctx)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
