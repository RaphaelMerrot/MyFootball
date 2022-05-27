//
//  TeamCellViewPresenterMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


final class TeamCellViewPresenterMock: Mock, TeamCellViewPresenter {

    func viewDidLoad(team: Team, isPlaceholderVisible: Bool) {
        super.call(team, isPlaceholderVisible)
    }


    func startSpinnerAnimation() {
        super.call()
    }


    func stopSpinnerAnimation() {
        super.call()
    }

}
