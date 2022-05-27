//
//  Translation.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 27/05/2022.
//

import Foundation


/** Translation tools */
protocol Translation {

    /// Retrieve the language code
    var languageCode: String { get }

    /** Retrieve a translation for a key provided */
    func translate(for key: String) -> String
}



/** Main implementation of `Translations` */
final class TranslationImpl: Translation {

    var languageCode: String {
        return NSLocalizedString("languageCode", comment: "language code")
    }


    func translate(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
