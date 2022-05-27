//
//  TeamServiceTests.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import XCTest
import InstantMock

@testable import MyFootball


final class TeamServiceTests: XCTestCase {

    private enum DummyError: Error {
        case dummy
    }

    private var service: JSONServiceMock!

    private var teamService: TeamServiceImpl!


    override func setUp() {
        super.setUp()

        self.service = JSONServiceMock()
        self.teamService = TeamServiceImpl(service: self.service)
    }


    func testFetchTeams_success() {
        let league = League(idLeague: "1", strLeague: "French Ligue 1", strSport: "Soccer", strLeagueAlternate: "Ligue 1")
        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "42",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Description FR",
                strCountry: "France",
                strTeamBadge: "logo.png",
                strTeamBanner: nil
            )
        ])
        let successClosure = ArgumentClosureCaptor<SuccessCallBack<Teams>>()
        self.service.expect().call(
            self.service.fetch(url: Arg.any(), success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(teams)
        }
        self.teamService.fetchTeams(from: league) { data in
            XCTAssertEqual(data?.count, 1)
            let value = data?.first
            XCTAssertNotNil(value)
            XCTAssertEqual(value?.idTeam, teams.teams?.first?.idTeam)
            XCTAssertEqual(value?.idLeague, teams.teams?.first?.idLeague)
            XCTAssertEqual(value?.strTeam, teams.teams?.first?.strTeam)
            XCTAssertEqual(value?.strAlternate, teams.teams?.first?.strAlternate)
            XCTAssertEqual(value?.strLeague, teams.teams?.first?.strLeague)
            XCTAssertEqual(value?.strLeague2, teams.teams?.first?.strLeague2)
            XCTAssertEqual(value?.strDescriptionEN, teams.teams?.first?.strDescriptionEN)
            XCTAssertEqual(value?.strCountry, teams.teams?.first?.strCountry)
            XCTAssertEqual(value?.strTeamBadge, teams.teams?.first?.strTeamBadge)
            XCTAssertNil(value?.strTeamBanner)
        } failure: { _ in
            XCTFail("error executed")
        }
        self.service.verify()
    }


    func testFetchTeams_failure() {
        let league = League(idLeague: "1", strLeague: "French Ligue 1", strSport: "Soccer", strLeagueAlternate: "Ligue 1")
        let successClosure = ArgumentClosureCaptor<TeamsCallBack>()
        let errorclosure = ArgumentClosureCaptor<ErrorCallBack>()
        self.service.expect().call(
            self.service.fetch(url: Arg.any(), success: successClosure.capture(), failure: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value?(DummyError.dummy)
        }
        self.teamService.fetchTeams(from: league) { _ in
            XCTFail("success executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.service.verify()
    }


    func testFetchTeams_failure_noFilter() {
        let league = League(idLeague: "1", strLeague: nil, strSport: "Soccer", strLeagueAlternate: "Ligue 1")
        let successClosure = ArgumentClosureCaptor<TeamsCallBack>()
        let errorclosure = ArgumentClosureCaptor<ErrorCallBack>()
        self.service.expect().call(
            self.service.fetch(url: Arg.any(), success: successClosure.capture(), failure: errorclosure.capture())
        ).andDo { _ in
            errorclosure.value?(DummyError.dummy)
        }
        self.teamService.fetchTeams(from: league) { _ in
            XCTFail("success executed")
        } failure: { error in
            XCTAssertNotNil(error)
        }
        self.service.verify()
    }


    func testDownloadImage_success() {
        let url = URL(string: "customURL")
        let expectedData = Data()
        let successClosure = ArgumentClosureCaptor<DownloadSuccessCallBack>()
        self.service.expect().call(
            self.service.downloadImage(url: Arg.any(), success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(expectedData)
        }

        self.teamService.downloadImage(from: url) { data in
            XCTAssertEqual(data, expectedData)
        } failure: { _ in
            XCTFail("error executed")
        }
        self.service.verify()
    }


    func testDownloadImage_failure() {
        let url = URL(string: "customURL")
        let errorClosure = ArgumentClosureCaptor<ErrorCallBack>()
        self.service.expect().call(
            self.service.downloadImage(url: Arg.any(), success: Arg.closure(), failure: errorClosure.capture())
        ).andDo { _ in
            errorClosure.value?(DummyError.dummy)
        }

        self.teamService.downloadImage(from: url) { _ in
            XCTFail("success executed")
        } failure: { error in
            XCTAssertTrue(error is DummyError)
        }
        self.service.verify()
    }


    func testUpdate() {
        var teams:[Team]? = [
            Team(
                idTeam: "1",
                idLeague: "42",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Description FR",
                strCountry: "France",
                strTeamBadge: "logo.png",
                strTeamBanner: "banner.jpeg"
            )
        ]
        var team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strDescriptionFR: "Description FR",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: "banner.jpeg"
        )
        let data = UIImage(systemName: "house")!.pngData()!
        self.teamService.update(teams: &teams, with: &team, data: data)
        XCTAssertEqual(teams?.count, 1)
        XCTAssertNotNil(teams?.first?.badge)
    }


    func testUpdate_teamsIsNil() {
        var teams:[Team]? = nil
        var team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strDescriptionFR: "Description FR",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: "banner.jpeg"
        )
        let data = UIImage(systemName: "house")!.pngData()!
        self.teamService.update(teams: &teams, with: &team, data: data)
        XCTAssertEqual(teams?.count, 1)
        XCTAssertNotNil(teams?.first?.badge)
    }


    func testUpdate_indexNotFount() {
        var teams:[Team]? = [
            Team(
                idTeam: "2",
                idLeague: "42",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Description FR",
                strCountry: "France",
                strTeamBadge: "logo.png",
                strTeamBanner: "banner.jpeg"
            )
        ]
        var team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strDescriptionFR: "Description FR",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: "banner.jpeg"
        )
        let data = UIImage(systemName: "house")!.pngData()!
        self.teamService.update(teams: &teams, with: &team, data: data)
        XCTAssertEqual(teams?.count, 2)
        XCTAssertNil(teams?.first?.badge)
        XCTAssertNotNil(teams?.last?.badge)
    }
}
