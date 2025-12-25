import { 
  collection, 
  doc, 
  setDoc, 
  updateDoc, 
  deleteDoc,
  getDoc,
  query, 
  where, 
  getDocs,
  onSnapshot,
  Timestamp 
} from 'firebase/firestore';
import { db } from '../firebase/firebaseConfig';

export interface LiveStream {
  id: string;
  venueId: string;
  title: string;
  description: string;
  streamKey: string;
  isLive: boolean;
  viewerCount: number;
  streamUrl: string;
  thumbnailUrl?: string;
  quality: '720p' | '1080p' | '480p';
  camera: 'main' | 'bar' | 'tv-area' | 'outdoor';
  startTime?: Timestamp;
  endTime?: Timestamp;
  totalViewTime: number; // in minutes
  peakViewers: number;
  chatEnabled: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ChatMessage {
  id: string;
  streamId: string;
  fanId: string;
  fanName: string;
  message: string;
  timestamp: Timestamp;
  isModerated: boolean;
}

export interface StreamStats {
  totalStreams: number;
  liveStreams: number;
  totalViewers: number;
  averageViewTime: number;
  popularCamera: string;
  totalChatMessages: number;
}

class LiveStreamService {
  private streamsCollection = collection(db, 'liveStreams');
  private chatCollection = collection(db, 'streamChat');
  private viewersCollection = collection(db, 'streamViewers');

  /**
   * Get all streams for a venue
   */
  async getVenueStreams(venueId: string): Promise<LiveStream[]> {
    try {
      const q = query(this.streamsCollection, where('venueId', '==', venueId));
      const querySnapshot = await getDocs(q);
      
      const streams: LiveStream[] = [];
      querySnapshot.forEach((doc) => {
        streams.push({ id: doc.id, ...doc.data() } as LiveStream);
      });
      
      return streams.sort((a, b) => b.createdAt.toMillis() - a.createdAt.toMillis());
    } catch (error) {
      console.error('Error fetching venue streams:', error);
      throw error;
    }
  }

  /**
   * Get active live streams for a venue
   */
  async getActiveLiveStreams(venueId: string): Promise<LiveStream[]> {
    try {
      const q = query(
        this.streamsCollection, 
        where('venueId', '==', venueId),
        where('isLive', '==', true)
      );
      const querySnapshot = await getDocs(q);
      
      const liveStreams: LiveStream[] = [];
      querySnapshot.forEach((doc) => {
        liveStreams.push({ id: doc.id, ...doc.data() } as LiveStream);
      });
      
      return liveStreams;
    } catch (error) {
      console.error('Error fetching active live streams:', error);
      throw error;
    }
  }

  /**
   * Create new live stream
   */
  async createLiveStream(streamData: Omit<LiveStream, 'id' | 'createdAt' | 'updatedAt' | 'viewerCount' | 'totalViewTime' | 'peakViewers'>): Promise<string> {
    try {
      const streamId = doc(this.streamsCollection).id;
      const now = Timestamp.now();
      
      const newStream: Omit<LiveStream, 'id'> = {
        ...streamData,
        viewerCount: 0,
        totalViewTime: 0,
        peakViewers: 0,
        createdAt: now,
        updatedAt: now,
      };

      await setDoc(doc(this.streamsCollection, streamId), newStream);
      return streamId;
    } catch (error) {
      console.error('Error creating live stream:', error);
      throw error;
    }
  }

  /**
   * Start live stream
   */
  async startStream(streamId: string): Promise<void> {
    try {
      const streamRef = doc(this.streamsCollection, streamId);
      await updateDoc(streamRef, {
        isLive: true,
        startTime: Timestamp.now(),
        updatedAt: Timestamp.now(),
      });
    } catch (error) {
      console.error('Error starting stream:', error);
      throw error;
    }
  }

  /**
   * Stop live stream
   */
  async stopStream(streamId: string): Promise<void> {
    try {
      const streamRef = doc(this.streamsCollection, streamId);
      await updateDoc(streamRef, {
        isLive: false,
        endTime: Timestamp.now(),
        updatedAt: Timestamp.now(),
      });
    } catch (error) {
      console.error('Error stopping stream:', error);
      throw error;
    }
  }

  /**
   * Update stream settings
   */
  async updateStreamSettings(streamId: string, updates: Partial<LiveStream>): Promise<void> {
    try {
      const streamRef = doc(this.streamsCollection, streamId);
      await updateDoc(streamRef, {
        ...updates,
        updatedAt: Timestamp.now(),
      });
    } catch (error) {
      console.error('Error updating stream settings:', error);
      throw error;
    }
  }

  /**
   * Delete stream
   */
  async deleteStream(streamId: string): Promise<void> {
    try {
      // Delete stream document
      await deleteDoc(doc(this.streamsCollection, streamId));
      
      // Clean up related chat messages
      await this.deleteStreamChat(streamId);
    } catch (error) {
      console.error('Error deleting stream:', error);
      throw error;
    }
  }

  /**
   * Join stream as viewer
   */
  async joinStream(streamId: string, fanId: string): Promise<void> {
    try {
      // Add viewer to stream
      const viewerRef = doc(this.viewersCollection, `${streamId}_${fanId}`);
      await setDoc(viewerRef, {
        streamId,
        fanId,
        joinedAt: Timestamp.now(),
      });

      // Update viewer count
      await this.updateViewerCount(streamId);
    } catch (error) {
      console.error('Error joining stream:', error);
      throw error;
    }
  }

  /**
   * Leave stream
   */
  async leaveStream(streamId: string, fanId: string): Promise<void> {
    try {
      // Remove viewer from stream
      const viewerRef = doc(this.viewersCollection, `${streamId}_${fanId}`);
      await deleteDoc(viewerRef);

      // Update viewer count
      await this.updateViewerCount(streamId);
    } catch (error) {
      console.error('Error leaving stream:', error);
      throw error;
    }
  }

  /**
   * Send chat message
   */
  async sendChatMessage(streamId: string, fanId: string, fanName: string, message: string): Promise<string> {
    try {
      const messageId = doc(this.chatCollection).id;
      const chatMessage: Omit<ChatMessage, 'id'> = {
        streamId,
        fanId,
        fanName,
        message: message.trim(),
        timestamp: Timestamp.now(),
        isModerated: false,
      };

      await setDoc(doc(this.chatCollection, messageId), chatMessage);
      return messageId;
    } catch (error) {
      console.error('Error sending chat message:', error);
      throw error;
    }
  }

  /**
   * Get chat messages for stream
   */
  async getStreamChat(streamId: string, limit: number = 50): Promise<ChatMessage[]> {
    try {
      const q = query(
        this.chatCollection,
        where('streamId', '==', streamId),
        where('isModerated', '==', false)
        // Note: You'd want to add orderBy and limit here, but it requires a composite index
      );
      const querySnapshot = await getDocs(q);
      
      const messages: ChatMessage[] = [];
      querySnapshot.forEach((doc) => {
        messages.push({ id: doc.id, ...doc.data() } as ChatMessage);
      });
      
      // Sort by timestamp and limit
      return messages
        .sort((a, b) => b.timestamp.toMillis() - a.timestamp.toMillis())
        .slice(0, limit);
    } catch (error) {
      console.error('Error fetching stream chat:', error);
      throw error;
    }
  }

  /**
   * Moderate chat message
   */
  async moderateChatMessage(messageId: string, moderate: boolean = true): Promise<void> {
    try {
      const messageRef = doc(this.chatCollection, messageId);
      await updateDoc(messageRef, {
        isModerated: moderate,
      });
    } catch (error) {
      console.error('Error moderating chat message:', error);
      throw error;
    }
  }

  /**
   * Get stream statistics
   */
  async getStreamStats(venueId: string): Promise<StreamStats> {
    try {
      const q = query(this.streamsCollection, where('venueId', '==', venueId));
      const querySnapshot = await getDocs(q);
      
      let totalStreams = 0;
      let liveStreams = 0;
      let totalViewers = 0;
      let totalViewTime = 0;
      let totalChatMessages = 0;
      const cameraCounts: { [key: string]: number } = {};

      const streamIds: string[] = [];
      
      querySnapshot.forEach((doc) => {
        const stream = doc.data() as LiveStream;
        totalStreams++;
        streamIds.push(doc.id);
        
        if (stream.isLive) {
          liveStreams++;
        }
        
        totalViewers += stream.peakViewers;
        totalViewTime += stream.totalViewTime;
        
        cameraCounts[stream.camera] = (cameraCounts[stream.camera] || 0) + 1;
      });

      // Get chat message count
      for (const streamId of streamIds) {
        const chatQuery = query(this.chatCollection, where('streamId', '==', streamId));
        const chatSnapshot = await getDocs(chatQuery);
        totalChatMessages += chatSnapshot.size;
      }

      // Find most popular camera
      const popularCamera = Object.entries(cameraCounts)
        .sort(([,a], [,b]) => b - a)[0]?.[0] || 'main';

      return {
        totalStreams,
        liveStreams,
        totalViewers,
        averageViewTime: totalStreams > 0 ? totalViewTime / totalStreams : 0,
        popularCamera,
        totalChatMessages,
      };
    } catch (error) {
      console.error('Error fetching stream stats:', error);
      throw error;
    }
  }

  /**
   * Listen to stream updates (real-time)
   */
  subscribeToStream(streamId: string, callback: (stream: LiveStream | null) => void): () => void {
    const streamRef = doc(this.streamsCollection, streamId);
    
    return onSnapshot(streamRef, (doc) => {
      if (doc.exists()) {
        callback({ id: doc.id, ...doc.data() } as LiveStream);
      } else {
        callback(null);
      }
    });
  }

  /**
   * Listen to chat updates (real-time)
   */
  subscribeToChatMessages(streamId: string, callback: (messages: ChatMessage[]) => void): () => void {
    const q = query(
      this.chatCollection,
      where('streamId', '==', streamId),
      where('isModerated', '==', false)
    );
    
    return onSnapshot(q, (querySnapshot) => {
      const messages: ChatMessage[] = [];
      querySnapshot.forEach((doc) => {
        messages.push({ id: doc.id, ...doc.data() } as ChatMessage);
      });
      
      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.toMillis() - a.timestamp.toMillis());
      callback(messages);
    });
  }

  /**
   * Update viewer count for stream
   */
  private async updateViewerCount(streamId: string): Promise<void> {
    try {
      const q = query(this.viewersCollection, where('streamId', '==', streamId));
      const querySnapshot = await getDocs(q);
      const viewerCount = querySnapshot.size;

      // Update stream with current viewer count
      const streamRef = doc(this.streamsCollection, streamId);
      const streamDoc = await getDoc(streamRef);
      
      if (streamDoc.exists()) {
        const currentStream = streamDoc.data() as LiveStream;
        const peakViewers = Math.max(currentStream.peakViewers, viewerCount);
        
        await updateDoc(streamRef, {
          viewerCount,
          peakViewers,
          updatedAt: Timestamp.now(),
        });
      }
    } catch (error) {
      console.error('Error updating viewer count:', error);
    }
  }

  /**
   * Delete all chat messages for a stream
   */
  private async deleteStreamChat(streamId: string): Promise<void> {
    try {
      const q = query(this.chatCollection, where('streamId', '==', streamId));
      const querySnapshot = await getDocs(q);
      
      const deletePromises = querySnapshot.docs.map(doc => deleteDoc(doc.ref));
      await Promise.all(deletePromises);
    } catch (error) {
      console.error('Error deleting stream chat:', error);
    }
  }

  /**
   * Generate stream key
   */
  generateStreamKey(): string {
    return 'sk_' + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
  }

  /**
   * Validate stream key format
   */
  isValidStreamKey(streamKey: string): boolean {
    return /^sk_[a-z0-9]+$/.test(streamKey);
  }
}

export const liveStreamService = new LiveStreamService(); 