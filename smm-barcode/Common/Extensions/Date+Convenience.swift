//
//  Date+Convenience.swift
//  smm-barcode
//
//  Created by Daniil on 20.03.2023.
//

import Foundation

extension Date {

    var stringDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        let dateTitle = dateFormatter.string(from: self).replacingOccurrences(of: " ", with: Constants.fileNameSeparator)
        return dateTitle
    }

    var dateExceptTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: dateComponents) ?? self
    }

    func fileName(with fileExtension: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd_HH-MM-SS"
        let timestamp = dateFormatter.string(from: self)
        return "\(timestamp).\(fileExtension)"
    }

}
