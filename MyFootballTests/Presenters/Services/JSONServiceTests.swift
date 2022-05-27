//
//  JSONServiceTests.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import InstantMock
import XCTest

@testable import MyFootball

final class JSONServiceTests: XCTestCase {

    private enum DummyError: Error {
        case dummy
    }

    private var service: JSONServiceImpl!

    private var sessionManager: URLSessionMock!

    private var task: URLSessionDataTaskMock!

    private var decoder: JSONDecoderMock!


    override func setUp() {
        super.setUp()
        self.sessionManager = URLSessionMock()
        self.task = URLSessionDataTaskMock()
        self.decoder = JSONDecoderMock()
        self.service = JSONServiceImpl(
            sessionManager: self.sessionManager,
            decoder: self.decoder
        )
    }


    func testFetch_noURL() {
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: Arg.closure()),
            count: 0
        )
        self.service.fetch(url: nil) { (response: League?) in
            XCTFail("success executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
    }


    func testFetch_success() {
        let league = League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "tst")
        let leagues = Leagues(leagues: [league])
        let data = try? JSONEncoder().encode(leagues)
        let response = URLResponse(
            url: URL(string: "test")!,
            mimeType: "application/json",
            expectedContentLength: 1,
            textEncodingName: nil
        )
        self.task.it.expect().call(self.task.resume())
        let successClosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: successClosure.capture())
        ).andDo { _ in
            successClosure.value!(data, response, nil)
        }.andReturn(self.task)
        self.decoder.it.stub().call(
            try? self.decoder.decode(Arg.eq(Leagues.self), from: Arg.any())
        ).andReturn(leagues)

        self.service.fetch(url: URL(string: "test")) { (response: Leagues?) in
            XCTAssertNotNil(response)
        } failure: { error in
            XCTFail("failure Executed")
        }
    }


    func testFetch_failure() {
        self.task.it.expect().call(task.resume())
        let errorclosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value!(nil, nil, DummyError.dummy)
        }.andReturn(self.task)
        self.decoder.it.expect().call(
            try? self.decoder.decode(Arg.eq(Leagues.self), from: Arg.any()),
            count: 0
        )

        self.service.fetch(url: URL(string: "test")) { (response: Leagues) in
            XCTFail("success Executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
        self.decoder.it.verify()
    }


    func testFetch_failure_mimeType() {
        let league = League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "tst")
        let leagues = Leagues(leagues: [league])
        let data = try? JSONEncoder().encode(leagues)
        let response = URLResponse(
            url: URL(string: "test")!,
            mimeType: "toto",
            expectedContentLength: 1,
            textEncodingName: nil
        )
        self.task.it.expect().call(self.task.resume())
        let errorclosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value!(data, response, nil)
        }.andReturn(self.task)
        self.decoder.it.expect().call(
            try? self.decoder.decode(Arg.eq(Leagues.self), from: Arg.any()),
            count: 0
        )

        self.service.fetch(url: URL(string: "test")) { (response: Leagues) in
            XCTFail("success Executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
        self.decoder.it.verify()
    }


    func testFetch_failure_noData() {
        self.task.it.expect().call(task.resume())
        let errorclosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        let response = URLResponse(
            url: URL(string: "test")!,
            mimeType: "application/json",
            expectedContentLength: 1,
            textEncodingName: nil
        )
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value!(nil, response, nil)
        }.andReturn(self.task)
        self.decoder.it.expect().call(
            try? self.decoder.decode(Arg.eq(Leagues.self), from: Arg.any()),
            count: 0
        )

        self.service.fetch(url: URL(string: "test")) { (response: Leagues) in
            XCTFail("success Executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
        self.decoder.it.verify()
    }


    func testFetch_failure_decode() {
        let league = League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "tst")
        let leagues = Leagues(leagues: [league])
        let data = try? JSONEncoder().encode(leagues)
        let response = URLResponse(
            url: URL(string: "test")!,
            mimeType: "application/json",
            expectedContentLength: 1,
            textEncodingName: nil
        )
        self.task.it.expect().call(self.task.resume())
        let errorclosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value!(data, response, nil)
        }.andReturn(self.task)
        self.decoder.it.stub().call(
            try? self.decoder.decode(Arg.eq(Leagues.self), from: Arg.any())
        ).andThrow(DummyError.dummy)

        self.service.fetch(url: URL(string: "test")) { (response: Leagues) in
            XCTFail("success Executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
        self.decoder.it.verify()
    }


    func testDownloadImage_noURL() {
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: Arg.closure()),
            count: 0
        )
        self.service.downloadImage(url: nil) { data in
            XCTFail("success executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
    }


    func testDownloadImage_failure() {
        self.task.it.expect().call(task.resume())
        let errorclosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value!(nil, nil, DummyError.dummy)
        }.andReturn(self.task)
        self.service.downloadImage(url: URL(string: "test")) { _ in
            XCTFail("success Executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
    }


    func testDownloadImage_failure_mimeType() {
        self.task.it.expect().call(task.resume())
        let response = URLResponse(
            url: URL(string: "test")!,
            mimeType: "issue",
            expectedContentLength: 1,
            textEncodingName: nil
        )
        let errorclosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value!(Data(), response, nil)
        }.andReturn(self.task)
        self.service.downloadImage(url: URL(string: "test")) { _ in
            XCTFail("success Executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
    }


    func testDownloadImage_failure_noData() {
        self.task.it.expect().call(task.resume())
        let response = URLResponse(
            url: URL(string: "test")!,
            mimeType: "image",
            expectedContentLength: 1,
            textEncodingName: nil
        )
        let errorclosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value!(nil, response, nil)
        }.andReturn(self.task)
        self.service.downloadImage(url: URL(string: "test")) { _ in
            XCTFail("success Executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.sessionManager.it.verify()
    }


    func testDownloadImage_success() {
        self.task.it.expect().call(task.resume())
        let response = URLResponse(
            url: URL(string: "test")!,
            mimeType: "image",
            expectedContentLength: 1,
            textEncodingName: nil
        )
        let successClosure = ArgumentClosureCaptor<(Data?, URLResponse?, Error?) -> Void>()
        self.sessionManager.it.expect().call(
            self.sessionManager.dataTask(with: Arg.any(), completionHandler: successClosure.capture())
        ).andDo { _ in
            successClosure.value!(Data(), response, nil)
        }.andReturn(self.task)
        self.service.downloadImage(url: URL(string: "test")) { data in
            XCTAssertNotNil(data)
        } failure: { error in
            XCTFail("error Executed")
        }
        self.sessionManager.it.verify()
    }
}
