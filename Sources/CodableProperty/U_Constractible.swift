//
//  U_Constractible.swift
//  Utility
//  Created by Stanislav Reznichenko on 02.02.2022.
//

import Foundation
#if os(iOS)
import UIKit
#endif

public protocol DefaultConstructible
{
    init()
}

extension Array: DefaultConstructible
{}

extension String: DefaultConstructible
{}

#if os(iOS)
extension UIColor: DefaultConstructible
{}
#endif

extension Date: DefaultConstructible
{}

public protocol DependentConstructible
{
    associatedtype Dependency
    init(dependency: Dependency)
}

extension Optional : DefaultConstructible {}
