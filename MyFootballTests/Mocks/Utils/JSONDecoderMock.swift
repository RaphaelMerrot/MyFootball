//
//  JSONDecoderMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import InstantMock


final class JSONDecoderMock: JSONDecoder, MockDelegate {

    private let mock = Mock()

    var it: Mock {
        return self.mock
    }


    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        try self.mock.callThrowing(type, data) ?? super.decode(type, from: data)
    }
}
