//
//  UIImage+BarcodeRecognition.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 12.04.2023.
//

import AVFoundation
import UIKit
import Vision

// RSBarcodes_Swift has limited list of supported formats, we should detect codes of this formats only
extension VNBarcodeSymbology {

    var avCodeType: AVMetadataObject.ObjectType? {
        switch self {
        case .code39, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum:
            return .code39
        case .code93:
            return .code93
        case .code128:
            return .code128
        case .upce:
            return .upce
        case .ean8:
            return .ean8
        case .ean13:
            return .ean13
        case .itf14:
            return .itf14
        case .i2of5:
            return .interleaved2of5
        case .pdf417:
            return .pdf417
        case .qr:
            return .qr
        case .aztec:
            return .aztec
        default:
            return nil
        }
    }

}

extension UIImage {

    func recognizeBarcode(completion: @escaping (Result<ScanModel, Error>) -> Void) {
        guard let cgImage = cgImage else {
            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: ^String.ErrorsDescription.failedImageProcessing])))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let requestHandler = VNImageRequestHandler(cgImage: cgImage)
                let request = VNDetectBarcodesRequest { request, _ in
                    if let observations = request.results as? [VNBarcodeObservation],
                       let observation = observations.first(where: { $0.symbology.avCodeType != nil }),
                       let data = observation.payloadStringValue,
                       let type = observation.symbology.avCodeType {
                        let model = ScanModel(
                            id: 0,
                            type: type == .qr ? .qr : .barcode,
                            date: Date(),
                            dataFormat: type.rawValue,
                            data: data
                        )
                        ScannedItemsManager.shared.addItem(model, completion: completion)
                    } else {
                        completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: ^String.ErrorsDescription.failedBarcodeRecognition])))
                        return
                    }
                }
                try requestHandler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }

}
