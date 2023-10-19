//
//  String+DateFormatting.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 07.04.2023.
//

import Foundation

extension String {

    func getDate(_ dateFormat: String = Constants.dateFormat) -> Date? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let title = replacingOccurrences(of: Constants.fileNameSeparator, with: " ")
        let date = dateFormatter.date(from: title)
        return date
    }

}
