//
//  Team.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation
import UIKit


/** Represent a list of teams */
struct Teams: Codable {

    let teams: [Team]?
}


/** Represent one team */
struct Team: Codable {

    private enum CodingKeys: String, CodingKey {
        case idTeam
        case idLeague
        case strTeam
        case strAlternate
        case strLeague
        case strLeague2
        case strDescriptionEN
        case strCountry
        case strTeamBadge
        case strTeamBanner
    }

    let idTeam: String

    let idLeague: String

    let strTeam: String?

    let strAlternate: String?

    let strLeague: String

    let strLeague2: String?

    let strDescriptionEN: String?

    let strCountry: String?

    let strTeamBadge: String?

    let strTeamBanner: String?

    var badge: UIImage?

    var isBadgeDownloaded: Bool = false
}
