//
//  OptionalsDecodeTest.swift
//  
//
//  Created by Stanislav Reznichenko on 15.03.2023.
//

import XCTest
@testable import CodableProperty

final class OptionalsDecodeTest: XCTestCase {

    static let jsonWithOptionals = Data("""
    {
        "value1": "value",
        "value2": null,
        "value4": "99",
        "value5": 100
    }
    """.utf8)
    
    struct OptionalTest: CodableEntity, DefaultConstructible
    {
        @CodableOptionalScalar
        var value1: String?
        
        @CodableOptionalScalar
        var value5: Int?
        
        static var codableKeyPaths = KeyPathList{
            \Self._value1
            \Self._value5
        }
    }
    
    func testOptionalDecoding() throws {
        let decoded = try JSONDecoder().decode(OptionalTest.self, from: Self.jsonWithOptionals)
        XCTAssertTrue(decoded.value1 == "value")
        XCTAssertTrue(decoded.value5 == 100)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct OptionalAndMandatoryTest: CodableEntity, DefaultConstructible
    {
        @CodableOptionalScalar(mandatory: true)
        var value3: String?
        
        static var codableKeyPaths = KeyPathList{
            \Self._value3
        }
    }
    
    func testOptionalValueMandatoryProperty() throws {
        do {
            _ = try JSONDecoder().decode(OptionalAndMandatoryTest.self, from: Self.jsonWithOptionals)
            XCTFail()
        } catch DecodingError.keyNotFound(let key, _ ) where key.stringValue == "value3" {
            
        } catch {
            XCTFail()
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct OptionalFallbackDecodingTest: CodableEntity, DefaultConstructible
    {
        @CodableOptionalScalar
        var value4: Int? = 10
        
        static var codableKeyPaths = KeyPathList{
            \Self._value4
        }
    }
    
    func testOptionalFallbackDecoding() throws {
        let decoded = try JSONDecoder().decode(OptionalFallbackDecodingTest.self, from: Self.jsonWithOptionals)
        XCTAssertTrue(decoded.value4 == 99)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct OptionalNilTest: CodableEntity, DefaultConstructible
    {
        @CodableOptionalScalar
        var value2: Int? = 10
        
        static var codableKeyPaths = KeyPathList{
            \Self._value2
        }
    }
    
    func testOptionalResetByNil() throws {
        let decoded = try JSONDecoder().decode(OptionalNilTest.self, from: Self.jsonWithOptionals)
        XCTAssertNil(decoded.value2)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct OptionalTypeFailureTest: CodableEntity, DefaultConstructible
    {
        @CodableOptionalScalar
        var value1: Int? = 10
        
        static var codableKeyPaths = KeyPathList{
            \Self._value1
        }
    }
    
    func testOptionalTypeFailure() throws {
        do {
            _ = try JSONDecoder().decode(OptionalTypeFailureTest.self, from: Self.jsonWithOptionals)
            XCTFail()
        } catch DecodingError.typeMismatch(let type, let ctx) where
                    ctx.codingPath.count == 1 &&
                    ctx.codingPath[0].stringValue == "value1" &&
                    type is Int.Type   {
            
        } catch {
            XCTFail()
        }
    }
}
