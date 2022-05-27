//
//  MainPresenterViewMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


final class MainPresenterViewMock: Mock, MainPresenterView {

    func onViewDidLoad() {
        super.call()
    }


    func onSearch(_ isLabelVisible: Bool, _ isTableViewVisible: Bool, _ isCollectionViewVisible: Bool) {
        super.call(isLabelVisible, isTableViewVisible, isCollectionViewVisible)
    }


    func onBadgeDownloaded(index: Int) {
        super.call(index)
    }


    func onDismissKeyboard() {
        super.call()
    }


    func onRemoveCells(indexes: [IndexPath]) {
        super.call(indexes)
    }


    func onError(_ error: Error, title: String, actionTitle: String) {
        super.call(error, title, actionTitle)
    }

}
