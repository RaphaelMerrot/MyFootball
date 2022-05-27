//
//  League+MockUsable.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


extension League: MockUsable {
    
    private static var any = League(
        idLeague: "id",
        strLeague: "league",
        strSport: "sport",
        strLeagueAlternate: "lgue",
        isTeamsDownloaded: false
    )

    public static var anyValue: MockUsable {
        return League.any
    }


    public func equal(to value: MockUsable?) -> Bool {
        guard let val = value as? League else { return false }
        return self.idLeague == val.idLeague
            && self.strLeague == val.strLeague
            && self.strSport == val.strSport
            && self.strLeagueAlternate == val.strLeagueAlternate
            && self.isTeamsDownloaded == val.isTeamsDownloaded
    }
}
