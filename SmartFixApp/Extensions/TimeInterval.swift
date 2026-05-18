//
//  TimeInterval.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 18.05.2026.
//

import Foundation

extension TimeInterval {

    var chatTimeStringTR: String {
        let date = Date(timeIntervalSince1970: self)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        formatter.locale = Locale(identifier: "tr_TR")

        return formatter.string(from: date)
    }
    
}


extension TimeInterval {

    var chatDayStringTR: String {
        let date = Date(timeIntervalSince1970: self)
        let calendar = Calendar(identifier: .gregorian)

        if calendar.isDateInToday(date) {
            return "Bugün"
        }

        if calendar.isDateInYesterday(date) {
            return "Dün"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        formatter.dateFormat = "EEEE"

        return formatter.string(from: date).capitalized
    }
}
