//
//  TranslationMock.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import InstantMock

@testable import MyFootball


final class TranslationMock: Mock, Translation {

    var languageCode: String {
        return super.call() ?? "en"
    }


    func translate(for key: String) -> String {
        return super.call(key) ?? "translation"
    }
}
