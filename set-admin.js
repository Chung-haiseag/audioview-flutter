const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

const email = process.argv[2];
const password = process.argv[3] || 'admin1234!'; // Default password if not provided

if (!email) {
    console.error('Please provide an email address: node set-admin.js user@example.com [password]');
    process.exit(1);
}

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

async function setupAdmin(email, password) {
    try {
        let user;
        try {
            user = await admin.auth().getUserByEmail(email);
            // Update password for existing user
            await admin.auth().updateUser(user.uid, { password: password });
            console.log(`User already exists: ${user.email}. Password has been reset.`);
        } catch (error) {
            if (error.code === 'auth/user-not-found') {
                user = await admin.auth().createUser({
                    email: email,
                    password: password,
                    emailVerified: true
                });
                console.log(`New user created: ${email} with password: ${password}`);
            } else {
                throw error;
            }
        }

        // Set admin custom claim
        await admin.auth().setCustomUserClaims(user.uid, { admin: true });
        console.log(`Success! Admin privileges granted to: ${email}`);
        console.log('Now you can log in with this email and password.');
        process.exit(0);
    } catch (error) {
        console.error('Error during setup:', error);
        process.exit(1);
    }
}

setupAdmin(email, password);
