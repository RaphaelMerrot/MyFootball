//
//  LeagueServiceMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


final class LeagueServiceMock: Mock, LeagueService {

    func fetchLeagues(success: @escaping LeaguesCallBack, failure: @escaping ErrorCallBack) {
        super.call(success, failure)
    }


    func updateLeague(leagues: inout [League]?, with league: League) {
        super.call(leagues, league)
    }
    
}
