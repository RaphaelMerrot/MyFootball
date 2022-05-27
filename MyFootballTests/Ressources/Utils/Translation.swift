//
//  Translation.swift
//  MyFootballTests
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation
import XCTest
import InstantMock

@testable import MyFootball


final class TranslationTests: XCTestCase {

    private var translation: TranslationImpl!


    override func setUp() {
        super.setUp()

        self.translation = TranslationImpl()
    }


    func testLanguageCode() {
        let code = Locale.current.languageCode
        XCTAssertEqual(code, self.translation.languageCode)
    }


    func testTranslate() {
        let string = NSLocalizedString("welcome", comment: "")
        XCTAssertEqual(string, self.translation.translate(for: "welcome"))
    }
}
