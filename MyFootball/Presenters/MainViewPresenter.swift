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

    func onSearch(_ isLabelVisible: Bool, _ isTableViewVisible: Bool, _ isCollectionViewVisible: Bool)

    func onBadgeDownloaded(index: Int)

    func onDismissKeyboard()

    func onRemoveCells(indexes: [IndexPath])

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

    /// Check if we don't have leagues
    private var isNoLeaguesFound: Bool {
        return self.filteredLeagues?.isEmpty ?? true
    }

    /// Check if we don't have teams
    private var isNoTeamsFound: Bool {
        return self.filteredTeams?.isEmpty ?? true
    }


    init(
        view: MainPresenterView,
        leagueService: LeagueService = LeagueServiceImpl(),
        teamService: TeamService = TeamServiceImpl()
    ) {
        self.view = view
        self.leagueService = leagueService
        self.teamService = teamService
    }


    /** Reset filtered teams */
    private func removeFilteredTeams() {
        guard let filteredTeams = self.filteredTeams else { return }
        if filteredTeams.count == 0 { return }
        var indexes = [IndexPath]()
        for (index, _) in filteredTeams.enumerated() {
            indexes.append(IndexPath(row: index, section: 0))
        }
        self.filteredTeams = nil
        self.view?.onRemoveCells(indexes: indexes)
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
        if self.isNoLeaguesFound {
            return "No leagues found"
        }

        if self.isNoTeamsFound {
            return "No teams found"
        }

        return ""
    }

    /// Placeholder of the search bar
    var searchBarPlaceholder: String {
        return "Search your league"
    }

    /// Number of rows in table view
    var numberOfRows: Int {
        return self.filteredLeagues?.count ?? 0
    }

    /// Number of items in collection view
    var numberOfItems: Int {
        return self.filteredTeams?.count ?? 0
    }


    /** View did load */
    func viewDidLoad() {
        self.loadLeaguesData()
    }


    /** Search a league */
    func search(searchText: String) {
        if searchText.isEmpty {
            self.removeFilteredTeams()
            self.filteredLeagues = nil
            self.view?.onSearch(false, false, false)
            return
        }

        // Trim seach text
        let searchText = searchText.trimmingCharacters(in: .whitespaces).lowercased()

        // Check if we have same value
        var previousSearch: League?
        if let leagues = self.filteredLeagues, leagues.count == 1 {
            previousSearch = leagues[0]
        }

        // Search leagues
        self.filteredLeagues = self.leagues?.filter { league in
            league.strLeague?.lowercased().contains(searchText) ?? false
                || league.strLeagueAlternate?.lowercased().contains(searchText) ?? false
        }

        // Search teams from league if we have one league
        if let filteredLeagues = self.filteredLeagues,
           filteredLeagues.count == 1,
           let league = filteredLeagues.first {
            if league.idLeague == previousSearch?.idLeague { return }
            self.loadTeamsData(from: league)
        } else {
            self.removeFilteredTeams()
            self.view?.onSearch(self.isNoLeaguesFound, !self.isNoLeaguesFound, false)
        }
    }


    /** Return the text of search bar (when you click on a league cell) */
    func searchBarText(for index: Int) -> String {
        return self.leagueName(for: index) ?? ""
    }


    /** Action when user click on a table view cell */
    func didSelectRow(at index: Int) {
        guard let league = self.filteredLeagues?[index] else { return }
        self.filteredLeagues = [league]
        self.filteredTeams = nil
        self.loadTeamsData(from: league)
    }


    /** Return the league name for an index */
    func leagueName(for index: Int) -> String? {
        let league = self.filteredLeagues?[index]
        return (league?.strLeagueAlternate?.isEmpty ?? false) ? league?.strLeague : league?.strLeagueAlternate
    }


    /** Return one team data */
    func teamData(for index: Int?) -> Team? {
        guard let index = index else {
            return nil
        }
        return self.filteredTeams?[index]
    }


    /** Define if we can perform segue or not */
    func shouldPerformSegue(for index: Int?) -> Bool {
        guard let index = index else {
            return false
        }
        return self.filteredTeams?[index] != nil
    }


    /** CallBack when all cells are deleted */
    func removeCellCompleted(isFinished: Bool) {
        if isFinished {
            self.view?.onSearch(self.isNoLeaguesFound, !self.isNoLeaguesFound, false)
        }
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
        // Remove cells
        self.removeFilteredTeams()

        // It's not necessary to download again teams
        if league.isTeamsDownloaded {
            self.filteredTeams = self.teams?.filter({ $0.idLeague == league.idLeague }).sorted(by: {
                $0.strTeam ?? "" < $1.strTeam ?? ""
            })
            self.view?.onSearch(self.isNoTeamsFound, false, !self.isNoTeamsFound)
            return
        }

        // Download Teams
        self.teamService.fetchTeams(from: league) { teams in
            // Check if the response is not nil
            guard let teams = teams else {
                self.view?.onSearch(true, false, false)
                return
            }

            // Check if we have teams in response
            guard teams.count > 0 else {
                self.view?.onSearch(true, false, false)
                return
            }

            // Save teams downloaded
            self.filteredTeams = teams.sorted(by: { $0.strTeam ?? "" < $1.strTeam ?? "" })

            // Dismiss keyboard
            self.view?.onDismissKeyboard()

            // Execute onSearch method
            self.view?.onSearch(false, false, true)

            // Mark that teams are downloaded
            var league = league
            league.isTeamsDownloaded = true
            self.leagueService.updateLeague(leagues: &self.leagues, with: league)

            // Load images
            self.loadBadges()
        } failure: { error in
            self.view?.onError(error, title: "Error", actionTitle: "Ok")
        }
    }


    /** Load badges */
    private func loadBadges() {
        guard let filteredTeams = self.filteredTeams else {
            self.view?.onSearch(true, false, false)
            return
        }
        for (index, var element) in filteredTeams.enumerated() {
            guard let url = element.strTeamBadge else { continue }
            element.isBadgeDownloaded = true
            self.teamService.downloadImage(from: URL(string: url)) { data in
                self.teamService.update(teams: &self.teams, with: &element, data: data)
                self.filteredTeams?[index] = element
                self.view?.onBadgeDownloaded(index: index)
            } failure: { error in
                self.view?.onBadgeDownloaded(index: index)
            }
        }
    }
}
