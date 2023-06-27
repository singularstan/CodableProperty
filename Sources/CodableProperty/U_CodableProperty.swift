//
//  U_DecodableProperty.swift
//  Utility
//  Created by Stanislav Reznichenko on 10.07.2021.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - property wrapper
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@propertyWrapper
public struct CodableKeyedProperty<Traits: CodableTraits>: CodableIdentifiable
{
    public let id = UUID()
    public let path: [String]
    public let key: String?
    public let mandatory: Bool
    private(set) var isDefault: Bool  = true
    
    public var wrappedValue : Traits.StorableType {
        didSet {
            self.isDefault = false
        }
    }
    
    public init(wrappedValue defaultValue: Traits.StorableType, key: String? = nil, mandatory: Bool = false) {
        if let key = key {
            self.path = key.components(separatedBy: Traits.pathSeparator)
        } else {
            self.path = []
        }
        self.key = key
        self.mandatory = mandatory
        self.wrappedValue = defaultValue
    }
        
    public init(key: String? = nil, mandatory: Bool = false) where Traits.StorableType: DefaultConstructible {
        if let key = key {
            self.path = key.components(separatedBy: Traits.pathSeparator)
        } else {
            self.path = []
        }
        self.key = key
        self.mandatory = mandatory
        self.wrappedValue = Traits.StorableType()
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - decoder entry point
    mutating public func decode(from container: DecodeContainer, reflectedName: String?) throws {
        if self.path.count != 0 {
            try container.decode(using: Traits.self,
                                 path: self.path,
                                 mandatory: self.mandatory,
                                 value: &self.wrappedValue)
        } else {
            if var reflected_name = reflectedName {
                if reflected_name.first == "_" {
                    reflected_name.remove(at: reflected_name.startIndex)
                }
                try container.decode(using: Traits.self,
                                     key: reflected_name,
                                     mandatory: self.mandatory,
                                     value: &self.wrappedValue)
            } else {
                let ctx = DecodingError.Context(codingPath: container.codingPath,
                                                debugDescription: "neither path nor reflected name were provided")
                throw DecodingError.keyNotFound(DynamicCodingKey(key: ""), ctx)
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public func encode(to container: inout EncodeContainer, reflectedName: String?) throws {
        if let key = self.key {
            try container.encode(storedValue: self.wrappedValue, using: Traits.self, keyName: key)
        } else {
            if var reflected_name = reflectedName {
                if reflected_name.first == "_" {
                    reflected_name.remove(at: reflected_name.startIndex)
                }
                do {
                    try container.encode(storedValue: self.wrappedValue, using: Traits.self, keyName: reflected_name)
                } catch let error as EncodingError {
                    switch error {
                        case .invalidValue:
                            if self.mandatory {
                                throw error
                            }
                        default:
                            throw error
                    }
                }
            }
        }
    }
}

extension CodableKeyedProperty where Traits.StorableType: DefaultConstructible
{
    public init(from container: DecodeContainer, key: String) throws {
        self.path = key.components(separatedBy: Traits.pathSeparator)
        self.key = key
        self.mandatory = true
        self.wrappedValue = Traits.StorableType()
        try container.decode(using: Traits.self, path: path, mandatory: self.mandatory, value: &self.wrappedValue)
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - utils
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public struct DynamicCodingKey: CodingKey
{
    
    public var stringValue: String
    public  var intValue: Int?
    
    public init(key: String) {
        stringValue = key
    }
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "Index " + String(intValue)
    }
}

public protocol DecodableKeyedValue
{
    var key : String? { get }
    typealias DecodeContainer = KeyedDecodingContainer<DynamicCodingKey>
    mutating func decode(from container: DecodeContainer, reflectedName: String?) throws
}

public protocol EncodableKeyedValue
{
    var key : String? { get }
    typealias EncodeContainer = KeyedEncodingContainer<DynamicCodingKey>
    func encode(to container: inout EncodeContainer, reflectedName: String?) throws
}

public protocol IdentifiableProperty
{
    var id: UUID { get }
}

public typealias CodableIdentifiable = DecodableKeyedValue & EncodableKeyedValue & IdentifiableProperty


