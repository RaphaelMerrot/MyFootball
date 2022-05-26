//
//  MainViewPresenter.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation


/** Main presenter delegate protocol */
protocol MainPresenterView: AnyObject {

    func onViewDidLoad()

    func onSearch(_ isLabelVisible: Bool, _ isTableViewVisible: Bool)

    func onError(_ error: Error, title: String, actionTitle: String)
}



/** Main presenter implementation */
final class MainPresenter {

    /// Delegate
    private weak var view: MainPresenterView?

    /// League service dependency
    private let leagueService: LeagueService

    /// Team service dependency
    private let teamService: TeamService

    /// Leagues downloaded
    private var leagues: [League]?

    /// Filtered leagues
    private var filteredLeagues: [League]?

    /// Teams downloaded
    private var teams: [Team]?

    /// Filtered teams
    private var filteredTeams: [Team]?


    init(
        view: MainPresenterView,
        leagueService: LeagueService = LeagueServiceImpl(),
        teamService: TeamService = TeamServiceImpl()
    ) {
        self.view = view
        self.leagueService = leagueService
        self.teamService = teamService
    }
}



// MARK: Public API

extension MainPresenter {

    /// View title
    var titleView: String {
        return "Welcome to MyFootball"
    }

    /// No data text label
    var textLabel: String {
        if self.filteredLeagues?.count ?? 0 == 1 && self.filteredTeams?.count ?? 0 == 0 {
            return "No teams found"
        }
        return "No leagues found"
    }

    /// Placeholder of the search bar
    var searchBarPlaceholder: String {
        return "Search your league"
    }

    /// Number of rows in table view
    var numberOfRows: Int {
        return self.filteredLeagues?.count ?? 0
    }


    /** View did load */
    func viewDidLoad() {
        self.loadLeaguesData()
    }


    /** Search a league */
    func search(searchText: String) {
        if searchText.isEmpty {
            self.filteredLeagues = nil
            self.view?.onSearch(false, false)
            return
        }

        // Search leagues
        self.filteredLeagues = self.leagues?.filter { league in
            league.strLeague?.contains(searchText) ?? false || league.strLeagueAlternate?.contains(searchText) ?? false
        }

        // Search teams from league if we have one league
        if let filteredLeagues = self.filteredLeagues, filteredLeagues.count == 1 {
            let league = filteredLeagues[0]
            self.loadTeamsData(from: league)
        } else {
            self.view?.onSearch(false, true)
        }
    }


    /** Return the text of search bar (when you click on a league cell) */
    func searchBarText(for index: Int) -> String {
        return self.leagueName(for: index) ?? ""
    }


    /** Return the league name for an index */
    func leagueName(for index: Int) -> String? {
        let league = self.filteredLeagues?[index]
        return (league?.strLeagueAlternate?.isEmpty ?? false) ? league?.strLeague : league?.strLeagueAlternate
    }
}



// MARK: Data

extension MainPresenter {

    /** Load leagues data */
    private func loadLeaguesData() {
        self.leagueService.fetchLeagues { leagues in
            self.leagues = leagues
            self.view?.onViewDidLoad()
        } failure: { error in
            self.view?.onError(error, title: "Error", actionTitle: "Ok")
        }
    }


    /** Load temas data */
    private func loadTeamsData(from league: League) {
        // It's not necessary to download again teams
        if league.isTeamsDownloaded {
            self.filteredTeams = self.teams?.filter { $0.idLeague == league.idLeague }
            self.view?.onSearch(false, false)
            return
        }

        // Download Teams
        self.teamService.fetchTeams(from: league) { teams in
            // Check if the response is not nil
            guard let teams = teams else {
                self.view?.onSearch(true, false)
                return
            }

            // Check if we have teams in response
            guard teams.count > 0 else {
                self.view?.onSearch(true, false)
                return
            }

            // Save teams downloaded
            if self.teams == nil {
                self.teams = []
            }
            self.teams?.append(contentsOf: teams)
            self.filteredTeams = teams
            self.view?.onSearch(false, false)
        } failure: { error in
            self.view?.onError(error, title: "Error", actionTitle: "Ok")
        }

    }
}
