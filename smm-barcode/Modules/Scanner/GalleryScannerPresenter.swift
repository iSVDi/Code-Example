//
//  GalleryScannerPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 12.04.2023.
//

import UIKit

class GalleryScannerPresenter: NSObject {

    private weak var controller: UIViewController?

    init(controller: UIViewController) {
        super.init()
        self.controller = controller
    }

    func start() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        controller?.present(imagePicker, animated: true)
    }

}

extension GalleryScannerPresenter: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            controller?.showErrorAlert(^String.ErrorsDescription.failedPickedImageProcessing)
            return
        }
        detectBarcode(in: image)
    }

    private func detectBarcode(in image: UIImage) {
        controller?.showHUD()
        image.recognizeBarcode { [weak self] result in
            /*
             INFO: -  without DispatchQueue.main.async there will be error
             "Modifications to the layout engine must not be performed from a background thread after it has been accessed from the main thread."
             */
            DispatchQueue.main.async {
                self?.controller?.hideHUD()
                switch result {
                case let .success(model):
                    self?.controller?.showResultViewController(model)
                case let .failure(error):
                    self?.controller?.showErrorAlert(error.localizedDescription)
                }
            }
        }
    }

}
