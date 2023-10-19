//
//  URL+Convenience.swift
//  smm-barcode
//
//  Created by Daniil on 20.03.2023.
//

import Foundation

extension URL {

    static var databaseDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Database")
    }

    static var pdfDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("PDFDocuments")
    }

    static func pdfDocument(name: String) -> URL {
        return pdfDocumentsDirectory.appendingPathComponent(name)
    }

}
