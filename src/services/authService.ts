import { 
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  sendPasswordResetEmail,
  updateProfile,
  User,
  UserCredential
} from 'firebase/auth';
import { doc, setDoc, getDoc, updateDoc, Timestamp } from 'firebase/firestore';
import { auth, db } from '../firebase/firebaseConfig';

export interface VenueOwner {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
  phone?: string;
  venueId?: string;
  isVerified: boolean;
  role: 'venue_owner' | 'admin';
  createdAt: Timestamp;
  lastLoginAt: Timestamp;
  profileImage?: string;
}

export interface AuthState {
  user: User | null;
  venueOwner: VenueOwner | null;
  loading: boolean;
  error: string | null;
}

class AuthService {
  private venueOwnersCollection = 'venueOwners';

  /**
   * Sign in venue owner with email and password
   */
  async signIn(email: string, password: string): Promise<VenueOwner> {
    try {
      const userCredential: UserCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      
      // Get venue owner profile
      const venueOwner = await this.getVenueOwnerProfile(user.uid);
      if (!venueOwner) {
        throw new Error('Venue owner profile not found');
      }

      // Update last login time
      await this.updateLastLogin(user.uid);
      
      return venueOwner;
    } catch (error: any) {
      console.error('Error signing in:', error);
      throw new Error(this.getAuthErrorMessage(error.code));
    }
  }

  /**
   * Create new venue owner account
   */
  async signUp(
    email: string, 
    password: string, 
    firstName: string, 
    lastName: string,
    phone?: string
  ): Promise<VenueOwner> {
    try {
      const userCredential: UserCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      
      // Update user profile
      await updateProfile(user, {
        displayName: `${firstName} ${lastName}`
      });

      // Create venue owner profile
      const venueOwner: VenueOwner = {
        uid: user.uid,
        email: user.email!,
        displayName: `${firstName} ${lastName}`,
        firstName,
        lastName,
        phone,
        isVerified: false,
        role: 'venue_owner',
        createdAt: Timestamp.now(),
        lastLoginAt: Timestamp.now(),
      };

      await this.createVenueOwnerProfile(venueOwner);
      
      return venueOwner;
    } catch (error: any) {
      console.error('Error creating account:', error);
      throw new Error(this.getAuthErrorMessage(error.code));
    }
  }

  /**
   * Sign out current user
   */
  async signOut(): Promise<void> {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Error signing out:', error);
      throw error;
    }
  }

  /**
   * Send password reset email
   */
  async resetPassword(email: string): Promise<void> {
    try {
      await sendPasswordResetEmail(auth, email);
    } catch (error: any) {
      console.error('Error sending password reset email:', error);
      throw new Error(this.getAuthErrorMessage(error.code));
    }
  }

  /**
   * Get venue owner profile by UID
   */
  async getVenueOwnerProfile(uid: string): Promise<VenueOwner | null> {
    try {
      const docRef = doc(db, this.venueOwnersCollection, uid);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists()) {
        return docSnap.data() as VenueOwner;
      }
      return null;
    } catch (error) {
      console.error('Error fetching venue owner profile:', error);
      throw error;
    }
  }

  /**
   * Create venue owner profile in Firestore
   */
  async createVenueOwnerProfile(venueOwner: VenueOwner): Promise<void> {
    try {
      const docRef = doc(db, this.venueOwnersCollection, venueOwner.uid);
      await setDoc(docRef, venueOwner);
    } catch (error) {
      console.error('Error creating venue owner profile:', error);
      throw error;
    }
  }

  /**
   * Update venue owner profile
   */
  async updateVenueOwnerProfile(uid: string, updates: Partial<VenueOwner>): Promise<void> {
    try {
      const docRef = doc(db, this.venueOwnersCollection, uid);
      await updateDoc(docRef, updates);
    } catch (error) {
      console.error('Error updating venue owner profile:', error);
      throw error;
    }
  }

  /**
   * Link venue to owner
   */
  async linkVenueToOwner(uid: string, venueId: string): Promise<void> {
    try {
      await this.updateVenueOwnerProfile(uid, { venueId });
    } catch (error) {
      console.error('Error linking venue to owner:', error);
      throw error;
    }
  }

  /**
   * Verify venue owner
   */
  async verifyVenueOwner(uid: string): Promise<void> {
    try {
      await this.updateVenueOwnerProfile(uid, { isVerified: true });
    } catch (error) {
      console.error('Error verifying venue owner:', error);
      throw error;
    }
  }

  /**
   * Update last login time
   */
  private async updateLastLogin(uid: string): Promise<void> {
    try {
      await this.updateVenueOwnerProfile(uid, { lastLoginAt: Timestamp.now() });
    } catch (error) {
      console.error('Error updating last login:', error);
      // Don't throw error as it's not critical
    }
  }

  /**
   * Set up auth state listener
   */
  onAuthStateChanged(callback: (user: User | null) => void): () => void {
    return onAuthStateChanged(auth, callback);
  }

  /**
   * Get current user
   */
  getCurrentUser(): User | null {
    return auth.currentUser;
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated(): boolean {
    return !!auth.currentUser;
  }

  /**
   * Get user ID token
   */
  async getIdToken(): Promise<string | null> {
    if (auth.currentUser) {
      return await auth.currentUser.getIdToken();
    }
    return null;
  }

  /**
   * Convert Firebase auth error codes to user-friendly messages
   */
  private getAuthErrorMessage(errorCode: string): string {
    switch (errorCode) {
      case 'auth/user-not-found':
        return 'No account found with this email address.';
      case 'auth/wrong-password':
        return 'Incorrect password.';
      case 'auth/email-already-in-use':
        return 'An account with this email already exists.';
      case 'auth/weak-password':
        return 'Password should be at least 6 characters.';
      case 'auth/invalid-email':
        return 'Invalid email address.';
      case 'auth/too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'auth/network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /**
   * Validate email format
   */
  isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Validate password strength
   */
  isValidPassword(password: string): { isValid: boolean; message: string } {
    if (password.length < 6) {
      return { isValid: false, message: 'Password must be at least 6 characters long.' };
    }
    
    if (!/(?=.*[a-z])/.test(password)) {
      return { isValid: false, message: 'Password must contain at least one lowercase letter.' };
    }
    
    if (!/(?=.*[A-Z])/.test(password)) {
      return { isValid: false, message: 'Password must contain at least one uppercase letter.' };
    }
    
    if (!/(?=.*\d)/.test(password)) {
      return { isValid: false, message: 'Password must contain at least one number.' };
    }
    
    return { isValid: true, message: 'Password is strong.' };
  }
}

export const authService = new AuthService(); 