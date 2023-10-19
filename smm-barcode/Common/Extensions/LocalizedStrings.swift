//
//  LocalizedStrings.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import Foundation

extension String {

    func capitalizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    enum Common: String {
        case cancelTitle
    }

    enum ButtonTitles: String {
        case continueButtonTitle
        case restoreButtonTitle
        case okButtonTitle
        case doneButtonTitle
        case closeButtonTitle
        case allScans
        case barcodesOnly
        case qrCodesOnly
        case documentsOnly
        case icons
        case list
        case edit
        case scanProduct
    }

    enum Trial: String {
        case subscriptionRestoreSuccessMessage
        case paidPromoFeature1
        case paidPromoFeature2
        case paidPromoFeature3
        case paidPromoNoAdsNoLimits
        case termsOfUsage
        case privacyPolicy
        case trialSlideHeaderTitle
    }

    enum Alerts: String {
        case errorAlertTitle
        case infoAlertTitle
        case askOpenSettingsTitle
        case goToSettingsTitle
        case yesTitle
        case noTitle
        case areYouSure
        case deleteConfirmationTitle
        case deleteTitle
    }

    enum Subscriptions: String {
        case threeDaysFreeCellTitle
        case monthSubCellTitle
        case yearSubCellTitle
        case monthlyCalculatedPrice
        case yearlyCalculatedPrice
        case monthSubCellSubtitle
        case yearSubCellSubtitle
        case unknownErrorTitle
        case subscriptionRestoreNoActiveSubMessage
    }

    enum Intro: String {
        case introFirstSlideDescription
        case introSecondSlideDescription
        case introThirdSlideDescription
    }

    enum Root: String {
        case galleryTitle
        case settingsTitle
        case historyTitle
        case lightTitle
        case productsTitle
    }

    enum Settings: String {
        case premiumTitle
        case freeTitle
        case licenseTitle
        case accountUppercasedTitle
        case subscriptionsTitle
        case contactSupportTitle
        case shareOurAppTitle
        case generalUppercasedTitle
        case sharingString
        case htmlSharingString
        case sharingSubjectTitle
        case subscriptionsDescriptionTitle
        case numberOfNumberString
        case barcodeLimitTitle
        case productLimitTitle
        case documentLimitTitle
        case changeSubscriptionTitle
    }

    enum Scan: String {
        case scannerTitle
        case scanResult
        case placeTheBarcodeInACameraArea
        case noBarcodeRecognizedTryAnotherPhoto
    }

    enum ScannerMode: String, CaseIterable {
        case barcodeScanner
        case productScanner
        case documentScanner
        case importFromGallery
        case importFromCloud
    }

    enum ScanResult: String {
        case scannedResultTitle
        case element
        case code
        case data
        case qrResult
        case barcodeResult
        case codeInformation
        case documentPreview
        case pdf
        case clipboardTitle
        case shareAsImage
        case shareAsText
        case text
        case website
    }

    enum Search: String {
        case google
        case amazon
        case aliexpress
        case ebay
        case searchTitle
    }

    enum History: String {
        case todayTitle
        case yesterdayTitle
        case delete
        case copy
        case share
    }

    enum Product: String {
        case productScanner
        case productScannerEmptyPreviewTitle
        case foodInfo
        case nutrientsTitle
        case micronutrientsTitle
        case scannedResult
        case dishType
        case category
        case foodInformation
    }

    enum ProductScanResult: String {
        case somethingWentWrong
        case tryAgain
    }

    enum Last: String {
        case nothingFoundLabelTitle
    }

    enum ErrorsDescription: String {
        case failedImageProcessing
        case failedPickedImageProcessing
        case failedDocumentScanSaving
        case failedBarcodeRecognition
        case codeWasntFound
        case codeWasntRecognized
    }

}

extension RawRepresentable {

    func format(_ args: CVarArg...) -> String {
        let format = ^self
        return String(format: format, arguments: args)
    }

}

prefix operator ^
prefix func ^ <Type: RawRepresentable>(_ value: Type) -> String {
    if let raw = value.rawValue as? String {
        let key = raw.capitalizeFirstLetter()
        return NSLocalizedString(key, comment: "")
    }
    return ""
}
