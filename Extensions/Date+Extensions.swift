//
//  Date+Extensions.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 13/04/2022.
//

import Foundation

extension Date {
    func convertDateToString(to dateFormat: String = "YY/MM/dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
