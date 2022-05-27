//
//  Team+MockUsable.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


extension Team: MockUsable {
    
    private static var any = Team(
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

    public static var anyValue: MockUsable {
        return Team.any
    }


    public func equal(to value: MockUsable?) -> Bool {
        guard let val = value as? Team else { return false }
        return self.idTeam == val.idTeam
            && self.idLeague == val.idLeague
            && self.strTeam == val.strTeam
            && self.strAlternate == val.strAlternate
            && self.strLeague == val.strLeague
            && self.strLeague2 == val.strLeague2
            && self.strDescriptionEN == val.strDescriptionEN
            && self.strCountry == val.strCountry
            && self.strTeamBadge == val.strTeamBadge
            && self.strTeamBanner == val.strTeamBanner
            && self.isBadgeDownloaded == val.isBadgeDownloaded
    }
}
