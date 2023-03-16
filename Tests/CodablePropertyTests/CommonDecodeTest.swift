
import XCTest
@testable import CodableProperty

final class CommonDecodeTest: XCTestCase {

    private struct Result : CodableEntity, DefaultConstructible {
        @CodableScalar
        var intProperty: Int = 10
        
        @CodableScalar(key: "IntTypeAndKeyMismatch")
        var intProperty2: Int = 10
        
        @CodableScalar(key: "stringTypeMismatch")
        var stringProperty2: String
        
        @CodableScalar
        var floatTypeMismatch: Float = 0
        
        @CodableStableBool
        var boolProperty: Bool = false
        
        @CodableStableBool
        var boolProperty2: Bool = false
        
        @CodableStableBool
        var boolProperty3: Bool = true
        
        @CodableStableBool
        var boolProperty4: Bool = false
        
        @CodableScalar
        var stringProperty: String = "string value"
        
        @CodableISO8601Date
        var dateISO8601
        
        @CodableURL
        var link = URL(string: "file://")!
        
        static var codableKeyPaths = KeyPathList {
            \Self._stringProperty
            \Self._stringProperty2
            \Self._intProperty
            \Self._intProperty2
            \Self._boolProperty
            \Self._boolProperty2
            \Self._boolProperty3
            \Self._boolProperty4
            \Self._floatTypeMismatch
            \Self._dateISO8601
            \Self._link
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static let json = Data("""
    {
        "intProperty": 56,
        "intTypeandkeyMismatch": "100",
        "stringTypeMismatch": 100,
        "boolProperty": "yes",
        "boolProperty2": "YES",
        "boolProperty3": "FALSE",
        "boolProperty4": 999,
        "stringProperty": "new value",
        "floatTypeMismatch": "9.9",
        "dateISO8601": "2020-12-05T15:39:02Z",
        "link": "https://test.com/path"
    }
    """.utf8)
    
    func testDecodeAndNameMapping() throws {
        let decoded = try JSONDecoder().decode(Result.self, from: Self.json)
        XCTAssertEqual(decoded.intProperty, 56, "int property decoding failed")
        XCTAssertEqual(decoded.stringProperty, "new value", "string property decoding failed")
        XCTAssertEqual(decoded.intProperty2, 100, "fallback decoding string-int failed")
        XCTAssertEqual(decoded.stringProperty2, "100", "fallback decoding int-string failed")
        XCTAssertTrue(decoded.boolProperty, "stable bool decoding failed")
        XCTAssertTrue(decoded.boolProperty2, "stable bool decoding failed")
        XCTAssertFalse(decoded.boolProperty3, "stable bool decoding failed")
        XCTAssertTrue(decoded.boolProperty4, "stable bool decoding from int failed")
        XCTAssertTrue((decoded.floatTypeMismatch - 9.9) < Float.ulpOfOne, "fallback decoding string-float failed")
        XCTAssertTrue(decoded.link.absoluteString == "https://test.com/path")
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static let jsonWithNull = Data("""
    {
        "value": null
    }
    """.utf8)
    
    struct SkipNullForNonOptionTest: CodableEntity, DefaultConstructible
    {
        @CodableScalar
        var value: Int = 10
        
        static var codableKeyPaths = KeyPathList{
            \Self._value
        }
    }
    
    func testSkipNullForNonOption() throws {
        let decoded = try JSONDecoder().decode(SkipNullForNonOptionTest.self, from: Self.jsonWithNull)
        XCTAssertEqual(decoded.value, 10)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static let jsonWithEnum = Data("""
    {
        "simpleEnum": "two"
    }
    """.utf8)
    
    enum SimpleEnum: String, Codable
    {
        case one, two
    }

    struct SimpleEnumTest: CodableEntity, DefaultConstructible
    {
        @CodableProperty
        var simpleEnum: SimpleEnum = .one
        
        static var codableKeyPaths = KeyPathList{
            \Self._simpleEnum
        }
    }
    
    func testEnumDecoding() throws {
        let decoded = try JSONDecoder().decode(SimpleEnumTest.self, from: Self.jsonWithEnum)
        XCTAssertTrue(decoded.simpleEnum == .two)
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
