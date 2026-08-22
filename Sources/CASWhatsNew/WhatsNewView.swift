/*-------------------------------------------------------------------------------------------------------------------------
     File: WhatsNewView.swift
   Author: Kevin Messina
  Created: Mar 19, 2021
 Modified: 08/22/2026 06:48 PM EDT
  Version: 2
   Source: CODEX: (GPT-5) 🤖AI Code a portion or all of this code.

©2026 Creative App Solutions, LLC. - All Rights Reserved.
--------------------------------------------------------------------------------------------------------------------------
NOTES:
-------------------------------------------------------------------------------------------------------------------------*/

import CASExternalFoundations
import CASExternalBasics
import CASThemeSupport
import SwiftUI
import GRDB

public struct WhatsNewView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    private let dbQueue: DatabaseQueue?
    private let appVersion: String
    private let showWhatsNewKey = "app.whatsNew"

    let CT = CurrentTheme().getThemeFromUserStds()

    @State var WhatsNewItems:[WhatsNewItem] = []
    @State var filteredItems:[WhatsNewItem] = []
    @State var versions:[String] = []
    @State var adjustAlignment: Bool = false
    @State var currentVersion: Double = 0.0
    @State var limitVersionsTo: Int = 3
    @State var selectedVersion: Int = 3

    let gridItem: GridItem = GridItem(.flexible(), spacing: 16, alignment: .leading)

    public init(
        dbQueue: DatabaseQueue? = nil,
        appVersion: String = ""
    ) {
        self.dbQueue = dbQueue
        self.appVersion = appVersion
    }

    func noContentView(title: String, icon: String) -> some View {
        VStack {
            Spacer()
            ContentUnavailableView { Label(title, systemImage: icon) }
            Spacer()
        }
        .foregroundStyle(CT.fair)
    }
    
    func loadBasicData() -> Void {
        guard let dbQueue else { return }

        let table: String = WhatsNewItem.databaseTableName
        
        WhatsNewItems.removeAll()
        
        do {
            try dbQueue.read { dbTable in
                WhatsNewItems = try WhatsNewItem.fetchAll(dbTable,
                    WhatsNewItem.order(Column("version"), Column("sortOrder"))
                )
                
                versions.removeAll()
                for item in WhatsNewItems {
                    if versions.count > limitVersionsTo {
                        break
                    }else{
                        if !versions.contains(String(item.version)) {
                            versions.append(String(item.version))
                        }
                    }
                }
                
                versions = versions.sorted().reversed()

                currentVersion = Double(versions[0]) ?? -1.0

                filterVersions()
                
                SimPrint.Info("WHATS NEW: Fetched \(WhatsNewItems.count) records from \(table).", action: .success, log: LFFL())
            }
        } catch {
            SimPrint.Info("WHATS NEW: Fetch failed for \(table).", action: .error, errorMsg: error.localizedDescription, log: LFFL())
            print("\(error)")
        }
    }
    
    func filterVersions() {
        filteredItems = WhatsNewItems.filter{ $0.version == currentVersion }
    }
    
    var toolbarView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
            .padding(.all,13)
            .glassEffect(.clear)
            .clipShape(Circle())
            .foregroundStyle(.white)

            Spacer()
            
            VStack {
                Text("What's New in the app".uppercased())
                    .fontWeight(.regular)

                Text("App Version \(appVersion)")
                    .fontWeight(.light)
            }
            .font(.headline)
            .fontWidth(.condensed)
            .foregroundStyle(.white)

            Spacer()
            
            Menu {
                ForEach(versions, id: \.self) { item in
                    Button("v\(item)\(Double(item) == currentVersion ?" (Current)" :"")") {
                        currentVersion = Double(item) ?? -1.0
                        filterVersions()
                    }
                }
            } label: {
                Image(systemName: "books.vertical")
            }//End Menu
            .foregroundStyle(.white)
            .padding(.all,13)
            .glassEffect(.clear)
            .clipShape(Circle())
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            // This inset ensures content doesn't go under the status bar
            Color.clear.frame(height: 0)
        }
        .padding(.leading,10)
        .padding(.trailing,5)
    }

    public var body: some View {
        let isCompact = (horizontalSizeClass == .compact)
        let iconSize: CGFloat = deviceIs.Pad ?90 :60
        let columns_1 =  [gridItem]
        let columns_2 =  [gridItem,gridItem]
        let columns_3 =  [gridItem,gridItem,gridItem]

        return ZStack {
            LinearGradient(
                colors: CT.Colors.backgroundArr.isEmpty ?[.black,.black] :CT.Colors.backgroundArr,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading) {
                if UserDefaults.standard.bool(forKey: showWhatsNewKey) {
                    toolbarView
                }
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: isCompact ?columns_1 :deviceIs().PadLandscape ?columns_3 :columns_2,
                        alignment: .center,
                        spacing: isCompact ?5 :deviceIs().PadLandscape ?25 :50,
                        pinnedViews: [.sectionHeaders, .sectionFooters]
                    ) {
                        if filteredItems.count < 1 {
                            noContentView(title: "No items found for this version.", icon: "list.bullet.rectangle.fill")
                        }else{
                            ForEach(filteredItems, id: \.id) { WNItem in
                                HStack(alignment: .top) {
                                    Image(WNItem.iconName, bundle: .module)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(CT.title)
                                        .frame(width: iconSize, height: iconSize, alignment: .topLeading)

                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(WNItem.title)
                                            .font(.title2)
                                            .fontWeight(deviceIs.Pad ?.bold :.regular)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.75)
                                            .padding(.bottom,1)
                                            .foregroundStyle(CT.medium)

                                        Text(WNItem.detail)
                                            .font(deviceIs.Pad ?.headline :.callout)
                                            .italic()
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(CT.fair)

                                        Spacer()
                                    }//End VStack
                                    .padding(.leading,20)

                                    Spacer()
                                }//End HStack
                                .frame(minWidth: 200, maxWidth: 500, minHeight: 75, maxHeight: 150, alignment: .leading)
                                .font(.title3)
                            }
                        }
                    }
                    .padding(.bottom,30)
                    .padding(.top,15)
                }
                .padding(.horizontal,10)

                Spacer()
            }
            .padding(.horizontal,10)
            .edgesIgnoringSafeArea(.bottom)
            .toolbar {
                TB().title("What's New in the app")
                TB().subtitle("App Version v\(appVersion)")

                if versions.count > 0 {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Section(header: Text("CURRENT VERSION")) {
                                Button {
                                    currentVersion = Double(versions[0])!
                                    filterVersions()
                                } label: {
                                    Text("v\(versions[0])")
                                }
                            }
                            
                            Section(header: Text("PRIOR VERSIONS")) {
                                ForEach(versions, id: \.self) { item in
                                    Button("v\(item)") {
                                        filterVersions()
                                    }
                                }
                            }
                        } label: {
                            Label("", systemImage: "books.vertical")
                        }//End Menu
                    }
                }//End If
            }
        }
        .task(priority: .high) {
            loadBasicData()
        }
    }
}

#Preview {
    WhatsNewView()
}
