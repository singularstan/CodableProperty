//
//  U_DecodableTraits.swift
//  Utility
//  Created by Stanislav Reznichenko on 15.07.2021.
//

import Foundation
#if os(iOS)
import UIKit
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - traits protocol
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public protocol CodableTraits
{
    associatedtype StorableType
    associatedtype CodableType: Codable
    
    typealias DecodeContainer = KeyedDecodingContainer<DynamicCodingKey>
    
    static var pathSeparator: String { get }
    
    static func findCodingKey(name: String, container: DecodeContainer) -> DynamicCodingKey?
    //key exists for sure
    static func decode(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) throws -> CodableType
    //key exists for sure
    static func assignStorableNil(from container: DecodeContainer,
                                  dynamicKey: DynamicCodingKey,
                                  mandatory: Bool,
                                  value: inout StorableType) -> Bool
    //key exists for sure
    static func fallback(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) -> CodableType?
    static func createStorable(_ codable: CodableType) -> StorableType?
    static func createDecodable(_ storable: StorableType) -> CodableType?
}

public extension CodableTraits
{
    static var pathSeparator: String {
        return "."
    }
    
    static func decode(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) throws -> CodableType {
        return try container.decode(CodableType.self, forKey: dynamicKey)
    }
    
    static func assignStorableNil(from container: DecodeContainer,
                                  dynamicKey: DynamicCodingKey,
                                  mandatory: Bool,
                                  value: inout StorableType) -> Bool {
        return !mandatory
    }
    
    static func fallback(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) -> CodableType? {
        return nil
    }
    
    static func findCodingKey(name: String, container: DecodeContainer) -> DynamicCodingKey? {
        for stored_key in container.allKeys {
            if stored_key.stringValue.compare(name, options: .caseInsensitive) == .orderedSame {
                return stored_key
            }
        }
        return nil
    }
}

public extension CodableTraits where StorableType == CodableType
{
    static func createStorable(_ decoded: CodableType) -> StorableType? {
        decoded
    }
    
    static func createDecodable(_ stored: StorableType) -> CodableType? {
        stored
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - default property
public struct DefaultPropertyTraits<T: Codable>: CodableTraits
{
    public typealias StorableType = T
    public typealias CodableType = T
}

public typealias CodableProperty<T: Codable> = CodableKeyedProperty<DefaultPropertyTraits<T>>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - stable scalar
public struct StableScalarTraits<T: Codable & LosslessStringConvertible>: CodableTraits
{
    public static func fallback(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) -> T? {
        @inline(__always)
        func decode<T: Decodable & LosslessStringConvertible>(_: T.Type) -> (DecodeContainer, DynamicCodingKey) -> LosslessStringConvertible? {
            return { try? $0.decode(T.self, forKey: $1) }
        }
        
        if let str_representable = [
            decode(String.self),
            decode(Bool.self),
            decode(Int.self),
            decode(Int8.self),
            decode(Int16.self),
            decode(Int64.self),
            decode(UInt.self),
            decode(UInt8.self),
            decode(UInt16.self),
            decode(UInt64.self),
            decode(Double.self),
            decode(Float.self),
        ].compactMap({$0(container, dynamicKey)}).first {
            return T("\(str_representable)")
        }
        return nil
    }
}

public typealias CodableScalar<T: Codable & LosslessStringConvertible> = CodableKeyedProperty<StableScalarTraits<T>>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - stable optional scalar
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public struct StableOptionalScalarTraits<T: OptionalType>: CodableTraits where T.WrappedType: Codable & LosslessStringConvertible
{
    public typealias StorableType = T
    public typealias CodableType = T.WrappedType
    
    public static func assignStorableNil(from container: DecodeContainer,
                                         dynamicKey: DynamicCodingKey,
                                         mandatory: Bool,
                                         value: inout StorableType) -> Bool {
        value = T()
        return true
    }
    
    public static func createStorable(_ decoded: CodableType) -> StorableType? {
        StorableType(value: decoded)
    }
    
    public static func createDecodable(_ stored: StorableType) -> CodableType? {
        stored.asOptional
    }
    
    public static func fallback(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) -> CodableType? {
        
        @inline(__always)
        func decode<T: Decodable & LosslessStringConvertible>(_: T.Type) -> (DecodeContainer, DynamicCodingKey) -> LosslessStringConvertible? {
            return { try? $0.decode(T.self, forKey: $1) }
        }
        
        if let str_representable = [
            decode(String.self),
            decode(Bool.self),
            decode(Int.self),
            decode(Int8.self),
            decode(Int16.self),
            decode(Int64.self),
            decode(UInt.self),
            decode(UInt8.self),
            decode(UInt16.self),
            decode(UInt64.self),
            decode(Double.self),
            decode(Float.self),
        ].compactMap({$0(container, dynamicKey)}).first {
            return CodableType("\(str_representable)")
        }
        return nil
    }
}

public typealias CodableStableOptionalScalar<T: OptionalType> = CodableKeyedProperty<StableOptionalScalarTraits<T>>
where T.WrappedType: Codable & LosslessStringConvertible

public struct OptionalScalarTraits<T: OptionalType>: CodableTraits where T.WrappedType: Codable
{
    public typealias StorableType = T
    public typealias CodableType = T.WrappedType
    
    public static func assignStorableNil(from container: DecodeContainer,
                                         dynamicKey: DynamicCodingKey,
                                         mandatory: Bool,
                                         value: inout StorableType) -> Bool {
        value = T()
        return true
    }
    
    public static func createStorable(_ decoded: CodableType) -> StorableType? {
        StorableType(value: decoded)
    }
    
    public static func createDecodable(_ stored: StorableType) -> CodableType? {
        stored.asOptional
    }
}

public typealias CodableOptionalScalar<T: OptionalType> = CodableKeyedProperty<OptionalScalarTraits<T>>
where T.WrappedType: Codable
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - stable bool
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public struct StableBoolTraits: CodableTraits
{
    public static func fallback(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) -> Bool? {
        if let int_val = try? container.decode(Int.self, forKey: dynamicKey) {
            return int_val > 0
        } else if let str_val = try? container.decode(String.self, forKey: dynamicKey) {
            switch str_val.lowercased() {
                case "yes", "true":
                    return true
                case "no", "false":
                    return false
                default:
                    return false
            }
        }
        return nil
    }
}

public typealias CodableStableBool = CodableKeyedProperty<StableBoolTraits>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - stable array traits
public struct StableArrayTraits<T: Codable>: CodableTraits
{
    public static func decode(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) throws -> [T] {
        var array_cnt = try container.nestedUnkeyedContainer(forKey: dynamicKey)
        var elements = [T]()
        while !array_cnt.isAtEnd {
            do {
                let value = try array_cnt.decode(T.self)
                elements.append(value)
            } catch {
                // we still need to move our decoding cursor past that element
                _ = try? array_cnt.decode(_AnyDecodableValue.self)
            }
        }
        return elements
    }
}

public typealias CodableArrayProperty<T: Codable> = CodableKeyedProperty<StableArrayTraits<T>>

struct _AnyDecodableValue: Decodable {}

public struct StableFlattendArrayTraits<T: Codable>: CodableTraits
{
    public static func decode(from container: DecodeContainer, _ dynamicKey: DynamicCodingKey) throws -> [T] {
        let nested_cnt = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: dynamicKey)
        var elements = [T]()
        let keys = nested_cnt.allKeys
        for key in keys {
            do {
                let subitem = try nested_cnt.decode(T.self, forKey: key)
                elements.append(subitem)
            } catch {
                _ = try? nested_cnt.decode(_AnyDecodableValue.self, forKey: key)
            }
        }
        return elements
    }
}

public typealias CodableFlattenedArrayProperty<T: Codable> = CodableKeyedProperty<StableFlattendArrayTraits<T>>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - UIColor traits
#if os(iOS)
public struct UIColorTraits: CodableTraits
{
    public static func createStorable(_ codable: String) -> UIColor? {
        var str = codable.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") {
            str.remove(at: str.startIndex)
        }
        if str.count < 6 {
            return nil
        } else {
            var rgb: UInt64 = 0
            if Scanner(string: str).scanHexInt64(&rgb) {
                return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                               green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                               blue: CGFloat(rgb & 0x0000FF) / 255.0,
                               alpha: 1)
            } else {
                return nil
            }
        }
    }
    
    public static func createDecodable(_ storable: UIColor) -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if storable.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(red) * 255.0),
                lroundf(Float(green) * 255.0),
                lroundf(Float(blue) * 255.0)
            )
        } else {
            return "#000000"
        }
    }
}

public typealias CodableUIColor = CodableKeyedProperty<UIColorTraits>
#endif
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - ISO 8601 Date traits
public struct ISO8601DateTraits: CodableTraits
{
    private static var _iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    public static func createStorable(_ codable: String) -> Date? {
        _iso8601Formatter.date(from: codable)
    }
    
    public static func createDecodable(_ storable: Date) -> String? {
        _iso8601Formatter.string(from: storable)
    }
}

public typealias CodableISO8601Date = CodableKeyedProperty<ISO8601DateTraits>


public struct URLTraits: CodableTraits
{
    public static func createStorable(_ storable: String) -> URL? {
        URL(string: storable)
    }
    
    public static func createDecodable(_ storable: URL) -> String? {
        storable.absoluteString
    }
}

public typealias CodableURL = CodableKeyedProperty<URLTraits>

public struct OptionalURLTraits: CodableTraits
{
    public typealias StorableType = URL?
    public typealias CodableType = String
    
    public static func assignStorableNil(from container: DecodeContainer,
                                         dynamicKey: DynamicCodingKey,
                                         mandatory: Bool,
                                         value: inout StorableType) -> Bool {
        value = nil
        return true
    }
    
    public static func createStorable(_ storable: String) -> StorableType? {
        //double optional here
        if let url = URL(string: storable) {
            return url
        } else {
            return nil
        }
    }
    
    public static func createDecodable(_ storable: URL?) -> CodableType? {
        storable.flatMap { $0.absoluteString }
    }
}

public typealias CodableOptionalURL = CodableKeyedProperty<OptionalURLTraits>
