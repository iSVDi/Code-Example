//
//  DocumentScanResultViewController.swift
//  smm-barcode
//
//  Created by Daniil on 23.03.2023.
//

import PDFKit
import QuickLook
import UIKit

class DocumentScanResultViewController: UIViewController {

    private let toolbar = UIToolbar(frame: .init(origin: .zero, size: CGSize(width: Constants.screenWidth, height: 44)))
    private let document: ScanModel
    private lazy var pdfView: PDFView = {
        let view = PDFView()
        view.pageBreakMargins = .bottom(10)
        view.backgroundColor = .appWhite
        view.autoScales = true
        view.usePageViewController(true)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setDismissLeftBarButtonItem()
        setupViews()
        reloadPDFDocument()
    }

    init(document: ScanModel) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private func setupViews() {
        view.backgroundColor = .appLightGray3
        title = ^String.ScanResult.documentPreview

        view.addSubview(pdfView)
        pdfView.edgesToSuperview()

        view.addSubview(toolbar)
        toolbar.edgesToSuperview(excluding: .top, usingSafeArea: true)

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let toolbarEditBtn = UIBarButtonItem(image: .pencil)
        toolbarEditBtn.addTarget(self, action: #selector(editDocumentHandler))
        let toolbarRemoveBtn = UIBarButtonItem(image: .commonRemove, tint: .appSystemRed)
        toolbarRemoveBtn.addTarget(self, action: #selector(deleteDocumentHandler))
        let toolbarShareBtn = UIBarButtonItem(image: .commonShare)
        toolbarShareBtn.addTarget(self, action: #selector(shareDocumentHandler))
        toolbar.setItems([toolbarRemoveBtn, spacer, toolbarEditBtn, spacer, toolbarShareBtn], animated: true)
    }

    private func documentUrl() -> URL {
        return URL.pdfDocument(name: document.data)
    }

    private func reloadPDFDocument() {
        if let document = PDFDocument(url: documentUrl()) {
            pdfView.document = document
        } else {
            showErrorAlert(^String.Alerts.errorAlertTitle)
        }
    }

    private func updateThumbnail() {
        DispatchQueue.main.async {
            ThumbnailHelper.shared.removeThumbnail(at: self.documentUrl())
            NotificationCenter.default.post(name: ScannedItemsManager.itemsUpdateNotification, object: nil)
        }
    }

    // MARK: - Handlers

    @objc private func editDocumentHandler() {
        let quickLookViewController = QLPreviewController.getQLPreviewControllerWithDelegateAndDataSourceIn((self, self))
        quickLookViewController.modalPresentationStyle = .fullScreen
        quickLookViewController.modalTransitionStyle = .crossDissolve
        present(quickLookViewController, animated: true)
    }

    @objc private func deleteDocumentHandler() {
        showDeleteConfirmationAlert { confirmed in
            guard confirmed else {
                return
            }
            ScannedItemsManager.shared.removePDF(self.document) { [weak self] error in
                guard error != nil else {
                    self?.dismiss(animated: true)
                    return
                }
                self?.view.makeToast(error?.localizedDescription)
            }
        }
    }

    @objc private func shareDocumentHandler() {
        let activityVc = UIActivityViewController(activityItems: [documentUrl()], applicationActivities: nil)
        activityVc.popoverPresentationController?.sourceView = view
        present(activityVc, animated: true)
        print("shareDocument handler")
    }

}

extension DocumentScanResultViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentUrl() as QLPreviewItem
    }

}

extension DocumentScanResultViewController: QLPreviewControllerDelegate {

    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .updateContents
    }

    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        print("UPDATE")
    }

    func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
        print("SAVED at \(modifiedContentsURL)")
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        reloadPDFDocument()
        updateThumbnail()
    }

}
