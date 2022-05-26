//
//  LeagueService.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation


/// API call back
typealias LeaguesCallBack = ([League]?) -> Void


/** Service to retrieve a list of leagues */
protocol LeagueService {

    /** Retireve all soccer leagues */
    func fetchLeagues(success: @escaping LeaguesCallBack, failure: @escaping ErrorCallBack)

    /** Update league with another league */
    func updateLeague(leagues: inout [League]?, with league: League)
}


/** Main implementation of `LeagueService` */
final class LeagueServiceImpl: LeagueService {

    private enum SportType: String {
        case soccer = "Soccer"
    }

    /// JSON service dependency
    private let service: JSONService

    /// API's URL
    private let url = URL(string: API.url.rawValue + API.all_leagues.rawValue)


    init(service: JSONService = JSONServiceImpl()) {
        self.service = service
    }


    func fetchLeagues(success: @escaping LeaguesCallBack, failure: @escaping ErrorCallBack) {
        self.service.fetch(url: self.url) { (response: Leagues) in
            success(response.leagues?.filter { $0.strSport == SportType.soccer.rawValue } )
        } failure: { error in
            failure(error)
        }
    }


    func updateLeague(leagues: inout [League]?, with league: League) {
        if leagues == nil { return }
        guard let index = leagues?.firstIndex(where: { $0.idLeague == league.idLeague }) else { return }
        leagues?[index] = league
    }
}
