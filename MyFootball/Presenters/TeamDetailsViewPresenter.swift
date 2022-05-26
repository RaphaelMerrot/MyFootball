//
//  TeamDetailsViewPresenter.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation


/** Team details presenter delegate protocol */
protocol TeamDetailsViewPresenter: AnyObject {

    func onViewDidLoad(team: Team?, isNoDataLabelVisible: Bool)

    func onBannerDownloaded(data: Data)
}



/** Team details presenter implementation */
final class TeamDetailsPresenter {

    /// Delegate
    private weak var view: TeamDetailsViewPresenter?

    /// Team data
    private let team: Team?

    /// Team service dependency
    private let teamService: TeamService


    init(
        view: TeamDetailsViewPresenter,
        team: Team?,
        teamService: TeamService = TeamServiceImpl()
    ) {
        self.view = view
        self.team = team
        self.teamService = teamService
    }
}


// MARK: Public API

extension TeamDetailsPresenter {

    /// No data text
    var noDataText: String {
        return "Cannot load team data"
    }

    /// Title view
    var titleView: String? {
        self.team?.strTeam
    }


    /** View did load */
    func viewDidLoad() {
        guard let team = team else {
            self.view?.onViewDidLoad(team: nil, isNoDataLabelVisible: true)
            return
        }
        self.loadBannerImageData()
        self.view?.onViewDidLoad(team: team, isNoDataLabelVisible: false)
    }
}



// MARK: Data
extension TeamDetailsPresenter {

    /** Load all badge data */
    private func loadBannerImageData() {
        guard let team = self.team else {
            self.view?.onViewDidLoad(team: nil, isNoDataLabelVisible: true)
            return
        }
        guard let urlString = team.strTeamBanner else {
            self.view?.onViewDidLoad(team: team, isNoDataLabelVisible: false)
            return
        }
        self.teamService.downloadImage(from: URL(string: urlString)) { data in
            self.view?.onBannerDownloaded(data: data)
        } failure: { error in
            print(error.localizedDescription)
        }
    }
}
