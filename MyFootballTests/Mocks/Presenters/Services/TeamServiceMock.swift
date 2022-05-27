//
//  TeamServiceMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball
import UIKit


final class TeamServiceMock: Mock, TeamService {

    func fetchTeams(from league: League, success: @escaping TeamsCallBack, failure: @escaping ErrorCallBack) {
        super.call(league, success, failure)
    }


    func downloadImage(from url: URL?, success: @escaping DownloadSuccessCallBack, failure: @escaping ErrorCallBack) {
        super.call(url, success, failure)
    }


    func update(teams: inout [Team]?, with team: inout Team, data: Data) {
        let service = TeamServiceImpl(service: JSONServiceMock())
        service.update(teams: &teams, with: &team, data: data)
    }

}
