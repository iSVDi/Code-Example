//
//  HistoryPresenterProtocol.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 08.04.2023.
//

import Foundation
import UIKit

protocol HistoryLayoutPresenterProtocol {
    func getView() -> UIView
    func handleSearch(query: String)
    func handleFilter(by elementType: ScanModel.ScanType?)
}
