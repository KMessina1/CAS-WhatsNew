/*-------------------------------------------------------------------------------------------------------------------------
     File: db+WhatsNewVersion.swift
   Author: Kevin Messina
  Created: 9/11/25
 Modified: 08/23/2026 09:40 AM EDT
  Version: 4
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
    public func getFromID(
        _ id: Int64,
        dbQueue: DatabaseQueue,
        logLFFL: String
    ) -> WhatsNewVersion {
        var rec: WhatsNewVersion = WhatsNewVersion()
        
        do {
            try dbQueue.read { tableRecs in
                try rec = WhatsNewVersion.fetchOne(tableRecs, id: id) ?? WhatsNewVersion()
            }
            
            SimPrint.Info("WHATS NEW VERSION: Fetched record ID: \(id) from \(dbTableName).", action: .success, log: logLFFL)
        } catch {
            SimPrint.Info("WHATS NEW VERSION: Fetch failed for \(dbTableName).", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
        }
        
        return rec
    }
    
    public func getLatestVersion(
        dbQueue: DatabaseQueue,
        logLFFL: String
    ) -> Double {
        var rec: WhatsNewVersion = WhatsNewVersion()
        
        do {
            try dbQueue.read { tableRecs in
                try rec = WhatsNewVersion.fetchOne(tableRecs) ?? WhatsNewVersion()
            }
            
            SimPrint.Info("WHATS NEW VERSION: Fetched latest version from \(dbTableName).", action: .success, log: logLFFL)
        } catch {
            SimPrint.Info("WHATS NEW VERSION: Fetch latest failed for \(dbTableName).", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
        }
        
        return rec.version
    }
    
    public func getAll(
        dbQueue: DatabaseQueue,
        logLFFL: String
    ) -> [WhatsNewVersion] {
        var recs: [WhatsNewVersion] = []
        
        do {
            try dbQueue.read { tableRecs in
                try recs = WhatsNewVersion.order(Columns.version.asc).fetchAll(tableRecs)
            }
            
            SimPrint.Info("WHATS NEW VERSION: Fetched \(recs.count) records from \(dbTableName).", action: .success, log: logLFFL)
        } catch {
            SimPrint.Info("WHATS NEW VERSION: Fetch all failed for \(dbTableName).", action: .error, errorMsg: error.localizedDescription, log: logLFFL)
        }
        
        return recs
    }
    
    @discardableResult
    public func saveUpdate(
        _ item: WhatsNewVersion,
        dbQueue: DatabaseQueue,
        logLFFL: String
    ) -> Bool {
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
        do {
            try dbQueue.write { tableRecs in
                try WhatsNewVersion.deleteOne(tableRecs, id: id)
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
