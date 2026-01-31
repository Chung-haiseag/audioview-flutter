const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}

const db = admin.firestore();

async function checkLists() {
    const snapshot = await db.collection('featured_lists').get();
    snapshot.forEach(doc => {
        console.log(`ID: ${doc.id}, Name: ${doc.get('listName')}, Type: ${doc.get('type')}`);
    });
}

checkLists();
