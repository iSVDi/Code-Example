//
//  Images.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import UIKit

enum AppImage: String {

    // Common
    case commonClose
    case commonChevronLeft = "chevron.left"
    case commonChevronDown = "chevron.down"
    case commonChevronUp = "chevron.up"
    case commonChevronRight
    case commonCrown = "crown"
    case commonCopy = "square.on.square"
    case commonRemove = "trash"
    case commonShare = "square.and.arrow.up"
    case commonDocImage = "doc.text"
    case linkArrowImage = "arrow.up.right"
    case photo

    // Launchscreen
    case launchscreenLogo
    case launchscreenBarcodeApps

    // Trial
    case trialCheckmark

    // Intro
    case introFirstSlideIpad
    case introFirstSlide
    case introSecondSlideIpad
    case introSecondSlide
    case introThirdSlide
    case introThirdSlideIpad

    // Features
    case featuresFirstSlideIpad
    case featuresSecondSlideIpad

    // Root
    case rootGearshape = "gearshape.fill"
    case rootLightningFill = "bolt.fill"
    case rootLightning = "bolt"
    case rootHistory
    case rootProducts = "magnifyingglass"
    case warning = "exclamationmark.triangle"

    // Albums
    case albumsPhotoOnRectangleAngled = "photo.on.rectangle.angled"

    // Settings
    case settingsPersonSquare
    case settingsGoforwardSquare
    case settingsMessageSquare
    case settingsArrowshapeRightSquare
    case settingsDocSquare
    case settingsInfinity = "infinity"
    case settingsClockArrowCirclePath

    // History
    case moreOptionsImage = "ellipsis.circle"
    case filterImage
    case pdfPreview

    // Document Preview
    case pencil = "pencil.tip.crop.circle"

    // Search
    case google
    case ebay
    case amazon
    case aliexpress

    // Product Scanner
    case barcode = "barcode.viewfinder"
    case productScannerEmptyPreview

    var uiImage: UIImage? {
        return UIImage(systemName: rawValue) ?? UIImage(named: rawValue)
    }

    func uiImageWith(font: UIFont? = nil, tint: UIColor? = nil) -> UIImage? {
        var img = uiImage
        if let font = font {
            img = img?.withConfiguration(UIImage.SymbolConfiguration(font: font))
        }
        if let tint = tint {
            return img?.withTintColor(tint, renderingMode: .alwaysOriginal)
        } else {
            return img
        }
    }

}
