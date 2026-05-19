import { getFunctions, httpsCallable } from 'firebase/functions';
import app from '../firebase/firebaseConfig';

const functions = getFunctions(app, 'us-central1');

export interface ClaimVenueInput {
  venueId: string;
  businessName: string;
  contactEmail: string;
  ownerRole: string;
  venueType: string;
  venuePhoneNumber: string;
}

export interface ClaimVenueResult {
  success: boolean;
  venueId: string;
}

export const claimVenue = httpsCallable<ClaimVenueInput, ClaimVenueResult>(
  functions,
  'claimVenue',
);

export interface SendVerificationCodeInput {
  venueId: string;
}

export interface SendVerificationCodeResult {
  success: boolean;
  message: string;
}

export const sendVenueVerificationCode = httpsCallable<
  SendVerificationCodeInput,
  SendVerificationCodeResult
>(functions, 'sendVenueVerificationCode');

export interface VerifyCodeInput {
  venueId: string;
  code: string;
}

export interface VerifyCodeResult {
  success: boolean;
  message: string;
}

export const verifyVenueCode = httpsCallable<VerifyCodeInput, VerifyCodeResult>(
  functions,
  'verifyVenueCode',
);

export interface CreateVenuePremiumCheckoutInput {
  venueId: string;
  venueName?: string;
  successUrl?: string;
  cancelUrl?: string;
}

export interface CreateVenuePremiumCheckoutResult {
  sessionId: string;
  url: string;
}

export const createVenuePremiumCheckout = httpsCallable<
  CreateVenuePremiumCheckoutInput,
  CreateVenuePremiumCheckoutResult
>(functions, 'createVenuePremiumCheckout');
