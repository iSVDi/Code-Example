//
//  AVMetadataObject+Convenience.swift
//  smm-barcode
//
//  Created by Daniil on 13.03.2023.
//

import AVFoundation
import Foundation

extension AVMetadataObject {

    func value() -> String? {
        guard let readableObject = self as? AVMetadataMachineReadableCodeObject else {
            return nil
        }
        guard let stringValue = readableObject.stringValue else {
            return nil
        }
        return stringValue
    }

}
