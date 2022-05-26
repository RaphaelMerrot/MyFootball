//
//  JSONServiceMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


final class JSONServiceMock: Mock, JSONService {

    func fetch<T>(url: URL?, success: @escaping SuccessCallBack<T>, failure: @escaping ErrorCallBack) where T : Decodable {
        super.call(url, success, failure)
    }
}
