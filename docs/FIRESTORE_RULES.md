What I added

- `firestore.rules` at the project root containing secure rules to allow authenticated users to create `payments` documents and allow reads by payer or listing owner.

How to deploy rules

1) Using Firebase Console
   - Open Firebase Console → Firestore → Rules
   - Replace the rules with the contents of `firestore.rules`
   - Click Publish

2) Using Firebase CLI
   - Install and login if needed:

```bash
npm install -g firebase-tools
firebase login
```

   - Save `firestore.rules` (already in repo) and run:

```bash
firebase deploy --only firestore:rules
```

Notes & alternatives

- I cannot publish rules to your Firebase project from here (no access). You must apply them in your Firebase Console or deploy via the CLI with credentials.
- If you cannot change rules in production, I can add a Firebase Cloud Function (Node.js) that uses the Admin SDK to record payments server-side; you'll need to deploy that function and call it from the app instead of writing directly to Firestore.

Want me to add a Cloud Function implementation and the client call? Reply yes and I will scaffold it in the repo.