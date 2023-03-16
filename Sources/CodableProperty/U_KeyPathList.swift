//
//  U_KeyPathList.swift
//  Utility
//  Created by Stanislav Reznichenko on 10.07.2021.
//

import Foundation


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - list
public protocol ICodableKeyPathList
{
    associatedtype Target
    func decode(_ target: inout Target,
                container: KeyedDecodingContainer<DynamicCodingKey>) throws
    func encode(target: Target,
                container: inout KeyedEncodingContainer<DynamicCodingKey>) throws
}

public struct KeyPathList<Target>: ICodableKeyPathList
{
    private let _head: AnyDecodableKeyPathNode<Target>
    
    public init<ListHead: ICodableKeyPathNode >(@KeyPathsBuilder _ keyPaths: () -> ListHead )
    where ListHead.Target == Target {
        self._head = AnyDecodableKeyPathNode(keyPaths())
    }
    
    public func decode(_ target: inout Target, container: KeyedDecodingContainer<DynamicCodingKey>) throws {
        let mirror = Mirror(reflecting: target)
        var names = [UUID: String]()
        for case let (name?, value) in mirror.children {
            if let id_prop = value as? IdentifiableProperty {
                names[id_prop.id] = name
            }
        }
        try self._head.decode(target: &target, container: container, reflectedNames: names)
    }
    
    public func encode(target: Target,
                       container: inout KeyedEncodingContainer<DynamicCodingKey>) throws {
        let mirror = Mirror(reflecting: target)
        var names = [UUID: String]()
        for case let (name?, value) in mirror.children {
            if let id_prop = value as? IdentifiableProperty {
                names[id_prop.id] = name
            }
        }
        try self._head.encode(target: target, container: &container, reflectedNames: names)
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - list builder
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@resultBuilder
public struct KeyPathsBuilder
{
//Alexandrescu says: let's make a type list. hello from "loki" lib
    public typealias List1<T, P> = CodableKeyPathNode<T, P, EmptyNode<T>>
    where P: CodableIdentifiable
    public typealias List2<T, P0, P1> = CodableKeyPathNode<T, P0, List1<T, P1>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable
    public typealias List3<T, P0, P1, P2> = CodableKeyPathNode<T, P0, List2<T, P1, P2>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable
    public typealias List4<T, P0, P1, P2, P3> = CodableKeyPathNode<T, P0, List3<T, P1, P2, P3>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable
    public typealias List5<T, P0, P1, P2, P3, P4> = CodableKeyPathNode<T, P0, List4<T, P1, P2, P3, P4>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable
    public typealias List6<T, P0, P1, P2, P3, P4, P5> = CodableKeyPathNode<T, P0, List5<T, P1, P2, P3, P4, P5>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable
    public typealias List7<T, P0, P1, P2, P3, P4, P5, P6> = CodableKeyPathNode<T, P0, List6<T, P1, P2, P3, P4, P5, P6>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable
    public typealias List8<T, P0, P1, P2, P3, P4, P5, P6, P7> = CodableKeyPathNode<T, P0, List7<T, P1, P2, P3, P4, P5, P6, P7>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable
    public typealias List9<T, P0, P1, P2, P3, P4, P5, P6, P7, P8> = CodableKeyPathNode<T, P0, List8<T, P1, P2, P3, P4, P5, P6, P7, P8>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable,
          P8: CodableIdentifiable
    public typealias List10<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9> = CodableKeyPathNode<T, P0, List9<T, P1, P2, P3, P4, P5, P6, P7, P8, P9>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable,
          P8: CodableIdentifiable,
          P9: CodableIdentifiable
    public typealias List11<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10> = CodableKeyPathNode<T, P0, List10<T, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10>>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable,
          P8: CodableIdentifiable,
          P9: CodableIdentifiable,
          P10: CodableIdentifiable
    
    public static func buildBlock<T, P>(_ keyPath: WritableKeyPath<T, P>) -> List1<T, P>
    where P: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath, tail: EmptyNode<T>())
    }
    
    public static func buildBlock<T, P0, P1>(_ keyPath0: WritableKeyPath<T, P0>,
                                      _ keyPath1: WritableKeyPath<T, P1>) -> List2<T, P0, P1>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1))
    }
    
    public static func buildBlock<T, P0, P1, P2>(_ keyPath0: WritableKeyPath<T, P0>,
                                          _ keyPath1: WritableKeyPath<T, P1>,
                                          _ keyPath2: WritableKeyPath<T, P2>) -> List3<T, P0, P1, P2>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3>(_ keyPath0: WritableKeyPath<T, P0>,
                                              _ keyPath1: WritableKeyPath<T, P1>,
                                              _ keyPath2: WritableKeyPath<T, P2>,
                                              _ keyPath3: WritableKeyPath<T, P3>) -> List4<T, P0, P1, P2, P3>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3, P4>(_ keyPath0: WritableKeyPath<T, P0>,
                                                  _ keyPath1: WritableKeyPath<T, P1>,
                                                  _ keyPath2: WritableKeyPath<T, P2>,
                                                  _ keyPath3: WritableKeyPath<T, P3>,
                                                  _ keyPath4: WritableKeyPath<T, P4>) -> List5<T, P0, P1, P2, P3, P4>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3, keyPath4))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3, P4, P5>(_ keyPath0: WritableKeyPath<T, P0>,
                                                      _ keyPath1: WritableKeyPath<T, P1>,
                                                      _ keyPath2: WritableKeyPath<T, P2>,
                                                      _ keyPath3: WritableKeyPath<T, P3>,
                                                      _ keyPath4: WritableKeyPath<T, P4>,
                                                      _ keyPath5: WritableKeyPath<T, P5>) -> List6<T, P0, P1, P2, P3, P4, P5>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3, keyPath4, keyPath5))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3, P4, P5, P6>(_ keyPath0: WritableKeyPath<T, P0>,
                                                          _ keyPath1: WritableKeyPath<T, P1>,
                                                          _ keyPath2: WritableKeyPath<T, P2>,
                                                          _ keyPath3: WritableKeyPath<T, P3>,
                                                          _ keyPath4: WritableKeyPath<T, P4>,
                                                          _ keyPath5: WritableKeyPath<T, P5>,
                                                          _ keyPath6: WritableKeyPath<T, P6>) -> List7<T, P0, P1, P2, P3, P4, P5, P6>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3, keyPath4, keyPath5, keyPath6))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3, P4, P5, P6, P7>(_ keyPath0: WritableKeyPath<T, P0>,
                                                              _ keyPath1: WritableKeyPath<T, P1>,
                                                              _ keyPath2: WritableKeyPath<T, P2>,
                                                              _ keyPath3: WritableKeyPath<T, P3>,
                                                              _ keyPath4: WritableKeyPath<T, P4>,
                                                              _ keyPath5: WritableKeyPath<T, P5>,
                                                              _ keyPath6: WritableKeyPath<T, P6>,
                                                              _ keyPath7: WritableKeyPath<T, P7>) -> List8<T, P0, P1, P2, P3, P4, P5, P6, P7>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3, keyPath4, keyPath5, keyPath6, keyPath7))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3, P4, P5, P6, P7, P8>(_ keyPath0: WritableKeyPath<T, P0>,
                                                                  _ keyPath1: WritableKeyPath<T, P1>,
                                                                  _ keyPath2: WritableKeyPath<T, P2>,
                                                                  _ keyPath3: WritableKeyPath<T, P3>,
                                                                  _ keyPath4: WritableKeyPath<T, P4>,
                                                                  _ keyPath5: WritableKeyPath<T, P5>,
                                                                  _ keyPath6: WritableKeyPath<T, P6>,
                                                                  _ keyPath7: WritableKeyPath<T, P7>,
                                                                  _ keyPath8: WritableKeyPath<T, P8>) -> List9<T, P0, P1, P2, P3, P4, P5, P6, P7, P8>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable,
          P8: CodableIdentifiable{
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3, keyPath4, keyPath5, keyPath6, keyPath7, keyPath8))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9>(_ keyPath0: WritableKeyPath<T, P0>,
                                                                             _ keyPath1: WritableKeyPath<T, P1>,
                                                                             _ keyPath2: WritableKeyPath<T, P2>,
                                                                             _ keyPath3: WritableKeyPath<T, P3>,
                                                                             _ keyPath4: WritableKeyPath<T, P4>,
                                                                             _ keyPath5: WritableKeyPath<T, P5>,
                                                                             _ keyPath6: WritableKeyPath<T, P6>,
                                                                             _ keyPath7: WritableKeyPath<T, P7>,
                                                                             _ keyPath8: WritableKeyPath<T, P8>,
                                                                             _ keyPath9: WritableKeyPath<T, P9>) -> List10<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable,
          P8: CodableIdentifiable,
          P9: CodableIdentifiable{
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3, keyPath4, keyPath5, keyPath6, keyPath7, keyPath8, keyPath9))
    }
    
    public static func buildBlock<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10>(_ keyPath0: WritableKeyPath<T, P0>,
                                                                                  _ keyPath1: WritableKeyPath<T, P1>,
                                                                                  _ keyPath2: WritableKeyPath<T, P2>,
                                                                                  _ keyPath3: WritableKeyPath<T, P3>,
                                                                                  _ keyPath4: WritableKeyPath<T, P4>,
                                                                                  _ keyPath5: WritableKeyPath<T, P5>,
                                                                                  _ keyPath6: WritableKeyPath<T, P6>,
                                                                                  _ keyPath7: WritableKeyPath<T, P7>,
                                                                                  _ keyPath8: WritableKeyPath<T, P8>,
                                                                                  _ keyPath9: WritableKeyPath<T, P9>,
                                                                                  _ keyPath10: WritableKeyPath<T, P10>) -> List11<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10>
    where P0: CodableIdentifiable,
          P1: CodableIdentifiable,
          P2: CodableIdentifiable,
          P3: CodableIdentifiable,
          P4: CodableIdentifiable,
          P5: CodableIdentifiable,
          P6: CodableIdentifiable,
          P7: CodableIdentifiable,
          P8: CodableIdentifiable,
          P9: CodableIdentifiable,
          P10: CodableIdentifiable {
        return CodableKeyPathNode(keyPath: keyPath0, tail: buildBlock(keyPath1, keyPath2, keyPath3, keyPath4, keyPath5, keyPath6, keyPath7, keyPath8, keyPath9, keyPath10))
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: - nodes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public protocol ICodableKeyPathNode
{
    associatedtype Target
    typealias DecodeContainer = KeyedDecodingContainer<DynamicCodingKey>
    typealias EncodeContainer = KeyedEncodingContainer<DynamicCodingKey>
    func decode(target: inout Target,
                container: DecodeContainer,
                reflectedNames: [UUID: String]) throws
    func encode(target: Target,
                container: inout EncodeContainer,
                reflectedNames: [UUID: String]) throws
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public struct EmptyNode<T>: ICodableKeyPathNode
{
    public func decode(target: inout T,
                container: DecodeContainer,
                reflectedNames: [UUID: String]) throws {
    }
    
    public func encode(target: T,
                container: inout EncodeContainer,
                reflectedNames: [UUID: String]) throws {
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public struct CodableKeyPathNode<Target, Property, Tail: ICodableKeyPathNode>: ICodableKeyPathNode
where Tail.Target == Target,
      Property: IdentifiableProperty & DecodableKeyedValue & EncodableKeyedValue
{
    let keyPath: WritableKeyPath<Target, Property>
    let tail: Tail
    
    public func decode(target: inout Target,
                       container: DecodeContainer,
                       reflectedNames: [UUID: String]) throws {
        //print(value)
        let property_id = target[keyPath: self.keyPath].id
        let property_name = reflectedNames[property_id]
        try target[keyPath: self.keyPath].decode(from: container, reflectedName: property_name)
        try self.tail.decode(target: &target, container: container, reflectedNames: reflectedNames)
    }
    
    public func encode(target: Target,
                       container: inout EncodeContainer,
                       reflectedNames: [UUID: String]) throws {
        let property_id = target[keyPath: self.keyPath].id
        let property_name = reflectedNames[property_id]
        try target[keyPath: self.keyPath].encode(to: &container, reflectedName: property_name)
        try self.tail.encode(target: target, container: &container, reflectedNames: reflectedNames)
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct AnyDecodableKeyPathNode<Target>: ICodableKeyPathNode
{
    private let _decode_fn: (inout Target, DecodeContainer, [UUID: String]) throws -> Void
    private let _encode_fn: (Target, inout EncodeContainer, [UUID: String]) throws -> Void
    
    init<ListHead: ICodableKeyPathNode>(_ head: ListHead) where ListHead.Target == Target {
        self._decode_fn = head.decode
        self._encode_fn = head.encode
    }
    
    func decode(target: inout Target,
                container: DecodeContainer,
                reflectedNames: [UUID: String]) throws {
        try self._decode_fn(&target, container, reflectedNames)
    }
    
    func encode(target: Target,
                container: inout EncodeContainer,
                reflectedNames: [UUID: String]) throws {
        try self._encode_fn(target, &container, reflectedNames)
    }
}
