//
//  TeamService.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation


/// API call back
typealias TeamsCallBack = ([Team]?) -> Void


/** Service to retrieve a list of teams */
protocol TeamService {

    /** Retrieve all teams from a league */
    func fetchTeams(from league: League, success: @escaping TeamsCallBack, failure: @escaping ErrorCallBack)
}



/** Main implementation if `TeamService` */
final class TeamServiceImpl: TeamService {

    /// JSON service dependency
    private let service: JSONService


    init(service: JSONService = JSONServiceImpl()) {
        self.service = service
    }


    func fetchTeams(from league: League, success: @escaping TeamsCallBack, failure: @escaping ErrorCallBack) {
        self.service.fetch(url: self.url(league: league)) { (response: Teams) in
            success(response.teams)
        } failure: { error in
            failure(error)
        }
    }


    /** Generate the url from the league */
    private func url(league: League) -> URL? {
        guard let filter = league.strLeague?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: API.url.rawValue + API.search_all_teams.rawValue + filter)
    }
}
