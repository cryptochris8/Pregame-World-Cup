import { 
  collection, 
  doc, 
  getDoc, 
  setDoc, 
  updateDoc, 
  deleteDoc,
  query, 
  where, 
  getDocs,
  orderBy,
  Timestamp 
} from 'firebase/firestore';
import { db } from '../firebase/firebaseConfig';

export interface Special {
  id: string;
  venueId: string;
  name: string;
  description: string;
  originalPrice: number;
  specialPrice: number;
  category: 'food' | 'drink' | 'combo';
  isActive: boolean;
  startTime: string;
  endTime: string;
  gameSpecific: boolean;
  scheduledGames: string[];
  daysOfWeek?: number[]; // 0-6 (Sunday-Saturday)
  validUntil?: Timestamp;
  image?: string;
  redemptionCount: number;
  maxRedemptions?: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface SpecialStats {
  totalSpecials: number;
  activeSpecials: number;
  totalRedemptions: number;
  revenue: number;
  popularSpecials: {
    specialId: string;
    name: string;
    redemptions: number;
  }[];
}

class SpecialsService {
  private specialsCollection = collection(db, 'specials');

  /**
   * Get all specials for a venue
   */
  async getVenueSpecials(venueId: string): Promise<Special[]> {
    try {
      const q = query(
        this.specialsCollection, 
        where('venueId', '==', venueId),
        orderBy('createdAt', 'desc')
      );
      const querySnapshot = await getDocs(q);
      
      const specials: Special[] = [];
      querySnapshot.forEach((doc) => {
        specials.push({ id: doc.id, ...doc.data() } as Special);
      });
      
      return specials;
    } catch (error) {
      console.error('Error fetching venue specials:', error);
      throw error;
    }
  }

  /**
   * Get active specials for a venue
   */
  async getActiveVenueSpecials(venueId: string): Promise<Special[]> {
    try {
      const q = query(
        this.specialsCollection,
        where('venueId', '==', venueId),
        where('isActive', '==', true),
        orderBy('createdAt', 'desc')
      );
      const querySnapshot = await getDocs(q);
      
      const specials: Special[] = [];
      const now = new Date();
      const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
      const currentDay = now.getDay();
      
      querySnapshot.forEach((doc) => {
        const special = { id: doc.id, ...doc.data() } as Special;
        
        // Check if special is currently valid
        const isTimeValid = currentTime >= special.startTime && currentTime <= special.endTime;
        const isDayValid = !special.daysOfWeek || special.daysOfWeek.includes(currentDay);
        const isNotExpired = !special.validUntil || special.validUntil.toDate() > now;
        const hasRedemptionsLeft = !special.maxRedemptions || special.redemptionCount < special.maxRedemptions;
        
        if (isTimeValid && isDayValid && isNotExpired && hasRedemptionsLeft) {
          specials.push(special);
        }
      });
      
      return specials;
    } catch (error) {
      console.error('Error fetching active venue specials:', error);
      throw error;
    }
  }

  /**
   * Get special by ID
   */
  async getSpecial(specialId: string): Promise<Special | null> {
    try {
      const specialDoc = await getDoc(doc(this.specialsCollection, specialId));
      if (specialDoc.exists()) {
        return { id: specialDoc.id, ...specialDoc.data() } as Special;
      }
      return null;
    } catch (error) {
      console.error('Error fetching special:', error);
      throw error;
    }
  }

  /**
   * Create new special
   */
  async createSpecial(specialData: Omit<Special, 'id' | 'createdAt' | 'updatedAt' | 'redemptionCount'>): Promise<string> {
    try {
      const specialId = doc(this.specialsCollection).id;
      const now = Timestamp.now();
      
      const newSpecial: Omit<Special, 'id'> = {
        ...specialData,
        redemptionCount: 0,
        createdAt: now,
        updatedAt: now,
      };

      await setDoc(doc(this.specialsCollection, specialId), newSpecial);
      return specialId;
    } catch (error) {
      console.error('Error creating special:', error);
      throw error;
    }
  }

  /**
   * Update special
   */
  async updateSpecial(specialId: string, updates: Partial<Special>): Promise<void> {
    try {
      const specialRef = doc(this.specialsCollection, specialId);
      await updateDoc(specialRef, {
        ...updates,
        updatedAt: Timestamp.now(),
      });
    } catch (error) {
      console.error('Error updating special:', error);
      throw error;
    }
  }

  /**
   * Delete special
   */
  async deleteSpecial(specialId: string): Promise<void> {
    try {
      await deleteDoc(doc(this.specialsCollection, specialId));
    } catch (error) {
      console.error('Error deleting special:', error);
      throw error;
    }
  }

  /**
   * Toggle special active status
   */
  async toggleSpecialStatus(specialId: string): Promise<void> {
    try {
      const special = await this.getSpecial(specialId);
      if (special) {
        await this.updateSpecial(specialId, { isActive: !special.isActive });
      }
    } catch (error) {
      console.error('Error toggling special status:', error);
      throw error;
    }
  }

  /**
   * Redeem special (increment redemption count)
   */
  async redeemSpecial(specialId: string, fanId: string): Promise<boolean> {
    try {
      const special = await this.getSpecial(specialId);
      if (!special) {
        throw new Error('Special not found');
      }

      // Check if special can be redeemed
      if (!special.isActive) {
        throw new Error('Special is not active');
      }

      if (special.maxRedemptions && special.redemptionCount >= special.maxRedemptions) {
        throw new Error('Special has reached maximum redemptions');
      }

      // Check time validity
      const now = new Date();
      const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
      if (currentTime < special.startTime || currentTime > special.endTime) {
        throw new Error('Special is not available at this time');
      }

      // Increment redemption count
      await this.updateSpecial(specialId, {
        redemptionCount: special.redemptionCount + 1
      });

      // Log redemption (you might want to create a separate redemptions collection)
      await this.logSpecialRedemption(specialId, fanId);

      return true;
    } catch (error) {
      console.error('Error redeeming special:', error);
      throw error;
    }
  }

  /**
   * Get special statistics for a venue
   */
  async getSpecialStats(venueId: string): Promise<SpecialStats> {
    try {
      const q = query(this.specialsCollection, where('venueId', '==', venueId));
      const querySnapshot = await getDocs(q);
      
      let totalSpecials = 0;
      let activeSpecials = 0;
      let totalRedemptions = 0;
      let revenue = 0;
      const popularSpecials: { specialId: string; name: string; redemptions: number }[] = [];

      querySnapshot.forEach((doc) => {
        const special = doc.data() as Special;
        totalSpecials++;
        
        if (special.isActive) {
          activeSpecials++;
        }
        
        totalRedemptions += special.redemptionCount;
        revenue += special.redemptionCount * special.specialPrice;
        
        popularSpecials.push({
          specialId: doc.id,
          name: special.name,
          redemptions: special.redemptionCount
        });
      });

      // Sort by redemptions and take top 5
      popularSpecials.sort((a, b) => b.redemptions - a.redemptions);
      
      return {
        totalSpecials,
        activeSpecials,
        totalRedemptions,
        revenue,
        popularSpecials: popularSpecials.slice(0, 5)
      };
    } catch (error) {
      console.error('Error fetching special stats:', error);
      throw error;
    }
  }

  /**
   * Get game-specific specials
   */
  async getGameSpecials(venueId: string, gameInfo: string): Promise<Special[]> {
    try {
      const q = query(
        this.specialsCollection,
        where('venueId', '==', venueId),
        where('gameSpecific', '==', true),
        where('isActive', '==', true)
      );
      const querySnapshot = await getDocs(q);
      
      const gameSpecials: Special[] = [];
      querySnapshot.forEach((doc) => {
        const special = { id: doc.id, ...doc.data() } as Special;
        
        // Check if this special applies to the current game
        if (special.scheduledGames.some(game => 
          game.toLowerCase().includes(gameInfo.toLowerCase()) ||
          gameInfo.toLowerCase().includes(game.toLowerCase())
        )) {
          gameSpecials.push(special);
        }
      });
      
      return gameSpecials;
    } catch (error) {
      console.error('Error fetching game specials:', error);
      throw error;
    }
  }

  /**
   * Search specials by category
   */
  async getSpecialsByCategory(venueId: string, category: 'food' | 'drink' | 'combo'): Promise<Special[]> {
    try {
      const q = query(
        this.specialsCollection,
        where('venueId', '==', venueId),
        where('category', '==', category),
        where('isActive', '==', true),
        orderBy('specialPrice', 'asc')
      );
      const querySnapshot = await getDocs(q);
      
      const specials: Special[] = [];
      querySnapshot.forEach((doc) => {
        specials.push({ id: doc.id, ...doc.data() } as Special);
      });
      
      return specials;
    } catch (error) {
      console.error('Error fetching specials by category:', error);
      throw error;
    }
  }

  /**
   * Log special redemption
   */
  private async logSpecialRedemption(specialId: string, fanId: string): Promise<void> {
    try {
      const redemptionRef = doc(collection(db, 'specialRedemptions'));
      await setDoc(redemptionRef, {
        specialId,
        fanId,
        redeemedAt: Timestamp.now(),
      });
    } catch (error) {
      console.error('Error logging special redemption:', error);
      // Don't throw error here as it's not critical
    }
  }

  /**
   * Calculate discount percentage
   */
  calculateDiscount(originalPrice: number, specialPrice: number): number {
    return Math.round(((originalPrice - specialPrice) / originalPrice) * 100);
  }

  /**
   * Bulk activate/deactivate specials
   */
  async bulkToggleSpecials(specialIds: string[], isActive: boolean): Promise<void> {
    try {
      const promises = specialIds.map(id => this.updateSpecial(id, { isActive }));
      await Promise.all(promises);
    } catch (error) {
      console.error('Error bulk toggling specials:', error);
      throw error;
    }
  }
}

export const specialsService = new SpecialsService(); 