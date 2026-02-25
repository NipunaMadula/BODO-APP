# Firestore migration: set `available: true` for existing listings

This repository includes a small Node.js script to set `available: true` on existing documents in the `listings` collection that are missing the `available` field.

Preconditions
- You need a Firebase service account JSON with sufficient Firestore write permissions.
- Node.js (14+) and npm installed locally.

Steps
1. From the repo root, install the dependency:

```bash
npm install firebase-admin
```

2. Point the SDK to your service account JSON:

Windows (PowerShell):

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\path\to\serviceAccount.json'
node tools\set_available_migration.js
```

macOS / Linux:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
node tools/set_available_migration.js
```

3. Monitor console output — the script runs in batches and reports how many documents it updated.

Notes
- This is a one-time migration; after running you can remove the script if you like.
- Test in a staging project first.
- If you prefer, the same logic can be implemented as a Cloud Function or using the Firebase Admin SDK in other languages.
