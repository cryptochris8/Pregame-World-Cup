import { 
  collection, 
  doc, 
  getDoc, 
  setDoc, 
  updateDoc, 
  query, 
  where, 
  getDocs,
  orderBy,
  limit,
  Timestamp 
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage';
import { db, storage } from '../firebase/firebaseConfig';

export interface VenueProfile {
  id: string;
  ownerId: string;
  name: string;
  description: string;
  address: string;
  phone: string;
  email: string;
  website?: string;
  capacity: number;
  venueType: 'Sports Bar' | 'Restaurant' | 'Brewery' | 'Pub' | 'Grill' | 'Cafe';
  amenities: string[];
  regularHours: {
    [key: string]: { open: string; close: string; isClosed: boolean };
  };
  gameDayHours: {
    [key: string]: { open: string; close: string; isClosed: boolean };
  };
  socialMedia: {
    facebook?: string;
    instagram?: string;
    twitter?: string;
  };
  images: string[];
  rating: number;
  reviewCount: number;
  isVerified: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  location: {
    latitude: number;
    longitude: number;
  };
  schoolAffiliation?: string; // SEC school
}

export interface VenueStats {
  totalVisits: number;
  todayVisits: number;
  weeklyVisits: number[];
  monthlyGrowth: number;
  activeSpecials: number;
  fanRating: number;
  liveViewers: number;
  totalRevenue: number;
  specialsRevenue: number;
  averageSpend: number;
}

class VenueService {
  private venueCollection = collection(db, 'venues');
  private venueStatsCollection = collection(db, 'venueStats');

  /**
   * Get venue profile by ID
   */
  async getVenueProfile(venueId: string): Promise<VenueProfile | null> {
    try {
      const venueDoc = await getDoc(doc(this.venueCollection, venueId));
      if (venueDoc.exists()) {
        return { id: venueDoc.id, ...venueDoc.data() } as VenueProfile;
      }
      return null;
    } catch (error) {
      console.error('Error fetching venue profile:', error);
      throw error;
    }
  }

  /**
   * Get venue profile by owner ID
   */
  async getVenueByOwnerId(ownerId: string): Promise<VenueProfile | null> {
    try {
      const q = query(this.venueCollection, where('ownerId', '==', ownerId), limit(1));
      const querySnapshot = await getDocs(q);
      
      if (!querySnapshot.empty) {
        const doc = querySnapshot.docs[0];
        return { id: doc.id, ...doc.data() } as VenueProfile;
      }
      return null;
    } catch (error) {
      console.error('Error fetching venue by owner:', error);
      throw error;
    }
  }

  /**
   * Create new venue profile
   */
  async createVenueProfile(venueData: Omit<VenueProfile, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const venueId = doc(this.venueCollection).id;
      const now = Timestamp.now();
      
      const newVenue: Omit<VenueProfile, 'id'> = {
        ...venueData,
        createdAt: now,
        updatedAt: now,
      };

      await setDoc(doc(this.venueCollection, venueId), newVenue);
      
      // Initialize venue stats
      await this.initializeVenueStats(venueId);
      
      return venueId;
    } catch (error) {
      console.error('Error creating venue profile:', error);
      throw error;
    }
  }

  /**
   * Update venue profile
   */
  async updateVenueProfile(venueId: string, updates: Partial<VenueProfile>): Promise<void> {
    try {
      const venueRef = doc(this.venueCollection, venueId);
      await updateDoc(venueRef, {
        ...updates,
        updatedAt: Timestamp.now(),
      });
    } catch (error) {
      console.error('Error updating venue profile:', error);
      throw error;
    }
  }

  /**
   * Upload venue image
   */
  async uploadVenueImage(venueId: string, file: File): Promise<string> {
    try {
      const imageRef = ref(storage, `venues/${venueId}/images/${Date.now()}_${file.name}`);
      const snapshot = await uploadBytes(imageRef, file);
      const downloadURL = await getDownloadURL(snapshot.ref);
      
      // Add image URL to venue profile
      const venueProfile = await this.getVenueProfile(venueId);
      if (venueProfile) {
        const updatedImages = [...venueProfile.images, downloadURL];
        await this.updateVenueProfile(venueId, { images: updatedImages });
      }
      
      return downloadURL;
    } catch (error) {
      console.error('Error uploading venue image:', error);
      throw error;
    }
  }

  /**
   * Delete venue image
   */
  async deleteVenueImage(venueId: string, imageUrl: string): Promise<void> {
    try {
      // Remove from storage
      const imageRef = ref(storage, imageUrl);
      await deleteObject(imageRef);
      
      // Remove from venue profile
      const venueProfile = await this.getVenueProfile(venueId);
      if (venueProfile) {
        const updatedImages = venueProfile.images.filter(img => img !== imageUrl);
        await this.updateVenueProfile(venueId, { images: updatedImages });
      }
    } catch (error) {
      console.error('Error deleting venue image:', error);
      throw error;
    }
  }

  /**
   * Get venue statistics
   */
  async getVenueStats(venueId: string): Promise<VenueStats | null> {
    try {
      const statsDoc = await getDoc(doc(this.venueStatsCollection, venueId));
      if (statsDoc.exists()) {
        return statsDoc.data() as VenueStats;
      }
      return null;
    } catch (error) {
      console.error('Error fetching venue stats:', error);
      throw error;
    }
  }

  /**
   * Update venue statistics
   */
  async updateVenueStats(venueId: string, stats: Partial<VenueStats>): Promise<void> {
    try {
      const statsRef = doc(this.venueStatsCollection, venueId);
      await updateDoc(statsRef, stats);
    } catch (error) {
      console.error('Error updating venue stats:', error);
      throw error;
    }
  }

  /**
   * Initialize venue statistics
   */
  private async initializeVenueStats(venueId: string): Promise<void> {
    const initialStats: VenueStats = {
      totalVisits: 0,
      todayVisits: 0,
      weeklyVisits: [0, 0, 0, 0, 0, 0, 0],
      monthlyGrowth: 0,
      activeSpecials: 0,
      fanRating: 0,
      liveViewers: 0,
      totalRevenue: 0,
      specialsRevenue: 0,
      averageSpend: 0,
    };

    await setDoc(doc(this.venueStatsCollection, venueId), initialStats);
  }

  /**
   * Get venues near location (for discovery)
   */
  async getVenuesNearLocation(lat: number, lng: number, radiusKm: number = 10): Promise<VenueProfile[]> {
    try {
      // Note: For production, you'd want to use geohashing or Google Cloud Firestore's 
      // geospatial queries. This is a simplified version.
      const q = query(this.venueCollection, where('isVerified', '==', true));
      const querySnapshot = await getDocs(q);
      
      const venues: VenueProfile[] = [];
      querySnapshot.forEach((doc) => {
        const venue = { id: doc.id, ...doc.data() } as VenueProfile;
        
        // Simple distance calculation (for demo purposes)
        const distance = this.calculateDistance(
          lat, lng, 
          venue.location.latitude, 
          venue.location.longitude
        );
        
        if (distance <= radiusKm) {
          venues.push(venue);
        }
      });
      
      return venues.sort((a, b) => b.rating - a.rating);
    } catch (error) {
      console.error('Error fetching nearby venues:', error);
      throw error;
    }
  }

  /**
   * Calculate distance between two coordinates (Haversine formula)
   */
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in kilometers
    const dLat = this.degreesToRadians(lat2 - lat1);
    const dLon = this.degreesToRadians(lon2 - lon1);
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(this.degreesToRadians(lat1)) * Math.cos(this.degreesToRadians(lat2)) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }

  private degreesToRadians(degrees: number): number {
    return degrees * (Math.PI/180);
  }
}

export const venueService = new VenueService(); 