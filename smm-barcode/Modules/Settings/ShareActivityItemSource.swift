//
//  ShareActivityItemSource.swift
//  SecretVault
//
//  Created by Daniil on 02.03.2023.
//

import UIKit

class ShareActivityItemSource: NSObject, UIActivityItemSource {

    private var sharingString: String {
        return String.Settings.sharingString.format(Constants.appStorePath)
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return activityType == .mail ? String.Settings.htmlSharingString.format(Constants.appStorePath) : sharingString
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return activityType == .mail ? ^String.Settings.sharingSubjectTitle : ""
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return sharingString
    }

}
