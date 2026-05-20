jest.mock('../../firebase/firebaseConfig', () => ({
  __esModule: true,
  auth: {},
  db: {},
  storage: {},
  analytics: {},
  default: {},
}));

jest.mock('firebase/auth', () => ({
  createUserWithEmailAndPassword: jest.fn(),
  signInWithEmailAndPassword: jest.fn(),
  updateProfile: jest.fn(),
  signOut: jest.fn(),
  onAuthStateChanged: jest.fn(),
  sendPasswordResetEmail: jest.fn(),
  getAuth: jest.fn(),
}));

jest.mock('firebase/firestore', () => ({
  doc: jest.fn(() => ({ id: 'doc-ref' })),
  setDoc: jest.fn(),
  getDoc: jest.fn(),
  updateDoc: jest.fn(),
  getFirestore: jest.fn(),
  collection: jest.fn(),
  Timestamp: { now: jest.fn(() => ({ seconds: 0, nanoseconds: 0 })) },
}));

import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  updateProfile,
} from 'firebase/auth';
import { getDoc, setDoc } from 'firebase/firestore';
import { authService } from '../authService';

const mockCreateUser = createUserWithEmailAndPassword as jest.Mock;
const mockSignIn = signInWithEmailAndPassword as jest.Mock;
const mockUpdateProfile = updateProfile as jest.Mock;
const mockGetDoc = getDoc as jest.Mock;
const mockSetDoc = setDoc as jest.Mock;

describe('authService.signUpOrSignIn', () => {
  beforeEach(() => {
    mockUpdateProfile.mockResolvedValue(undefined);
    mockSetDoc.mockResolvedValue(undefined);
  });

  it('creates a new account and profile when the email is unused', async () => {
    mockCreateUser.mockResolvedValue({ user: { uid: 'u1', email: 'new@bar.com' } });
    mockGetDoc.mockResolvedValue({ exists: () => false });

    const result = await authService.signUpOrSignIn(
      'new@bar.com',
      'Passw0rd',
      'Jane',
      'Doe',
      '5551234567',
    );

    expect(mockCreateUser).toHaveBeenCalledTimes(1);
    expect(mockSignIn).not.toHaveBeenCalled();
    expect(mockSetDoc).toHaveBeenCalledTimes(1);
    expect(result.uid).toBe('u1');
    expect(result.role).toBe('venue_owner');
    expect(result.phone).toBe('5551234567');
  });

  it('signs in and returns the existing profile when the email is already registered', async () => {
    mockCreateUser.mockRejectedValue({ code: 'auth/email-already-in-use' });
    mockSignIn.mockResolvedValue({ user: { uid: 'u2', email: 'exist@bar.com' } });
    mockGetDoc.mockResolvedValue({
      exists: () => true,
      data: () => ({
        uid: 'u2',
        email: 'exist@bar.com',
        role: 'venue_owner',
        firstName: 'Old',
        lastName: 'Owner',
      }),
    });

    const result = await authService.signUpOrSignIn(
      'exist@bar.com',
      'Passw0rd',
      'Jane',
      'Doe',
      '5551234567',
    );

    expect(mockSignIn).toHaveBeenCalledTimes(1);
    expect(mockSetDoc).not.toHaveBeenCalled();
    expect(result.firstName).toBe('Old');
  });

  it('signs in and creates a profile when the account exists but has no venue profile', async () => {
    mockCreateUser.mockRejectedValue({ code: 'auth/email-already-in-use' });
    mockSignIn.mockResolvedValue({ user: { uid: 'u3', email: 'exist2@bar.com' } });
    mockGetDoc.mockResolvedValue({ exists: () => false });

    const result = await authService.signUpOrSignIn(
      'exist2@bar.com',
      'Passw0rd',
      'Jane',
      'Doe',
      '5551234567',
    );

    expect(mockSignIn).toHaveBeenCalledTimes(1);
    expect(mockSetDoc).toHaveBeenCalledTimes(1);
    expect(result.uid).toBe('u3');
  });

  it('throws a clear message when the existing account password is wrong', async () => {
    mockCreateUser.mockRejectedValue({ code: 'auth/email-already-in-use' });
    mockSignIn.mockRejectedValue({ code: 'auth/wrong-password' });

    await expect(
      authService.signUpOrSignIn('exist@bar.com', 'WrongPass', 'Jane', 'Doe', '5551234567'),
    ).rejects.toThrow(/existing password/i);
  });

  it('treats invalid-credential the same as a wrong password', async () => {
    mockCreateUser.mockRejectedValue({ code: 'auth/email-already-in-use' });
    mockSignIn.mockRejectedValue({ code: 'auth/invalid-credential' });

    await expect(
      authService.signUpOrSignIn('exist@bar.com', 'WrongPass', 'Jane', 'Doe', '5551234567'),
    ).rejects.toThrow(/existing password/i);
  });

  it('surfaces a friendly message for other signup errors', async () => {
    mockCreateUser.mockRejectedValue({ code: 'auth/weak-password' });

    await expect(
      authService.signUpOrSignIn('new2@bar.com', '123', 'Jane', 'Doe', '5551234567'),
    ).rejects.toThrow(/at least 6 characters/i);
    expect(mockSignIn).not.toHaveBeenCalled();
  });
});
