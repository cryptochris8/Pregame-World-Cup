import * as admin from 'firebase-admin';
import * as path from 'path';

const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'pregame-b089e.firebasestorage.app'
});

const bucket = admin.storage().bucket();

async function main() {
  console.log('Checking Firebase Storage bucket:', bucket.name);

  try {
    // List all files
    const [files] = await bucket.getFiles({ maxResults: 20 });

    console.log(`\nFound ${files.length} files:`);
    files.forEach(file => {
      console.log('  - ' + file.name);
    });

    if (files.length === 0) {
      console.log('\n⚠️ No files found in storage bucket!');
      console.log('The upload might have failed or gone to a different bucket.');
    }
  } catch (error) {
    console.error('Error listing files:', error);
  }

  process.exit(0);
}

main();
