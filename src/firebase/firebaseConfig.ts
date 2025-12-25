// Firebase configuration for Pregame Venue Portal
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';
import { getAnalytics } from 'firebase/analytics';

const firebaseConfig = {
  apiKey: "AIzaSyCmi4yeleQW3Oi-6VGmn7NPhpCYu88F4JM",
  authDomain: "pregame-b089e.firebaseapp.com",
  projectId: "pregame-b089e",
  storageBucket: "pregame-b089e.appspot.com",
  messagingSenderId: "942034010384",
  appId: "1:942034010384:web:fecbfbbdc8a0465b99a595",
  measurementId: "G-WEY5DQ2XV2"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export const analytics = getAnalytics(app);

export default app; 