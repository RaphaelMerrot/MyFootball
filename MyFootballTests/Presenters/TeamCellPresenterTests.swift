//
//  TeamCellPresenterTests.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import XCTest
import InstantMock

@testable import MyFootball


final class TeamCellPresenterTests: XCTestCase {

    private var view: TeamCellViewPresenterMock!


    override func setUp() {
        super.setUp()

        self.view = TeamCellViewPresenterMock()
    }


    func testInstance() {
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
        let presenter = TeamCellPresenter(view: self.view, team: team)
        XCTAssertNotNil(presenter)
    }


    func testInstance_nil() {
        let presenter = TeamCellPresenter(view: self.view, team: nil)
        XCTAssertNil(presenter)
    }


    func testViewDidLoad_isBadgeDownloaded() {
        var team = Team(
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
        team.isBadgeDownloaded = true
        self.view.expect().call(
            self.view.stopSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.viewDidLoad(team: Arg.eq(team), isPlaceholderVisible: Arg.eq(true))
        )
        let presenter = TeamCellPresenter(view: self.view, team: team)
        presenter?.viewDidLoad()
        self.view.verify()
    }


    func testViewDidLoad_isBadgeNotDownloaded() {
        var team = Team(
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
        team.isBadgeDownloaded = false
        team.badge = UIImage()
        self.view.expect().call(
            self.view.startSpinnerAnimation()
        )
        self.view.expect().call(
            self.view.viewDidLoad(team: Arg.eq(team), isPlaceholderVisible: Arg.eq(false))
        )
        let presenter = TeamCellPresenter(view: self.view, team: team)
        presenter?.viewDidLoad()
        self.view.verify()
    }


    func testPlaceHaloder() {
        var team = Team(
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
        team.isBadgeDownloaded = true
        team.badge = nil
        let presenter = TeamCellPresenter(view: self.view, team: team)
        XCTAssertEqual(presenter?.placeholder, team.strTeam)
    }

    func testPlaceHaloder_nil() {
        var team = Team(
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
        team.isBadgeDownloaded = false
        team.badge = nil
        let presenter = TeamCellPresenter(view: self.view, team: team)
        XCTAssertNil(presenter?.placeholder)
    }
}
