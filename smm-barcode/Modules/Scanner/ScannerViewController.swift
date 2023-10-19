//
//  ScannerViewController.swift
//  smm-barcode
//
//  Created by Daniil on 06.03.2023.
//

import RSBarcodes_Swift
import TinyConstraints
import UIKit

class ScannerViewController: RSCodeReaderViewController {

    enum Mode {
        case barcode
        case product
    }

    var scannerMode: Mode = .barcode {
        didSet {
            switch scannerMode {
            case .barcode:
                changeModePickerButton(title: ^String.ScannerMode.barcodeScanner)
            case .product:
                changeModePickerButton(title: ^String.ScannerMode.productScanner)
            }
        }
    }

    private let modePickerButton = ViewsFactory.defaultButton(color: .appClear, font: .semibold(17))
    private lazy var lightningButton = LightButton(target: self, selector: #selector(lightningButtonPressed))
    private lazy var presenter = ScannerPresenter(controller: self)
    private lazy var galleryPresenter = GalleryScannerPresenter(controller: self)
    private let filePresenter = IcloudCodeRecognizer()
    let placeBarcodeLabel: UIView = {
        let label = ViewsFactory.defaultLabel(font: .regular(13), textColor: .appWhite, alignment: .center)
        label.text = ^String.Scan.placeTheBarcodeInACameraArea
        let wrappedLabel = label.wrap(horizontalInsets: 12, verticalInsets: 6)
        wrappedLabel.backgroundColor = .appGray
        wrappedLabel.layer.cornerRadius = 12
        return wrappedLabel
    }()

    let noRecognizedBarcodeLabel: UIView = {
        let label = ViewsFactory.defaultLabel(font: .regular(13), textColor: .appWhite, alignment: .center)
        label.attributedText = NSAttributedString.stringWithImage(title: ^String.Scan.noBarcodeRecognizedTryAnotherPhoto, font: .regular(13), image: AppImage.warning, imageOrigin: .begin)
        let wrappedLabel = label.wrap(horizontalInsets: 12, verticalInsets: 6)
        wrappedLabel.backgroundColor = .appGray
        wrappedLabel.layer.cornerRadius = 12
        return wrappedLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupCamera()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lightningButton.turnOff()
    }

    // MARK: - Handlers

    @objc func showSettings() {
        let settingsVC = SettingsViewController()
        presentFullScreenController(controller: settingsVC)
    }

    @objc func galleryButtonPressed() {
        galleryPresenter.start()
    }

    @objc func lightningButtonPressed() {
        toggleTorch()
        lightningButton.changeLightState()
    }

    @objc func historyButtonPressed() {
        presenter.openHistory()
    }

    @objc func productButtonPressed() {
        presenter.openProducts()
    }

    @objc private func modePickerButtonPressed() {
        var actions = String.ScannerMode.allCases.map { mode in
            return UIAlertAction(title: ^mode, style: .default) { [weak self] _ in
                self?.handleModeSelection(mode)
            }
        }
        actions.append(UIAlertAction.cancelAction)
        showSheetAlertController(actions: actions)
    }

    // MARK: - Helpers

    private func handleModeSelection(_ mode: String.ScannerMode) {
        switch mode {
        case .barcodeScanner:
            scannerMode = .barcode
        case .productScanner:
            scannerMode = .product
        case .documentScanner:
            presenter.openDocumentsScanner()
        case .importFromGallery:
            galleryPresenter.start()
        case .importFromCloud:
            filePresenter.present(in: self)
        }
    }

    private func setupLayout() {
        let settingsButton = ButtonView(
            image: AppImage.rootGearshape.uiImage,
            title: ^String.Root.settingsTitle,
            target: self,
            selector: #selector(showSettings)
        )
        let galleryButton = ButtonView(
            image: AppImage.albumsPhotoOnRectangleAngled.uiImage,
            title: ^String.Root.galleryTitle,
            target: self,
            selector: #selector(galleryButtonPressed)
        )
        let historyButton = ButtonView(
            image: AppImage.rootHistory.uiImage,
            title: ^String.Root.historyTitle,
            target: self,
            selector: #selector(historyButtonPressed)
        )
        let productButton = ButtonView(
            image: AppImage.rootProducts.uiImage,
            title: ^String.Root.productsTitle,
            target: self,
            selector: #selector(productButtonPressed)
        )

        [settingsButton, galleryButton, lightningButton, historyButton, productButton, placeBarcodeLabel, noRecognizedBarcodeLabel].forEach {
            view.addSubview($0)
        }

        settingsButton.rightToSuperview(offset: -20)
        settingsButton.topToSuperview(offset: view.frame.height * 0.87)

        galleryButton.leftToSuperview(offset: 20)
        galleryButton.topToSuperview(offset: view.frame.height * 0.87)

        lightningButton.leftToSuperview(offset: 20)
        lightningButton.topToSuperview(offset: 11.5, usingSafeArea: true)

        historyButton.leftToSuperview(offset: 20)
        historyButton.topToBottom(of: lightningButton, offset: 12)

        productButton.rightToSuperview(offset: -20)
        productButton.topToSuperview(offset: 11.5, usingSafeArea: true)

        let wrapperView = UIView()
        view.addSubview(wrapperView)
        wrapperView.addSubview(modePickerButton)
        wrapperView.backgroundColor = .appGray
        wrapperView.layer.cornerRadius = 12

        modePickerButton.horizontalToSuperview(insets: .horizontal(16))
        modePickerButton.verticalToSuperview(insets: .horizontal(12))

        wrapperView.height(44)
        wrapperView.centerXToSuperview()
        wrapperView.topToSuperview(offset: 11.5, usingSafeArea: true)

        placeBarcodeLabel.bottomToSuperview(offset: -187)
        placeBarcodeLabel.centerXToSuperview()

        noRecognizedBarcodeLabel.bottomToSuperview(offset: -114)
        noRecognizedBarcodeLabel.centerXToSuperview()
        noRecognizedBarcodeLabel.isHidden = true
    }

    private func setupViews() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .appClear
        scannerMode = .barcode
        if #available(iOS 14.0, *) {
            let items = String.ScannerMode.allCases.map { mode in
                let image = mode == .productScanner ? AppImage.rootProducts.uiImageWith(font: .regular(21), tint: .appOrange) : nil
                return UIAction(title: ^mode, image: image, handler: { [weak self] _ in
                    self?.handleModeSelection(mode)
                })
            }
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: items)
            modePickerButton.menu = menu
            modePickerButton.showsMenuAsPrimaryAction = true
        } else {
            modePickerButton.addTarget(self, action: #selector(modePickerButtonPressed), for: .touchDown)
        }
    }

    private func setupCamera() {
        UIViewController.ensureCameraPermission { [weak self] authorized in
            guard authorized else {
                self?.showGoToAppSettingsAlert(message: "")
                return
            }
            self?.setupScanner()
        }
    }

    private func setupScanner() {
        focusMarkLayer.isHidden = true
        cornersLayer.isHidden = true
        barcodesHandler = { [weak self] barcodes in
            self?.session.stopRunning()
            self?.presenter.handleScanResult(barcodes)
        }
    }

    private func changeModePickerButton(title: String) {
        let attribute = NSAttributedString.stringWithImage(title: title, image: AppImage.commonChevronDown)
        let attributeUp = NSAttributedString.stringWithImage(title: title, image: AppImage.commonChevronUp, tintColor: .appTitleGray)

        modePickerButton.setAttributedTitle(attribute, for: .normal)
        modePickerButton.setAttributedTitle(attributeUp, for: .highlighted)
    }

}
