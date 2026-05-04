//
//  NormalizedCityKey.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 4.05.2026.
//

import Foundation

extension String {

    var normalizedCityKey: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "tr_TR"))
            .lowercased()
            .replacingOccurrences(of: "ı", with: "i")
    }

}
