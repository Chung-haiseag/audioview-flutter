const admin = require('firebase-admin');

// Try to initialize without explicit key if possible, otherwise this will fail
// In some environments, GOOGLE_APPLICATION_CREDENTIALS might be set.
try {
    admin.initializeApp();
} catch (e) {
    // If it fails, we know we need the key.
}

const db = admin.firestore();

async function listMovies() {
    try {
        const snapshot = await db.collection('movies').limit(20).get();
        snapshot.forEach(doc => {
            console.log(`MovieId: ${doc.id}, Title: ${doc.get('title')}`);
        });
    } catch (e) {
        console.error("Failed to list movies:", e.message);
    }
}

listMovies();
