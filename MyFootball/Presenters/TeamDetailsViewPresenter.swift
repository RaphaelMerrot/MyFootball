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

    func startSpinnerAnimation()

    func stopSpinnerAnimation()
}



/** Team details presenter implementation */
final class TeamDetailsPresenter {

    /// Delegate
    private weak var view: TeamDetailsViewPresenter?

    /// Team data
    private let team: Team?

    /// Team service dependency
    private let teamService: TeamService

    /// Translation tools
    private let translation: Translation


    init(
        view: TeamDetailsViewPresenter,
        team: Team?,
        teamService: TeamService = TeamServiceImpl(),
        translation: Translation = TranslationImpl()
    ) {
        self.view = view
        self.team = team
        self.teamService = teamService
        self.translation = translation
    }
}


// MARK: Public API

extension TeamDetailsPresenter {

    /// No data text
    var noDataText: String {
        return self.translation.translate(for: "teamNotLoaded")
    }

    /// Title view
    var titleView: String? {
        return self.team?.strTeam
    }

    ///  League title {
    var leagueTitle: String? {
        return self.team?.strLeague2 ?? self.team?.strLeague
    }

    ///  Description title {
    var decription: String? {
        if self.translation.languageCode == "en" {
            return self.team?.strDescriptionEN
        }
        return self.team?.strDescriptionFR ?? self.team?.strDescriptionEN
    }



    /** View did load */
    func viewDidLoad() {
        self.view?.startSpinnerAnimation()
        self.view?.onViewDidLoad(team: self.team, isNoDataLabelVisible: self.team == nil )
        self.loadBannerImageData()
    }
}



// MARK: Data
extension TeamDetailsPresenter {

    /** Load all badge data */
    private func loadBannerImageData() {
        guard let team = self.team else {
            self.view?.stopSpinnerAnimation()
            self.view?.onViewDidLoad(team: nil, isNoDataLabelVisible: true)
            return
        }
        guard let urlString = team.strTeamBanner else {
            self.view?.stopSpinnerAnimation()
            self.view?.onViewDidLoad(team: team, isNoDataLabelVisible: false)
            return
        }
        self.teamService.downloadImage(from: URL(string: urlString)) { data in
            self.view?.stopSpinnerAnimation()
            self.view?.onBannerDownloaded(data: data)
        } failure: { _ in
            self.view?.stopSpinnerAnimation()
        }
    }
}
