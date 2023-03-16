//
//  MandatoryDecodingTest.swift
//  
//
//  Created by Stanislav Reznichenko on 15.03.2023.
//

import XCTest
@testable import CodableProperty

final class MandatoryDecodingTest: XCTestCase {

    static let jsonWithMandatoryTypeMismatch = Data("""
    {
        "intProperty": "not integer"
    }
    """.utf8)
    
    static let jsonWithMandatoryNotExist = Data("""
    {
        "badname": "10"
    }
    """.utf8)
    
    static let jsonWithMandatoryNull = Data("""
    {
        "intProperty": null
    }
    """.utf8)
    
    struct MandatoryTest: CodableEntity, DefaultConstructible
    {
        @CodableScalar(mandatory: true)
        var intProperty: Int = 0
        
        static var codableKeyPaths = KeyPathList{
            \Self._intProperty
        }
    }
    
    func testMandatoryTypeFailure() throws {
        do {
            _ = try JSONDecoder().decode(MandatoryTest.self, from: Self.jsonWithMandatoryTypeMismatch)
            XCTFail()
        } catch DecodingError.typeMismatch(let type, let ctx) where
                    ctx.codingPath.count == 1 &&
                    ctx.codingPath[0].stringValue == "intProperty" &&
                    type is Int.Type   {
            
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryKeyFailure() throws {
        do {
            _ = try JSONDecoder().decode(MandatoryTest.self, from: Self.jsonWithMandatoryNotExist)
            XCTFail()
        } catch DecodingError.keyNotFound(let key, _ ) where key.stringValue == "intProperty" {
            
        } catch {
            XCTFail()
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func testMandatoryNullFailure() throws {
        do {
            _ = try JSONDecoder().decode(MandatoryTest.self, from: Self.jsonWithMandatoryNull)
            XCTFail()
        } catch DecodingError.valueNotFound(let type, let context) where
                    type is Int.Type &&
                    context.codingPath.count == 1 &&
                    context.codingPath[0].stringValue == "intProperty" {
            
        } catch {
            XCTFail()
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static let jsonTree = Data("""
    {
        "level1": {
            "level2": {
                "intProperty": 9
            }
        }
    }
    """.utf8)
    
    struct MandatoryPathTest: CodableEntity, DefaultConstructible
    {
        @CodableProperty(key: "level1.level2.intProperty", mandatory: true)
        var intProperty: Int = 0
        
        static var codableKeyPaths = KeyPathList{
            \Self._intProperty
        }
    }
    
    func testMandatoryPath() throws {
        let decoded = try JSONDecoder().decode(MandatoryPathTest.self, from: Self.jsonTree)
        XCTAssertTrue(decoded.intProperty == 9)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct MandatoryPathFailureTest: CodableEntity, DefaultConstructible
    {
        @CodableProperty(key: "level1.level2.badName", mandatory: true)
        var intProperty: Int = 0
        
        static var codableKeyPaths = KeyPathList{
            \Self._intProperty
        }
    }
    
    func testMandatoryPathFailure() throws {
        do {
            _ = try JSONDecoder().decode(MandatoryPathFailureTest.self, from: Self.jsonTree)
            XCTFail()
        } catch DecodingError.keyNotFound(let key, _ ) where key.stringValue == "badName" {
            
        } catch {
            XCTFail()
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
