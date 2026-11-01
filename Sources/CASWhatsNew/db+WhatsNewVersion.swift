/*-------------------------------------------------------------------------------------------------------------------------
     File: db+WhatsNewVersion.swift
   Author: Kevin Messina
  Created: 9/11/25
 Modified: 11/01/2026 11:54 AM EST
  Version: 5
   Source: CODEX: (GPT-5) 🤖AI Code a portion or all of this code.

©2026 Creative App Solutions, LLC. - All Rights Reserved.
--------------------------------------------------------------------------------------------------------------------------
NOTES:
-------------------------------------------------------------------------------------------------------------------------*/

import Foundation
import GRDB
import CASExternalFoundations

public struct WhatsNewVersion: Codable, Equatable, Hashable, Identifiable, FetchableRecord, MutablePersistableRecord {
    public var id: Int64?
    public var version: Double = 0.0
    
    public static let databaseTableName = "Version"
    public var dbTableName: String { Self.databaseTableName }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let version = Column(CodingKeys.version)
    }
    
    public init(
        id: Int64? = nil,
        version: Double = 0.0
    ) {
        self.id = id
        self.version = version
    }
    
    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    // MARK: - *** DB Functions ***
    /// Returns nil only when a valid record ID is absent; database failures are thrown.
    public func getFromID(_ id: Int64, dbQueue: DatabaseQueue, logLFFL: String) throws -> WhatsNewVersion? {
        guard id >= 0 else {
            throw NSError(domain: "WhatsNewVersion", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid version record ID: \(id)."])
        }
        do {
            let record = try dbQueue.read { try WhatsNewVersion.fetchOne($0, id: id) }
            SimPrint.Info("WhatsNewVersion: Found \(record == nil ? 0 : 1) record for ID \(id).", action: .success, log: logLFFL)
            return record
        } catch {
            SimPrint.Info("WhatsNewVersion: Fetch failed.", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
            throw error
        }
    }

    /// Returns nil for an empty Version table, rather than fabricating version zero.
    public func getLatestVersion(dbQueue: DatabaseQueue, logLFFL: String) throws -> Double? {
        do {
            let record = try dbQueue.read { try WhatsNewVersion.order(Columns.version.desc, Columns.id.desc).fetchOne($0) }
            return record.map { Double($0.version) }
        } catch {
            SimPrint.Info("WhatsNewVersion: Latest version fetch failed.", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
            throw error
        }
    }

    public func getAll(dbQueue: DatabaseQueue, logLFFL: String) throws -> [WhatsNewVersion] {
        do {
            return try dbQueue.read { try WhatsNewVersion.order(Columns.version.asc, Columns.id.asc).fetchAll($0) }
        } catch {
            SimPrint.Info("WhatsNewVersion: Fetch all failed.", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
            throw error
        }
    }

    @discardableResult
    public func saveUpdate(
        _ item: WhatsNewVersion,
        dbQueue: DatabaseQueue,
        logLFFL: String
    ) -> Bool {
        guard let id = item.id, id >= 0 else {
            SimPrint.Info("A valid existing version record ID is required for update.", action: .error, log: logLFFL)
            return false
        }
        do {
            try dbQueue.write { tableRecs in
                try item.update(tableRecs)
            }
            
            SimPrint.Info("WHATS NEW VERSION: Updated record in \(dbTableName).", action: .success, log: logLFFL)
        } catch {
            SimPrint.Info("WHATS NEW VERSION: Update failed for \(dbTableName).", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
            return false
        }
        
        return true
    }
    
    @discardableResult
    public func delete(
        id: Int64,
        dbQueue: DatabaseQueue,
        logLFFL: String
    ) -> Bool {
        guard id >= 0 else {
            SimPrint.Info("Invalid required version ID: \(id).", action: .error, log: logLFFL)
            return false
        }
        do {
            let deleted = try dbQueue.write { tableRecs in
                try WhatsNewVersion.deleteOne(tableRecs, id: id)
            }
            guard deleted else {
                SimPrint.Info("Version record ID \(id) was not found for deletion.", action: .error, log: logLFFL)
                return false
            }
            
            SimPrint.Info("WHATS NEW VERSION: Deleted record ID: \(id) from \(dbTableName).", action: .success, log: logLFFL)
        } catch {
            SimPrint.Info("WHATS NEW VERSION: Delete failed for \(dbTableName).", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
            return false
        }
        
        return true
    }
    
    @discardableResult
    public func addNew(
        _ item: WhatsNewVersion,
        dbQueue: DatabaseQueue,
        logLFFL: String
    ) -> (success: Bool, id: Int64) {
        var newItem = item
        var newID: Int64 = -1
        
        do {
            try dbQueue.write { tableRecs in
                try newItem.insert(tableRecs)
                newID = tableRecs.lastInsertedRowID
            }
            
            SimPrint.Info("WHATS NEW VERSION: Inserted record ID: \(newID) into \(dbTableName).", action: .success, log: logLFFL)
        } catch {
            SimPrint.Info("WHATS NEW VERSION: Insert failed for \(dbTableName).", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
            return (success: false, id: -1)
        }
        
        return (success: true, id: newID)
    }
}
