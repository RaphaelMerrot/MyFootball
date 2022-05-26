//
//  URL+MockUsable.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import InstantMock


extension URL: MockUsable {

    private static var any = URL(fileURLWithPath: "mock")


    public static var anyValue: MockUsable {
        return URL.any
    }


    public func equal(to value: MockUsable?) -> Bool {
        if let value = value as? URL {
            return value == self
        }
        return false
    }

}
