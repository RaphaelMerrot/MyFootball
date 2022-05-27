//
//  URLSessionDataTaskMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import InstantMock


final class URLSessionDataTaskMock: URLSessionDataTask, MockDelegate {

    private let mock = Mock()

    var it: Mock {
        return self.mock
    }

    override func resume() {
        self.mock.call()
    }
}
