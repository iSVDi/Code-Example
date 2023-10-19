//
//  ThumbnailHelper.swift
//  smm-barcode
//
//  Created by Daniil on 31.03.2023.
//

import QuickLookThumbnailing
import UIKit

class ThumbnailHelper {

    typealias Completion = (URL, UIImage?) -> Void

    static let shared = ThumbnailHelper()

    private let generator = QLThumbnailGenerator.shared

    private var completions: [URL: [Completion]] = [:]
    private var cache: [URL: UIImage] = [:]

    func thumbnail(of url: URL, size: CGSize, completion: @escaping Completion) {
        if let image = cache[url] {
            completion(url, image)
            return
        }
        var completions = self.completions[url] ?? []
        completions.append(completion)
        self.completions[url] = completions
        if completions.count > 1 {
            return
        }
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: Constants.scale, representationTypes: .all)
        generator.generateBestRepresentation(for: request) { [weak self] thumbnail, _ in
            if let image = thumbnail?.uiImage {
                self?.cache[url] = image
            }
            DispatchQueue.main.async {
                self?.notifyCompletions(of: url, image: thumbnail?.uiImage)
            }
        }
    }

    // MARK: - Cache

    func removeThumbnail(at url: URL) {
        cache.removeValue(forKey: url)
    }

    func copyThumbnail(at source: URL, to destination: URL) {
        cache[source] = cache[destination]
    }

    func moveThumbnail(at source: URL, to destination: URL) {
        cache[source] = cache.removeValue(forKey: destination)
    }

    // MARK: - Helpers

    private func notifyCompletions(of url: URL, image: UIImage?) {
        completions.removeValue(forKey: url)?.forEach { $0(url, image) }
    }

}
