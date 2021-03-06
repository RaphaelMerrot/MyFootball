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

    private var translation: TranslationMock!


    override func setUp() {
        super.setUp()
        self.view = TeamDetailsViewPresenterMock()
        self.teamService = TeamServiceMock()
        self.translation = TranslationMock()
    }


    func testNoDataText() {
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: nil,
            teamService: self.teamService,
            translation: self.translation
        )
        XCTAssertEqual(presenter.noDataText, self.translation.translate(for: "teamNotLoaded"))
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
            strDescriptionFR: "Description FR",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
        XCTAssertEqual(presenter.titleView, team.strTeam)
    }


    func testTitleView_nil() {
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: nil,
            teamService: self.teamService,
            translation: self.translation
        )
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
            strDescriptionFR: "Description FR",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
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
            strDescriptionFR: "Descitpion FR",
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
        XCTAssertEqual(presenter.leagueTitle, team.strLeague)
    }


    func testLeagueTitle_nil() {
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: nil,
            teamService: self.teamService,
            translation: self.translation
        )
        XCTAssertNil(presenter.leagueTitle)
    }


    func testDescription_en() {
        let team = Team(
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
        self.translation.stub().call(self.translation.languageCode).andReturn("en")
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
        XCTAssertEqual(team.strDescriptionEN, presenter.decription)
    }


    func testDescription_fr() {
        let team = Team(
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
        self.translation.stub().call(self.translation.languageCode).andReturn("fr")
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
        XCTAssertEqual(team.strDescriptionFR, presenter.decription)
    }


    func testDescription_fr_default_english() {
        let team = Team(
            idTeam: "1",
            idLeague: "42",
            strTeam: "Team",
            strAlternate: "Alternate team",
            strLeague: "League",
            strLeague2: "League 2",
            strDescriptionEN: "Description EN",
            strDescriptionFR: nil,
            strCountry: "France",
            strTeamBadge: "logo.png",
            strTeamBanner: nil
        )
        self.translation.stub().call(self.translation.languageCode).andReturn("fr")
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
        XCTAssertEqual(team.strDescriptionEN, presenter.decription)
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
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: nil,
            teamService: self.teamService,
            translation: self.translation
        )
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
            strDescriptionFR: "Description FR",
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
        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
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
            strDescriptionFR: "Description FR",
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

        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
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
            strDescriptionFR: "Description FR",
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

        let presenter = TeamDetailsPresenter(
            view: self.view,
            team: team,
            teamService: self.teamService,
            translation: self.translation
        )
        presenter.viewDidLoad()
        self.view.verify()
        self.teamService.verify()
    }
}
