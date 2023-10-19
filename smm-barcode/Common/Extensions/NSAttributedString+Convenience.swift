//
//  NSAttributedString+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import UIKit

extension NSAttributedString {

    enum ImageOrigin {
        case begin
        case end
    }

    static func stringWithImage(title: String, font: UIFont = .semibold(17), image: AppImage, tintColor: UIColor = .appWhite, imageOrigin: ImageOrigin = .end) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: tintColor, .font: font]

        let fullString = NSMutableAttributedString(string: title, attributes: attributes)

        guard let image = image.uiImageWith(font: font, tint: tintColor) else {
            return fullString
        }
        let imageAttachment = NSTextAttachment(image: image)
        let imageString = NSAttributedString(attachment: imageAttachment)

        switch imageOrigin {
        case .begin:
            fullString.insert(spaceString(font: font), at: 0)
            fullString.insert(imageString, at: 0)
        case .end:
            fullString.append(spaceString(font: font))
            fullString.append(imageString)
        }

        return fullString
    }

    // MARK: - Helpers

    private static func spaceString(font: UIFont) -> NSAttributedString {
        return NSAttributedString(string: " ", attributes: [.font: font])
    }

}
