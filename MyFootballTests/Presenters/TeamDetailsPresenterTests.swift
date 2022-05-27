//
//  TeamDetailsPresenterTests.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import XCTest
import InstantMock

@testable import MyFootball


final class TeamDetailsPresenterTests: XCTestCase {

    private enum DummyError: Error {
        case dummy
    }

    private var view: TeamDetailsViewPresenterMock!

    private var teamService: TeamServiceMock!


    override func setUp() {
        super.setUp()
        self.view = TeamDetailsViewPresenterMock()
        self.teamService = TeamServiceMock()
    }


    func testNoDataText() {
        let presenter = TeamDetailsPresenter(view: self.view, team: nil, teamService: self.teamService)
        XCTAssertEqual(presenter.noDataText, "Cannot load team data")
    }


    func testTitleView() {
        let team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        let presenter = TeamDetailsPresenter(view: self.view, team: team, teamService: self.teamService)
        XCTAssertEqual(presenter.titleView, team.strTeam)
    }


    func testTitleView_nil() {
        let presenter = TeamDetailsPresenter(view: self.view, team: nil, teamService: self.teamService)
        XCTAssertNil(presenter.titleView)
    }


    func testLeagueTitle_strLeague2() {
        let team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        let presenter = TeamDetailsPresenter(view: self.view, team: team, teamService: self.teamService)
        XCTAssertEqual(presenter.leagueTitle, team.strLeague2)
    }


    func testLeagueTitle_strLeague() {
        let team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: nil,
            strDescriptionEN: "Description EN",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        let presenter = TeamDetailsPresenter(view: self.view, team: team, teamService: self.teamService)
        XCTAssertEqual(presenter.leagueTitle, team.strLeague)
    }


    func testLeagueTitle_nil() {
        let presenter = TeamDetailsPresenter(view: self.view, team: nil, teamService: self.teamService)
        XCTAssertNil(presenter.leagueTitle)
    }


    func testViewDidLoad_noTeam() {
        self.view.expect().call(
            self.view.startSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.stopSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.onViewDidLoad(team: Arg.eq(nil), isNoDataLabelVisible: Arg.eq(true))
        )
        let presenter = TeamDetailsPresenter(view: self.view, team: nil, teamService: self.teamService)
        presenter.viewDidLoad()
        self.view.verify()
    }


    func testViewDidLoad_noStrTeamBanner() {
        let team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        self.view.expect().call(
            self.view.startSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.stopSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.onViewDidLoad(team: Arg.any(), isNoDataLabelVisible: Arg.eq(false))
        )
        let presenter = TeamDetailsPresenter(view: self.view, team: team, teamService: self.teamService)
        presenter.viewDidLoad()
        self.view.verify()
    }


    func testViewDidLoad_downloadBanner_success() {
        let successClosure = ArgumentClosureCaptor<DownloadSuccessCallBack>()
        let team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: "banner.jpeg"
        )
        self.view.expect().call(
            self.view.startSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.stopSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.onBannerDownloaded(data: Arg.any())
        )
        self.teamService.expect().call(
            self.teamService.downloadImage(from: Arg.any(), success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(Data())
        }

        let presenter = TeamDetailsPresenter(view: self.view, team: team, teamService: self.teamService)
        presenter.viewDidLoad()
        self.view.verify()
        self.teamService.verify()
    }


    func testViewDidLoad_downloadBanner_failure() {
        let errorClosure = ArgumentClosureCaptor<ErrorCallBack>()
        let team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: "banner.jpeg"
        )
        self.view.expect().call(
            self.view.startSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.stopSpinnerAnimation()
        )
        self.teamService.expect().call(
            self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: errorClosure.capture())
        ).andDo { _ in
            errorClosure.value?(DummyError.dummy)
        }

        let presenter = TeamDetailsPresenter(view: self.view, team: team, teamService: self.teamService)
        presenter.viewDidLoad()
        self.view.verify()
        self.teamService.verify()
    }
}
