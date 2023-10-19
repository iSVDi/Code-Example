//
//  ScannedCodesDatabase.swift
//  smm-barcode
//
//  Created by Daniil on 20.03.2023.
//

import AVFoundation
import FMDB

private enum DatabaseConstants {
    static let tableName = "scannedItemstTable"
    static let idColumn = "id"
    static let typeColumn = "type"
    static let dateColumn = "date"
    static let dataFormatColumn = "dataFormat"
    static let dataColumn = "data"
}

class ScannedCodesDatabase {

    private let queue: FMDatabaseQueue?

    init() {
        let databaseDirectory = URL.databaseDirectory
        if !FileManager.default.fileExists(atPath: databaseDirectory.path) {
            try? FileManager.default.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
        }

        let fileUrl = databaseDirectory.appendingPathComponent("scannedItemsDatabase.sqlite")
        _ = FMDatabase(url: fileUrl)
        queue = FMDatabaseQueue(url: fileUrl)

        // INFO: use "text" type for strings otherwise leading/trailing zero chars can be removed
        let createTableSql = "CREATE TABLE IF NOT EXISTS \(DatabaseConstants.tableName) (\(DatabaseConstants.idColumn) integer Primary key AutoIncrement, \(DatabaseConstants.typeColumn) text, \(DatabaseConstants.dateColumn) text, \(DatabaseConstants.dataFormatColumn) text, \(DatabaseConstants.dataColumn) text)"

        queue?.inTransaction { dataBase, rollback in
            do {
                try dataBase.executeUpdate(createTableSql, values: nil)
            } catch {
                rollback.pointee = true
                print(error)
            }
        }
    }

    func addItemData(_ item: ScanModel, completion: @escaping (Result<ScanModel, Error>) -> Void) {
        queue?.inTransaction { dataBase, rollback in
            let insertData = "INSERT INTO \(DatabaseConstants.tableName) (\(DatabaseConstants.idColumn), \(DatabaseConstants.typeColumn), \(DatabaseConstants.dateColumn), \(DatabaseConstants.dataFormatColumn), \(DatabaseConstants.dataColumn)) values (NULL, ?, ?, ?, ?)"
            do {
                try dataBase.executeUpdate(insertData, values: [item.type.rawValue, item.date, item.dataFormat, item.data])
                let resultItem = ScanModel(id: Int(dataBase.lastInsertRowId), type: item.type, date: item.date, dataFormat: item.dataFormat, data: item.data)
                print("addItem", resultItem.id, resultItem.type, resultItem.data)
                completion(.success(resultItem))
            } catch {
                rollback.pointee = true
                completion(.failure(error))
            }
        }
    }

    func getAllItems(completion: @escaping (Result<[ScanModel], Error>) -> Void) {
        queue?.inTransaction { dataBase, rollback in
            do {
                var items: [ScanModel] = []
                let allItem = "SELECT * FROM \(DatabaseConstants.tableName)"
                let result = try dataBase.executeQuery(allItem, values: nil)
                while result.next() {
                    let id = result.longLongInt(forColumn: DatabaseConstants.idColumn)
                    if let typeString = result.string(forColumn: DatabaseConstants.typeColumn),
                       let type = ScanModel.ScanType(rawValue: typeString),
                       let date = result.date(forColumn: DatabaseConstants.dateColumn),
                       let dataFormat = result.string(forColumn: DatabaseConstants.dataFormatColumn),
                       let data = result.string(forColumn: DatabaseConstants.dataColumn) {
                        items.append(ScanModel(id: Int(id), type: type, date: date, dataFormat: dataFormat, data: data))
                    }
                }
                completion(.success(items))
            } catch {
                rollback.pointee = true
                completion(.failure(error))
            }
        }
    }

    func removeItem(_ item: ScanModel, completion: @escaping (Error?) -> Void) {
        queue?.inTransaction { dataBase, rollback in
            do {
                let deleteRow = "DELETE FROM \(DatabaseConstants.tableName) WHERE \(DatabaseConstants.idColumn) = ?"
                try dataBase.executeUpdate(deleteRow, values: [item.id])
                completion(nil)
            } catch {
                rollback.pointee = true
                completion(error)
            }
        }
    }

}
