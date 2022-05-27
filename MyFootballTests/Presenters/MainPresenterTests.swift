//
//  MainPresenterTests.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import XCTest
import InstantMock

@testable import MyFootball


final class MainPresenterTests: XCTestCase {

    private enum DummyError: Error {
        case dummy
    }

    private var view: MainPresenterViewMock!

    private var leagueService: LeagueServiceMock!

    private var teamService: TeamServiceMock!

    private var presenter: MainPresenter!

    private var translation: TranslationMock!


    override func setUp() {
        super.setUp()

        self.view = MainPresenterViewMock()
        self.leagueService = LeagueServiceMock()
        self.teamService = TeamServiceMock()
        self.translation = TranslationMock()
        self.presenter = MainPresenter(
            view: self.view,
            leagueService: self.leagueService,
            teamService: self.teamService,
            translation: self.translation
        )
    }


    func testTitleView() {
        let title = self.presenter.titleView
        XCTAssertEqual(title, self.translation.translate(for: "welcome"))
    }


    func testSearchBarPlaceHolder() {
        let placeholder = self.presenter.searchBarPlaceholder
        XCTAssertEqual(placeholder, self.translation.translate(for: "searchPlaceholder"))
    }


    func testTextLabel_isNoLeaguesFound() {
        let textLabel = self.presenter.textLabel
        XCTAssertEqual(textLabel, self.translation.translate(for: "noLeaguesFound"))
    }


    func testTextLabel_isNoTeamsFound() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: true)
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test")
        let textLabel = self.presenter.textLabel
        XCTAssertEqual(textLabel, self.translation.translate(for: "noTeamsFound"))
    }


    
    func testTextLabel_empty() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: nil,
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
        let text = self.presenter.textLabel
        XCTAssertEqual(text, "")
    }


    func testNumberOfRows_filteredLeaguesNil() {
        let numberOfRows = self.presenter.numberOfRows
        XCTAssertEqual(numberOfRows, 0)
    }


    func testnumberOfItems_filteredTeamsNil() {
        let numberOfItems = self.presenter.numberOfItems
        XCTAssertEqual(numberOfItems, 0)
    }


    func testRemoveCellCompleted() {
        self.view.expect().call(
            self.view.onSearch(Arg.any(), Arg.any(), Arg.any())
        )
        self.presenter.removeCellCompleted(isFinished: true)
        self.view.verify()
    }


    func testRemoveCellCompleted_notFinished() {
        self.view.expect().call(
            self.view.onSearch(Arg.any(), Arg.any(), Arg.any()),
            count: 0
        )
        self.presenter.removeCellCompleted(isFinished: false)
        self.view.verify()
    }


    func testViewDidLoad_loadLeaguesData_success() {
        let leagues = Leagues(leagues: nil)
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.view.verify()
    }


    func testViewDidLoad_loadLeaguesData_error() {
        let errorClosure = ArgumentClosureCaptor<ErrorCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: Arg.closure(), failure: errorClosure.capture())
        ).andDo { _ in
            errorClosure.value?(DummyError.dummy)
        }
        self.view.expect().call(
            self.view.onViewDidLoad(),
            count: 0
        )
        self.presenter.viewDidLoad()
        self.view.verify()
    }


    func testDidSelectRow_noFilteredLeagues() {
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
            count: 0
        )
        self.presenter.didSelectRow(at: 0)
        self.teamService.verify()
    }


    func testDidSelectRow() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Description FR",
                strCountry: "France",
                strTeamBadge: nil,
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()

        let leagues2 = Leagues(leagues: [
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: true)
        ])
        let successLeagueClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successLeagueClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successLeagueClosure.value?(leagues2.leagues)
        }
        self.view.expect().call(
            self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
        )
        self.presenter.didSelectRow(at: 0)
        self.view.verify()
    }


    func testSearchBarText_empty() {
        let leagues = Leagues(leagues: nil)
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test")
        let leagueName = self.presenter.searchBarText(for: 0)
        XCTAssertEqual(leagueName, "")
    }


    func testLeagueName() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "testAlt", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: true)
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test")
        let leagueName = self.presenter.leagueName(for: 0)
        XCTAssertEqual(leagueName, "testAlt")
    }


    func testLeagueName_nil() {
        let leagues = Leagues(leagues: nil)
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test")
        let leagueName = self.presenter.leagueName(for: 0)
        XCTAssertNil(leagueName)
    }


    func testTeamData() {
        func testSearchText_loadTeams_success() {
            let leagues = Leagues(leagues: [
                League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
                League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
            ])

            let teams = Teams(teams: [
                Team(
                    idTeam: "1",
                    idLeague: "2",
                    strTeam: "Team",
                    strAlternate: "Alternate team",
                    strLeague: "League",
                    strLeague2: "League 2",
                    strDescriptionEN: "Description EN",
                    strDescriptionFR: "Descitpion FR",
                    strCountry: "France",
                    strTeamBadge: nil,
                    strTeamBanner: "banner.jpeg"
                )
            ])
            let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
            self.leagueService.expect().call(
                self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
            ).andDo { _ in
                successClosure.value?(leagues.leagues)
            }

            let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
            self.teamService.expect().call(
                self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
            ).andDo { _ in
                self.view.expect().call(
                    self.view.onDismissKeyboard()
                )
                self.view.expect().call(
                    self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
                )

                self.teamService.expect().call(
                    self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                    count: 0
                )
                successTeamClosure.value?(teams.teams)
            }
            self.view.expect().call(self.view.onViewDidLoad())
            self.presenter.viewDidLoad()
            self.presenter.search(searchText: "test2")
            self.view.verify()
            self.leagueService.verify()
            self.teamService.verify()
            let team = self.presenter.teamData(for: 0)
            XCTAssertNotNil(team)
        }
    }


    func testTeamData_noIndex() {
        let team = self.presenter.teamData(for: nil)
        XCTAssertNil(team)
    }


    func testTeamData_noFilteredTeams() {
        let team = self.presenter.teamData(for: 0)
        XCTAssertNil(team)
    }


    func testshouldPerformSegue() {
        func testSearchText_loadTeams_success() {
            let leagues = Leagues(leagues: [
                League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
                League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
            ])

            let teams = Teams(teams: [
                Team(
                    idTeam: "1",
                    idLeague: "2",
                    strTeam: "Team",
                    strAlternate: "Alternate team",
                    strLeague: "League",
                    strLeague2: "League 2",
                    strDescriptionEN: "Description EN",
                    strDescriptionFR: "Descitpion FR",
                    strCountry: "France",
                    strTeamBadge: nil,
                    strTeamBanner: "banner.jpeg"
                )
            ])
            let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
            self.leagueService.expect().call(
                self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
            ).andDo { _ in
                successClosure.value?(leagues.leagues)
            }

            let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
            self.teamService.expect().call(
                self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
            ).andDo { _ in
                self.view.expect().call(
                    self.view.onDismissKeyboard()
                )
                self.view.expect().call(
                    self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
                )

                self.teamService.expect().call(
                    self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                    count: 0
                )
                successTeamClosure.value?(teams.teams)
            }
            self.view.expect().call(self.view.onViewDidLoad())
            self.presenter.viewDidLoad()
            self.presenter.search(searchText: "test2")
            self.view.verify()
            self.leagueService.verify()
            self.teamService.verify()
            let shouldPerform = self.presenter.shouldPerformSegue(for: 0)
            XCTAssertTrue(shouldPerform)
        }
    }


    func testShouldPerformSegue_noIndex() {
        let shouldPerform = self.presenter.shouldPerformSegue(for: nil)
        XCTAssertFalse(shouldPerform)
    }


    func testShouldPerformSegue_noFilteredTeams() {
        let shouldPerform = self.presenter.shouldPerformSegue(for: 0)
        XCTAssertFalse(shouldPerform)
    }


    func testLeagueName_strLeagueAlternate_nil() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: nil, isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: true)
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test")
        let leagueName = self.presenter.leagueName(for: 0)
        XCTAssertEqual(leagueName, "test")
    }


    func testSearchText_lisEmpty() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
            count: 0
        )
        self.view.expect().call(
            self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(false))
        )
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }


    func testSearchText_sameSearch() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: nil,
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()

        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
            count: 0
        )
        self.presenter.search(searchText: "test2")
        self.teamService.verify()
    }


    func testSearchText_leagues_filter() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: nil, strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false),
            League(idLeague: "3", strLeague: nil, strSport: "Soccer", strLeagueAlternate: nil, isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: nil,
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }


    func testSearchText_loadTeams_success() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: nil,
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }


    func testSearchText_loadTeams_failure() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let errorTeamClosure = ArgumentClosureCaptor<ErrorCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: Arg.closure(), failure: errorTeamClosure.capture())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard(),
                count: 0
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true)),
                count: 0
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            errorTeamClosure.value?(DummyError.dummy)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }


    func testSearchText_loadTeams_nil() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: nil)
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onSearch(Arg.eq(true), Arg.eq(false), Arg.eq(false))
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }


    func testSearchText_loadTeams_empty() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: [])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onSearch(Arg.eq(true), Arg.eq(false), Arg.eq(false))
            )

            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: Arg.closure()),
                count: 0
            )
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }


    func testSearchText_loadTeams_isAlreadyDownloaded_noTeams() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: true)
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        self.view.expect().call(
            self.view.onSearch(Arg.eq(true), Arg.eq(false), Arg.eq(false))
        )
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
    }


    func testSearchText_loadTeams_isAlreadyDownloaded_withTeams() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false),
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: "badges.png",
                strTeamBanner: "banner.jpeg"
            ),
            Team(
                idTeam: "2",
                idLeague: "2",
                strTeam: nil,
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: "badges.png",
                strTeamBanner: "banner.jpeg"
            ),
            Team(
                idTeam: "3",
                idLeague: "2",
                strTeam: nil,
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: "badges.png",
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.stub().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            let successImageClosure = ArgumentClosureCaptor<DownloadSuccessCallBack>()
            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: successImageClosure.capture(), failure: Arg.closure())
            ).andDo { _ in
                self.view.expect().call(
                    self.view.onBadgeDownloaded(index: Arg.any())
                )
                successImageClosure.value?(Data())
            }
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()

        self.presenter.search(searchText: "test2m")
        self.view.expect().call(
            self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
        )
        self.presenter.search(searchText: "test2")
        self.view.verify()
    }


    func testSearchText_loadTeams_withBadges() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false),
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: "badges.png",
                strTeamBanner: "banner.jpeg"
            ),
            Team(
                idTeam: "2",
                idLeague: "2",
                strTeam: nil,
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: "badges.png",
                strTeamBanner: "banner.jpeg"
            ),
            Team(
                idTeam: "3",
                idLeague: "2",
                strTeam: nil,
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: "badges.png",
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            let successImageClosure = ArgumentClosureCaptor<DownloadSuccessCallBack>()
            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: successImageClosure.capture(), failure: Arg.closure())
            ).andDo { _ in
                self.view.expect().call(
                    self.view.onBadgeDownloaded(index: Arg.any())
                )
                successImageClosure.value?(Data())
            }
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }


    func testSearchText_loadTeams_withBadges_failure() {
        let leagues = Leagues(leagues: [
            League(idLeague: "1", strLeague: "test", strSport: "Soccer", strLeagueAlternate: "test", isTeamsDownloaded: true),
            League(idLeague: "2", strLeague: "test2", strSport: "Soccer", strLeagueAlternate: "test2", isTeamsDownloaded: false)
        ])

        let teams = Teams(teams: [
            Team(
                idTeam: "1",
                idLeague: "2",
                strTeam: "Team",
                strAlternate: "Alternate team",
                strLeague: "League",
                strLeague2: "League 2",
                strDescriptionEN: "Description EN",
                strDescriptionFR: "Descitpion FR",
                strCountry: "France",
                strTeamBadge: "badges.png",
                strTeamBanner: "banner.jpeg"
            )
        ])
        let successClosure = ArgumentClosureCaptor<LeaguesCallBack>()
        self.leagueService.expect().call(
            self.leagueService.fetchLeagues(success: successClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            successClosure.value?(leagues.leagues)
        }

        let successTeamClosure = ArgumentClosureCaptor<TeamsCallBack>()
        self.teamService.expect().call(
            self.teamService.fetchTeams(from: Arg.any(), success: successTeamClosure.capture(), failure: Arg.closure())
        ).andDo { _ in
            self.view.expect().call(
                self.view.onDismissKeyboard()
            )
            self.view.expect().call(
                self.view.onSearch(Arg.eq(false), Arg.eq(false), Arg.eq(true))
            )

            let errorImageClosure = ArgumentClosureCaptor<ErrorCallBack>()
            self.teamService.expect().call(
                self.teamService.downloadImage(from: Arg.any(), success: Arg.closure(), failure: errorImageClosure.capture())
            ).andDo { _ in
                self.view.expect().call(
                    self.view.onBadgeDownloaded(index: Arg.eq(0))
                )
                errorImageClosure.value?(DummyError.dummy)
            }
            successTeamClosure.value?(teams.teams)
        }
        self.view.expect().call(self.view.onViewDidLoad())
        self.presenter.viewDidLoad()
        self.presenter.search(searchText: "test2")
        self.view.verify()
        self.leagueService.verify()
        self.teamService.verify()
    }

}
