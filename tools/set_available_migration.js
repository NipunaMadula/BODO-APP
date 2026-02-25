// One-time migration script to set `available: true` on existing listings
// Usage:
// 1. Install dependencies: `npm install firebase-admin`
// 2. Set service account JSON: `set GOOGLE_APPLICATION_CREDENTIALS=path\\to\\serviceAccount.json` (Windows)
//    or `export GOOGLE_APPLICATION_CREDENTIALS=path/to/serviceAccount.json` (macOS/Linux)
// 3. Run: `node tools/set_available_migration.js`

const admin = require('firebase-admin');

// Initialize using Application Default Credentials (expects GOOGLE_APPLICATION_CREDENTIALS env var)
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();
const BATCH_SIZE = 500;

async function migrate() {
  console.log('Starting migration: setting available=true for listings missing the field');

  let lastId = null;
  while (true) {
    let query = db.collection('listings').orderBy(admin.firestore.FieldPath.documentId()).limit(BATCH_SIZE);
    if (lastId) query = query.startAfter(lastId);

    const snapshot = await query.get();
    if (snapshot.empty) {
      console.log('No more documents to process');
      break;
    }

    const batch = db.batch();
    let updates = 0;

    snapshot.docs.forEach((doc) => {
      const data = doc.data();
      if (!Object.prototype.hasOwnProperty.call(data, 'available') || data.available === null) {
        batch.update(doc.ref, { available: true });
        updates++;
      }
    });

    if (updates > 0) {
      await batch.commit();
      console.log(`Committed batch, updated ${updates} documents`);
    } else {
      console.log('No updates required for this batch');
    }

    lastId = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.size < BATCH_SIZE) break;
  }

  console.log('Migration completed');
}

migrate().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
