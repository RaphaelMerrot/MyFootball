//
//  TeamService.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import UIKit


/// API call back
typealias TeamsCallBack = ([Team]?) -> Void


/** Service to retrieve a list of teams */
protocol TeamService {

    /** Retrieve all teams from a league */
    func fetchTeams(from league: League, success: @escaping TeamsCallBack, failure: @escaping ErrorCallBack)

    /** Retrieve image data from url */
    func downloadImage(from url: URL?, success: @escaping DownloadSuccessCallBack, failure: @escaping ErrorCallBack)

    /** Update team data */
    func update(teams: inout [Team]?, with team: inout Team, data: Data)
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


    func downloadImage(from url: URL?, success: @escaping DownloadSuccessCallBack, failure: @escaping ErrorCallBack) {
        self.service.downloadImage(url: url) { data in
            success(data)
        } failure: { error in
            failure(error)
        }
    }


    func update(teams: inout [Team]?, with team: inout Team, data: Data) {
        team.badge = UIImage(data: data)
        if teams == nil { teams = [Team]() }
        guard let index = teams?.firstIndex(where: { $0.idTeam == team.idTeam }) else {
            teams?.append(team)
            return
        }
        teams?[index] = team
    }


    /** Generate the url from the league */
    private func url(league: League) -> URL? {
        guard let filter = league.strLeague?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: API.url.rawValue + API.search_all_teams.rawValue + filter)
    }
}
