//
//  ScanModel.swift
//  smm-barcode
//
//  Created by Daniil on 21.03.2023.
//

import Foundation

struct ScanModel: Encodable, Decodable {

    enum ScanType: String, Encodable, Decodable, CaseIterable {
        case qr
        case barcode
        case product
        case pdf
    }

    let id: Int
    let type: ScanType
    let date: Date
    let dataFormat: String // | org.iso.QRCode | org.iso.EAN-13 | "path" | etc.
    let data: String // data of barcode | data of QR | pdf's path

    var element: String {
        dataFormat.components(separatedBy: ["."]).last ?? ""
    }

}
