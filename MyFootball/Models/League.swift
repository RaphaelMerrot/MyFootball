//
//  League.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation


/** Represent a list of leagues */
struct Leagues: Codable {

    let leagues: [League]?
}


/** Represent on league */
struct League: Codable {

    private enum CodingKeys: String, CodingKey {
        case idLeague, strLeague, strSport, strLeagueAlternate
    }

    let idLeague: String

    let strLeague: String?

    let strSport: String?

    let strLeagueAlternate: String?

    var isTeamsDownloaded: Bool = false
}
