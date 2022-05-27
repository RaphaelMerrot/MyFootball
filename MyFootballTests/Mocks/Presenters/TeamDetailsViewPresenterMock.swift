//
//  TeamDetailsViewPresenterMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


final class TeamDetailsViewPresenterMock: Mock, TeamDetailsViewPresenter {

    func onViewDidLoad(team: Team?, isNoDataLabelVisible: Bool) {
        super.call(team, isNoDataLabelVisible)
    }


    func onBannerDownloaded(data: Data) {
        super.call(data)
    }


    func startSpinnerAnimation() {
        super.call()
    }


    func stopSpinnerAnimation() {
        super.call()
    }

}
