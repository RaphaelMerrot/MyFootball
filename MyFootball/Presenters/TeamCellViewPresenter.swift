//
//  TeamCellViewPresenter.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation


/** Team cell presenter delegate protocol */
protocol TeamCellViewPresenter: AnyObject {

    func viewDidLoad(team: Team, isPlaceholderVisible: Bool)

    func startSpinnerAnimation()

    func stopSpinnerAnimation()
}



/** Team cell presenter implementation */
final class TeamCellPresenter {

    /// Delegate
    private weak var view: TeamCellViewPresenter?

    /// Team data
    private let team: Team

    /// Check if placeholder must be visible or not
    private var isPlaceholderVisible: Bool {
        return self.team.isBadgeDownloaded && self.team.badge == nil
    }


    init?(view: TeamCellViewPresenter, team: Team?) {
        guard let team = team else {
            return nil
        }
        self.view = view
        self.team = team
    }


    /** View did load */
    func viewDidLoad() {
        if self.team.isBadgeDownloaded {
            self.view?.stopSpinnerAnimation()
        } else {
            self.view?.startSpinnerAnimation()
        }
        self.view?.viewDidLoad(team: team, isPlaceholderVisible: self.isPlaceholderVisible)
    }
}


// MARK: Public API

extension TeamCellPresenter {

    /// Placeholder
    var placeholder: String? {
        return team.isBadgeDownloaded && team.badge == nil ? team.strTeam : nil
    }
}
