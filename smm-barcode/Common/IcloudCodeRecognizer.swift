//
//  IcloudCodeRecognizer.swift
//  smm-barcode
//
//  Created by Daniil on 19.04.2023.
//

import MobileCoreServices
import UIKit
import UniformTypeIdentifiers

/// Supporting Images only by default.
class IcloudCodeRecognizer: NSObject {

    weak var controller: UIViewController?

    func present(in controller: UIViewController?) {
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image], asCopy: true)
        } else {
            picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeImage)], in: .import)
        }
        picker.allowsMultipleSelection = false
        picker.modalPresentationStyle = .fullScreen
        picker.delegate = self
        self.controller = controller

        controller?.present(picker, animated: true)
    }

    private func loadBarcodeFromCloud(result: Result<Data, Error>) {
        switch result {
        case let .success(data):
            recognizeImageFromCloud(data: data)
        case .failure:
            controller?.showErrorAlert(^String.ErrorsDescription.codeWasntFound)
        }
    }

    private func recognizeImageFromCloud(data: Data) {
        guard let image = UIImage(data: data) else {
            controller?.showErrorAlert(^String.ErrorsDescription.codeWasntFound)
            return
        }
        controller?.showHUD()
        image.recognizeBarcode { [weak self] recognizeResult in
            DispatchQueue.main.async {
                self?.controller?.hideHUD()
                switch recognizeResult {
                case let .success(result):
                    self?.controller?.showResultViewController(result)
                case .failure:
                    self?.controller?.showErrorAlert(^String.ErrorsDescription.codeWasntRecognized)
                }
            }
        }
    }

}

// MARK: - Document Picker Delegate

extension IcloudCodeRecognizer: UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            loadBarcodeFromCloud(result: .failure(error))
            return
        }
        loadBarcodeFromCloud(result: .success(data))
    }

}
