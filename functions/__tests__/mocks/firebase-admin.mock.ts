/**
 * Firebase Admin SDK Mocks
 *
 * Provides mock implementations for Firestore, Auth, and Messaging services.
 */

import { EventEmitter } from 'events';

// Mock Firestore Document Snapshot
export class MockDocumentSnapshot {
  private _exists: boolean;
  private _data: any;
  private _id: string;
  ref: any;

  constructor(id: string, data: any, exists: boolean = true) {
    this._id = id;
    this._data = data;
    this._exists = exists;
    this.ref = {
      id: id,
      update: jest.fn().mockResolvedValue(undefined),
      delete: jest.fn().mockResolvedValue(undefined),
      set: jest.fn().mockResolvedValue(undefined),
    };
  }

  get exists(): boolean {
    return this._exists;
  }

  get id(): string {
    return this._id;
  }

  data(): any {
    return this._exists ? this._data : undefined;
  }
}

// Mock Firestore Query Snapshot
export class MockQuerySnapshot {
  private _docs: MockDocumentSnapshot[];

  constructor(docs: MockDocumentSnapshot[] = []) {
    this._docs = docs;
  }

  get empty(): boolean {
    return this._docs.length === 0;
  }

  get size(): number {
    return this._docs.length;
  }

  get docs(): MockDocumentSnapshot[] {
    return this._docs;
  }

  forEach(callback: (doc: MockDocumentSnapshot) => void): void {
    this._docs.forEach(callback);
  }
}

// Mock Firestore Collection Reference
export class MockCollectionReference {
  private _data: Map<string, any>;
  private _collectionPath: string;

  constructor(collectionPath: string, initialData: Map<string, any> = new Map()) {
    this._collectionPath = collectionPath;
    this._data = initialData;
  }

  doc(docId: string): MockDocumentReference {
    return new MockDocumentReference(docId, this._data.get(docId), this._data);
  }

  where(field: string, operator: string, value: any): MockQuery {
    return new MockQuery(this._data, field, operator, value);
  }

  add(data: any): Promise<MockDocumentReference> {
    const id = `mock_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this._data.set(id, data);
    return Promise.resolve(new MockDocumentReference(id, data, this._data));
  }

  async get(): Promise<MockQuerySnapshot> {
    const docs = Array.from(this._data.entries()).map(
      ([id, data]) => new MockDocumentSnapshot(id, data)
    );
    return new MockQuerySnapshot(docs);
  }
}

// Mock Firestore Document Reference
export class MockDocumentReference {
  private _id: string;
  private _data: any;
  private _collection: Map<string, any>;

  constructor(id: string, data: any, collection: Map<string, any> = new Map()) {
    this._id = id;
    this._data = data;
    this._collection = collection;
  }

  get id(): string {
    return this._id;
  }

  async get(): Promise<MockDocumentSnapshot> {
    return new MockDocumentSnapshot(this._id, this._data, this._data !== undefined);
  }

  async set(data: any, options?: any): Promise<void> {
    if (options?.merge) {
      this._data = { ...this._data, ...data };
    } else {
      this._data = data;
    }
    this._collection.set(this._id, this._data);
  }

  async update(data: any): Promise<void> {
    this._data = { ...this._data, ...data };
    this._collection.set(this._id, this._data);
  }

  async delete(): Promise<void> {
    this._collection.delete(this._id);
  }

  collection(subCollectionPath: string): MockCollectionReference {
    return new MockCollectionReference(`${this._id}/${subCollectionPath}`);
  }
}

// Mock Firestore Query
export class MockQuery {
  private _data: Map<string, any>;
  private _filters: Array<{ field: string; operator: string; value: any }> = [];
  private _limitCount: number | null = null;
  private _orderByField: string | null = null;

  constructor(data: Map<string, any>, field?: string, operator?: string, value?: any) {
    this._data = data;
    if (field && operator && value !== undefined) {
      this._filters.push({ field, operator, value });
    }
  }

  where(field: string, operator: string, value: any): MockQuery {
    this._filters.push({ field, operator, value });
    return this;
  }

  orderBy(field: string, direction?: string): MockQuery {
    this._orderByField = field;
    return this;
  }

  limit(count: number): MockQuery {
    this._limitCount = count;
    return this;
  }

  async get(): Promise<MockQuerySnapshot> {
    let results = Array.from(this._data.entries());

    // Apply filters
    for (const filter of this._filters) {
      results = results.filter(([id, data]) => {
        const fieldValue = data[filter.field];
        switch (filter.operator) {
          case '==':
            return fieldValue === filter.value;
          case '!=':
            return fieldValue !== filter.value;
          case '<':
            return fieldValue < filter.value;
          case '<=':
            return fieldValue <= filter.value;
          case '>':
            return fieldValue > filter.value;
          case '>=':
            return fieldValue >= filter.value;
          default:
            return true;
        }
      });
    }

    // Apply limit
    if (this._limitCount !== null) {
      results = results.slice(0, this._limitCount);
    }

    const docs = results.map(([id, data]) => new MockDocumentSnapshot(id, data));
    return new MockQuerySnapshot(docs);
  }
}

// Mock Firestore Batch
export class MockWriteBatch {
  private operations: Array<{ type: string; ref: any; data?: any }> = [];

  set(ref: any, data: any, options?: any): MockWriteBatch {
    this.operations.push({ type: 'set', ref, data });
    return this;
  }

  update(ref: any, data: any): MockWriteBatch {
    this.operations.push({ type: 'update', ref, data });
    return this;
  }

  delete(ref: any): MockWriteBatch {
    this.operations.push({ type: 'delete', ref });
    return this;
  }

  async commit(): Promise<void> {
    // Execute all operations
    for (const op of this.operations) {
      if (op.type === 'set' && op.ref.set) {
        await op.ref.set(op.data);
      } else if (op.type === 'update' && op.ref.update) {
        await op.ref.update(op.data);
      } else if (op.type === 'delete' && op.ref.delete) {
        await op.ref.delete();
      }
    }
  }
}

// Mock Firestore Timestamp
export class MockTimestamp {
  private _seconds: number;
  private _nanoseconds: number;

  constructor(seconds: number, nanoseconds: number = 0) {
    this._seconds = seconds;
    this._nanoseconds = nanoseconds;
  }

  get seconds(): number {
    return this._seconds;
  }

  get nanoseconds(): number {
    return this._nanoseconds;
  }

  toDate(): Date {
    return new Date(this._seconds * 1000 + this._nanoseconds / 1000000);
  }

  toMillis(): number {
    return this._seconds * 1000 + Math.floor(this._nanoseconds / 1000000);
  }

  static now(): MockTimestamp {
    const now = Date.now();
    return new MockTimestamp(Math.floor(now / 1000), (now % 1000) * 1000000);
  }

  static fromDate(date: Date): MockTimestamp {
    return new MockTimestamp(Math.floor(date.getTime() / 1000));
  }

  static fromMillis(milliseconds: number): MockTimestamp {
    return new MockTimestamp(Math.floor(milliseconds / 1000));
  }
}

// Mock Firestore FieldValue
export const MockFieldValue = {
  serverTimestamp: jest.fn(() => ({ _methodName: 'serverTimestamp' })),
  increment: jest.fn((n: number) => ({ _methodName: 'increment', value: n })),
  arrayUnion: jest.fn((...elements: any[]) => ({ _methodName: 'arrayUnion', elements })),
  arrayRemove: jest.fn((...elements: any[]) => ({ _methodName: 'arrayRemove', elements })),
  delete: jest.fn(() => ({ _methodName: 'delete' })),
};

// Mock Firestore instance
export class MockFirestore {
  private _collections: Map<string, Map<string, any>> = new Map();

  collection(collectionPath: string): MockCollectionReference {
    if (!this._collections.has(collectionPath)) {
      this._collections.set(collectionPath, new Map());
    }
    return new MockCollectionReference(collectionPath, this._collections.get(collectionPath));
  }

  batch(): MockWriteBatch {
    return new MockWriteBatch();
  }

  // Helper to set test data
  setTestData(collectionPath: string, data: Map<string, any>): void {
    this._collections.set(collectionPath, data);
  }

  // Helper to clear all data
  clearAllData(): void {
    this._collections.clear();
  }
}

// Mock Firebase Messaging
export const createMockMessaging = () => ({
  send: jest.fn().mockResolvedValue('mock-message-id'),
  sendMulticast: jest.fn().mockResolvedValue({ successCount: 1, failureCount: 0 }),
  sendAll: jest.fn().mockResolvedValue({ successCount: 1, failureCount: 0 }),
  subscribeToTopic: jest.fn().mockResolvedValue({}),
  unsubscribeFromTopic: jest.fn().mockResolvedValue({}),
});

// Mock Firebase Auth
export const createMockAuth = () => ({
  verifyIdToken: jest.fn().mockResolvedValue({ uid: 'test-user-id' }),
  getUser: jest.fn().mockResolvedValue({ uid: 'test-user-id', email: 'test@example.com' }),
  createUser: jest.fn().mockResolvedValue({ uid: 'new-user-id' }),
  updateUser: jest.fn().mockResolvedValue({}),
  deleteUser: jest.fn().mockResolvedValue({}),
  createCustomToken: jest.fn().mockResolvedValue('mock-custom-token'),
});

// Create a mock admin instance
export const createMockAdmin = () => {
  const mockFirestore = new MockFirestore();
  const mockMessaging = createMockMessaging();
  const mockAuth = createMockAuth();

  return {
    initializeApp: jest.fn(),
    app: jest.fn(() => ({
      name: '[DEFAULT]',
      options: { projectId: 'test-project' },
    })),
    firestore: jest.fn(() => mockFirestore),
    messaging: jest.fn(() => mockMessaging),
    auth: jest.fn(() => mockAuth),
    credential: {
      cert: jest.fn(),
      applicationDefault: jest.fn(),
    },
    _mockFirestore: mockFirestore,
    _mockMessaging: mockMessaging,
    _mockAuth: mockAuth,
  };
};

// Export singleton instance
export const mockAdmin = createMockAdmin();

// Helper function to create a mock Firestore Timestamp
export const createMockTimestamp = (date: Date = new Date()): MockTimestamp => {
  return MockTimestamp.fromDate(date);
};
