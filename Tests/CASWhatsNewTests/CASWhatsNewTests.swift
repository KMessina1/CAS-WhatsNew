/*-------------------------------------------------------------------------------------------------------------------------
     File: CASWhatsNewTests.swift
   Author: Kevin Messina
  Created: 11/1/26
 Modified: 11/01/2026 11:56 AM EST
  Version: 1
   Source: CODEX: (GPT-5) 🤖AI Code a portion or all of this code.

©2026 Creative App Solutions, LLC. - All Rights Reserved.
--------------------------------------------------------------------------------------------------------------------------
NOTES:
-------------------------------------------------------------------------------------------------------------------------*/

import Testing
@testable import CASWhatsNew

@Test func releaseHistoryUsesNewestDistinctNumericVersions() {
    func records(_ versions: [Double]) -> [WhatsNewItem] {
        versions.map { WhatsNewItem(id: nil, version: $0, sortOrder: 0, title: "", detail: "", iconName: "") }
    }
    #expect(WhatsNewItem.recentVersions(in: [], limit: 3).isEmpty)
    #expect(WhatsNewItem.recentVersions(in: records([1, 2, 3, 4, 5, 6]), limit: 3) == [6, 5, 4])
    #expect(WhatsNewItem.recentVersions(in: records([8, 9, 10, 11, 11]), limit: 3) == [11, 10, 9])
    #expect(WhatsNewItem.recentVersions(in: records([0, 1]), limit: 3) == [1, 0])
    #expect(WhatsNewItem.recentVersions(in: records([1, .nan, .infinity, 2]), limit: 3) == [2, 1])
    #expect(WhatsNewItem.recentVersions(in: records([1, 2]), limit: 0).isEmpty)
    #expect(WhatsNewItem.recentVersions(in: records([1, 2]), limit: -1).isEmpty)
}
