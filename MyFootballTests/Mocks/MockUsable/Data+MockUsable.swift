//
//  Data+MockUsable.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import InstantMock


extension Data: MockUsable {

    private static var any = Data(base64Encoded: "SGVsbG8=")!

    public static var anyValue: MockUsable {
        return Data.any
    }


    public func equal(to value: MockUsable?) -> Bool {
        guard let val = value as? Data else { return false }
        return self == val
    }

}
