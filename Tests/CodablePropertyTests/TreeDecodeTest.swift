//
//  TreeDecodeTest.swift
//  Utility
//  Created by Stanislav Reznichenko on 12.03.2023.
//

import XCTest
@testable import CodableProperty

final class TreeDecodeTest: XCTestCase {

    struct RootObject: CodableEntity, DefaultConstructible
    {
        @CodableScalar
        var intProperty: Int = 10
        
        @CodableProperty
        var level1 = Level1Object()
        
        static var codableKeyPaths = KeyPathList {
            \Self._intProperty
            \Self._level1
        }
    }

    struct Level1Object: CodableEntity, DefaultConstructible
    {
        @CodableScalar
        var stringProperty: String = "old value"
        
        @CodableProperty
        var level2 = Level2Object()
        
        static var codableKeyPaths = KeyPathList {
            \Self._stringProperty
            \Self._level2
        }
    }

    struct Level2Object: CodableEntity, DefaultConstructible
    {
        @CodableScalar
        var boolProperty = false
        
        @CodableScalar
        var intProperty = 999
        
        static var codableKeyPaths = KeyPathList {
            \Self._boolProperty
        }
    }
    
    static let json = Data("""
    {
        "intProperty": 99,
        "level1": {
            "stringProperty": "new value",
            "level2":{
                        "boolProperty": true
                     }
                  }
    }
    """.utf8)

    func testSubElementsDecoding() throws {
        let decoded = try JSONDecoder().decode(RootObject.self, from: Self.json)
        XCTAssertEqual(decoded.intProperty, 99)
        XCTAssertEqual(decoded.level1.stringProperty, "new value")
        XCTAssertTrue(decoded.level1.level2.boolProperty)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: -
    static let jsonToFlat = Data("""
    {
        "level1":{
            "stringProperty": "new value",
            "level2":{
                        "intProperty": 111
                     }
                 }
    }
    """.utf8)
    
    struct Flattened: CodableEntity, DefaultConstructible
    {
        @CodableProperty
        var level1: Level1Object
        
        @CodableProperty(key: "level1.level2")
        var level2: Level2Object
        
        static var codableKeyPaths = KeyPathList{
            \Self._level1
            \Self._level2
        }
    }
    
    func testPartiallyFlattenedTree() throws {
        let decoded = try JSONDecoder().decode(Flattened.self, from: Self.jsonToFlat)
        XCTAssertTrue(decoded.level1.stringProperty == "new value")
        XCTAssertEqual(decoded.level1.level2.intProperty, decoded.level2.intProperty, "decoding by path failed")
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: -
    static let jsonWithDynamicKeys = Data("""
    {
        "items": {
            "x1": {
                "attr": 10
            },
            "x2": {
                "attr": 0
            },
            "x3": {
                "attr": "invalid value"
            },
            "some1": {
                "attr": 5
            },
            "x4": {
                "invalid_name": 0
            },
            "x5": {
                "attr": 1
            }
        }
    }
    """.utf8)
    
    struct FlattenTestItem: CodableEntity, DefaultConstructible
    {
        @CodableScalar(mandatory: true)
        var attr = -1
        
        static var codableKeyPaths = KeyPathList{
            \Self._attr
        }
    }
    
    struct FlattenArrayTest: CodableEntity, DefaultConstructible
    {
        @CodableFlattenedArrayProperty
        var items: [FlattenTestItem]
        
        static var codableKeyPaths = KeyPathList{
            \Self._items
        }
    }
    
    func testFlattenedArray() throws {
        let decoded = try JSONDecoder().decode(FlattenArrayTest.self, from: Self.jsonWithDynamicKeys)
        XCTAssertTrue(decoded.items.count == 4)
        XCTAssertNotNil( decoded.items.first(where: { $0.attr == 10 }) )
        XCTAssertNotNil( decoded.items.first(where: { $0.attr == 0 }) )
        XCTAssertNotNil( decoded.items.first(where: { $0.attr == 5 }) )
        XCTAssertNotNil( decoded.items.first(where: { $0.attr == 1 }) )
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: -
    static let jsonArray = Data("""
    {
        "arrayProperty": [
            {
                "stringProperty":"new value1"
            },
            {
                "stringProperty":"new value2"
            },
            {
                "stringProperty":"new value3"
            }
        ]
    }
    """.utf8)
    
    static let jsonArrayWithInvalidElement = Data("""
    {
        "arrayProperty": [
            {
                "stringProperty":"new value 1"
            },
            {
                "stringProperty_wrongName":"new value 2"
            },
            {
                "stringProperty":"new value 3"
            }
        ]
    }
    """.utf8)
    
    struct ArrayElement: CodableEntity, DefaultConstructible
    {
        @CodableScalar(mandatory: true)
        var stringProperty: String
        
        static var codableKeyPaths = KeyPathList{
            \Self._stringProperty
        }
    }
    
    struct StableArrayTest: CodableEntity, DefaultConstructible
    {
        @CodableArrayProperty
        var arrayProperty: [ArrayElement]
        
        static var codableKeyPaths = KeyPathList{
            \Self._arrayProperty
        }
    }
    
    func testStableArray() throws {
        let decoded = try JSONDecoder().decode(StableArrayTest.self, from: Self.jsonArray)
        XCTAssertTrue(decoded.arrayProperty.count == 3)
        XCTAssertNotNil(decoded.arrayProperty.first(where: { $0.stringProperty == "new value1" }))
        XCTAssertNotNil(decoded.arrayProperty.first(where: { $0.stringProperty == "new value2" }))
        XCTAssertNotNil(decoded.arrayProperty.first(where: { $0.stringProperty == "new value3" }))
    }
    
    func testStableArrayWithInvalidElement() throws {
        let decoded = try JSONDecoder().decode(StableArrayTest.self, from: Self.jsonArrayWithInvalidElement)
        XCTAssertTrue(decoded.arrayProperty.count == 2)
        XCTAssertNotNil(decoded.arrayProperty.first(where: { $0.stringProperty == "new value 1" }))
        XCTAssertNotNil(decoded.arrayProperty.first(where: { $0.stringProperty == "new value 3" }))
    }
}
