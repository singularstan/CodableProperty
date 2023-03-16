//
//  U_Optional+Ext.swift
//  Utility
//  Created by Stanislav Reznichenko on 12.02.2020.
//

import Foundation


public protocol OptionalType
{
    associatedtype WrappedType
    init()
    init(value: WrappedType)
    var asOptional: WrappedType? { get }
    func value(or defaultValue: WrappedType) -> WrappedType
}

extension Optional: OptionalType
{
    public typealias WrappedType = Wrapped
    public init() {
        self = nil
    }
    public init(value: Wrapped) {
        self = value
    }
    public var asOptional: Wrapped? {
        return self
    }
    public func value(or defaultValue: Wrapped) -> Wrapped {
        return self ?? defaultValue
    }
}
