import * as admin from 'firebase-admin';
import * as path from 'path';
import axios from 'axios';

const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'pregame-b089e.firebasestorage.app'
});

const bucket = admin.storage().bucket();

async function main() {
  const testFile = 'managers/arg_arg_lionel_scaloni.png';

  console.log(`Testing access to: ${testFile}\n`);

  // Get file reference
  const file = bucket.file(testFile);

  // Check if file exists
  const [exists] = await file.exists();
  console.log(`File exists: ${exists}`);

  if (!exists) {
    console.log('File not found!');
    process.exit(1);
  }

  // Get metadata
  const [metadata] = await file.getMetadata();
  console.log(`Content type: ${metadata.contentType}`);
  console.log(`Size: ${metadata.size} bytes`);
  console.log(`Public: ${metadata.acl?.find((a: any) => a.entity === 'allUsers') ? 'Yes' : 'No/Unknown'}`);

  // Try to make it public
  console.log('\nMaking file public...');
  try {
    await file.makePublic();
    console.log('File is now public');
  } catch (err: any) {
    console.log('Error making public:', err.message);
  }

  // Generate signed URL (always works)
  const [signedUrl] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 60 * 60 * 1000, // 1 hour
  });
  console.log(`\nSigned URL: ${signedUrl}`);

  // Test the Firebase Storage URL
  const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(testFile)}?alt=media`;
  console.log(`\nPublic URL: ${publicUrl}`);

  try {
    const response = await axios.head(publicUrl);
    console.log(`URL accessible: Yes (status ${response.status})`);
  } catch (err: any) {
    console.log(`URL accessible: No (${err.response?.status || err.message})`);
  }

  process.exit(0);
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
