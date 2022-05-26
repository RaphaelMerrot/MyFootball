//
//  LeagueServiceTests.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import XCTest
import InstantMock

@testable import MyFootball


final class LeagueServiceTests: XCTestCase {

    private enum DummyError: Error {
        case dummy
    }

    private var service: JSONServiceMock!

    private var leagueService: LeagueServiceImpl!


    override func setUp() {
        super.setUp()

        self.service = JSONServiceMock()
        self.leagueService = LeagueServiceImpl(service: self.service)
    }


    func testFetchLeague_sucess() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test1", strSport: "Rugby", strLeagueAlternate: "tst1"),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "tst2")
        ])
        let successClosure = ArgumentClosureCaptor<SuccessCallBack<Leagues>>()
        self.service.expect().call(
            self.service.fetch(url: Arg.any(), success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues)
        }
        self.leagueService.fetchLeagues { data in
            XCTAssertEqual(data?.count, 1)
            let value = data?.first
            XCTAssertNotNil(value)
            XCTAssertEqual(value?.idLeague, leagues.leagues?.last?.idLeague)
            XCTAssertEqual(value?.strLeague, leagues.leagues?.last?.strLeague)
            XCTAssertEqual(value?.strSport, leagues.leagues?.last?.strSport)
            XCTAssertEqual(value?.strLeagueAlternate, leagues.leagues?.last?.strLeagueAlternate)
        } failure: { _ in
            XCTFail("error executed")
        }
        self.service.verify()
    }


    func testFetchLeagues_failure() {
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        let errorclosure = ArgumentClosureCaptor<ErrorCallBack>()
        self.service.expect().call(
            self.service.fetch(url: Arg.any(), success: successClosure.capture(), failure: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value?(DummyError.dummy)
        }
        self.leagueService.fetchLeagues { _ in
            XCTFail("success executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.service.verify()
    }
}
