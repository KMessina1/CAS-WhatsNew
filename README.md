# CAS-WhatsNew

Reusable SwiftUI "What's New" viewer support for apps that store release notes in a GRDB-backed SQLite database.

## Integration

1. Add `CAS-WhatsNew` as a package dependency and link the `CASWhatsNew` product to the app target.

2. Copy the sample database from this package:

   `Sample Data/WhatsNewStarterFile.db`

   into the app project’s local data/resource folder.

3. Rename the copied database file to:

   `WhatsNew.db`

4. In Xcode, select the local `WhatsNew.db` file and confirm it is included in the app target membership so it is bundled with the app.

5. Present `WhatsNewView` from the app and pass the app-owned database queue and app version:

   ```swift
   WhatsNewView(
       dbQueue: dbQueue_WhatsNew,
       appVersion: AppInfo.version
   )
   ```

The package owns the reusable UI, record model, and bundled image asset catalog used by release-note rows. The app remains responsible for keeping a local bundled database named `WhatsNew.db` and opening the database queue used by `WhatsNewView`.
