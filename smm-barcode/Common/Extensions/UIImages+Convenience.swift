//
//  UIImages+Convenience.swift
//  smm-barcode
//
//  Created by Daniil on 24.03.2023.
//

import AVFoundation
import RSBarcodes_Swift
import UIKit

extension UIImage {

    static func barcode(data: String, type: String, size: CGSize) -> UIImage? {
        return RSUnifiedCodeGenerator.shared.generateCode(data, machineReadableCodeObjectType: type, targetSize: size)
    }

}
