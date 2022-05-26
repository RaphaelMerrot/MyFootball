//
//  URLSessionMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import InstantMock


final class URLSessionMock: URLSession, MockDelegate {

    private let mock = Mock()

    var it: Mock {
        return self.mock
    }

    override func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        return self.mock.call(url, completionHandler) ?? URLSessionDataTaskMock()
    }
}
