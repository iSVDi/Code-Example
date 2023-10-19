//
//  MomentJS.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 06.04.2023.
//

import Foundation
import JavaScriptCore

struct MomentJS {

    private static let sharedMomentJS: JSValue? = {
        guard let url = Bundle.main.url(forResource: "moment-with-locales", withExtension: "js"),
              let content = try? String(contentsOf: url, encoding: .utf8),
              let context = JSContext() else {
            return nil
        }
        context.evaluateScript(content)
        return context.objectForKeyedSubscript("moment")
    }()

    static func calendar(_ date: Date) -> String? {
        let moment = sharedMomentJS?.construct(withArguments: [date])
        guard let lang = Locale.preferredLanguages.first else {
            return ""
        }
        moment?.invokeMethod("locale", withArguments: [lang])
        // INFO: can be localized, like
        // "sameDay": "[\(^String.someLocalizationKey)]",
        let format = [
            "sameDay": "[Today]",
            "nextDay": "[Tomorrow]",
            "nextWeek": "dddd",
            "lastDay": "[Yesterday]",
            "lastWeek": "[Last] dddd",
            "sameElse": "DD/MM/YYYY"
        ]
        return moment?.invokeMethod("calendar", withArguments: [format])?.toString()
    }

}
