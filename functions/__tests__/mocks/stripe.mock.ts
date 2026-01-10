/**
 * Stripe SDK Mocks
 *
 * Provides mock implementations for Stripe API calls.
 */

export interface MockStripeCustomer {
  id: string;
  email: string;
  metadata: Record<string, string>;
  created: number;
}

export interface MockStripeCheckoutSession {
  id: string;
  url: string;
  customer: string;
  mode: 'payment' | 'subscription';
  payment_status: 'paid' | 'unpaid' | 'no_payment_required';
  metadata: Record<string, string>;
  line_items?: {
    data: Array<{
      price: { id: string };
      quantity: number;
    }>;
  };
}

export interface MockStripePaymentIntent {
  id: string;
  amount: number;
  currency: string;
  status: 'succeeded' | 'pending' | 'failed' | 'canceled';
  customer: string;
  metadata: Record<string, string>;
  last_payment_error?: {
    message: string;
    code: string;
  };
}

// Default mock responses
const defaultCheckoutSession: MockStripeCheckoutSession = {
  id: 'cs_test_mock_session',
  url: 'https://checkout.stripe.com/test_session',
  customer: 'cus_test_mock',
  mode: 'payment',
  payment_status: 'paid',
  metadata: {},
};

const defaultCustomer: MockStripeCustomer = {
  id: 'cus_test_mock',
  email: 'test@example.com',
  metadata: {},
  created: Date.now(),
};

const defaultPaymentIntent: MockStripePaymentIntent = {
  id: 'pi_test_mock',
  amount: 1499,
  currency: 'usd',
  status: 'succeeded',
  customer: 'cus_test_mock',
  metadata: {},
};

// Mock Stripe class
export class MockStripe {
  private _webhookSecret: string = 'whsec_test_mock';

  // Track calls for assertions
  public callHistory: {
    customersCreate: any[];
    checkoutSessionsCreate: any[];
    paymentIntentsCreate: any[];
    webhookConstructEvent: any[];
  } = {
    customersCreate: [],
    checkoutSessionsCreate: [],
    paymentIntentsCreate: [],
    webhookConstructEvent: [],
  };

  // Configurable responses
  public mockResponses: {
    checkoutSession: MockStripeCheckoutSession;
    customer: MockStripeCustomer;
    paymentIntent: MockStripePaymentIntent;
  } = {
    checkoutSession: { ...defaultCheckoutSession },
    customer: { ...defaultCustomer },
    paymentIntent: { ...defaultPaymentIntent },
  };

  // Reset mocks
  reset(): void {
    this.callHistory = {
      customersCreate: [],
      checkoutSessionsCreate: [],
      paymentIntentsCreate: [],
      webhookConstructEvent: [],
    };
    this.mockResponses = {
      checkoutSession: { ...defaultCheckoutSession },
      customer: { ...defaultCustomer },
      paymentIntent: { ...defaultPaymentIntent },
    };
  }

  // Customers API
  customers = {
    create: jest.fn(async (params: any) => {
      this.callHistory.customersCreate.push(params);
      return {
        ...this.mockResponses.customer,
        email: params.email || this.mockResponses.customer.email,
        metadata: params.metadata || {},
      };
    }),
    retrieve: jest.fn(async (customerId: string) => {
      return { ...this.mockResponses.customer, id: customerId };
    }),
    update: jest.fn(async (customerId: string, params: any) => {
      return { ...this.mockResponses.customer, id: customerId, ...params };
    }),
    list: jest.fn(async (params?: any) => {
      return { data: [this.mockResponses.customer], has_more: false };
    }),
  };

  // Checkout Sessions API
  checkout = {
    sessions: {
      create: jest.fn(async (params: any) => {
        this.callHistory.checkoutSessionsCreate.push(params);
        return {
          ...this.mockResponses.checkoutSession,
          customer: params.customer || this.mockResponses.checkoutSession.customer,
          mode: params.mode || 'payment',
          metadata: params.metadata || {},
        };
      }),
      retrieve: jest.fn(async (sessionId: string) => {
        return { ...this.mockResponses.checkoutSession, id: sessionId };
      }),
      listLineItems: jest.fn(async (sessionId: string) => {
        return {
          data: [{ price: { id: 'price_test' }, quantity: 1 }],
          has_more: false,
        };
      }),
    },
  };

  // Payment Intents API
  paymentIntents = {
    create: jest.fn(async (params: any) => {
      this.callHistory.paymentIntentsCreate.push(params);
      return {
        ...this.mockResponses.paymentIntent,
        amount: params.amount || this.mockResponses.paymentIntent.amount,
        currency: params.currency || 'usd',
        metadata: params.metadata || {},
      };
    }),
    retrieve: jest.fn(async (intentId: string) => {
      return { ...this.mockResponses.paymentIntent, id: intentId };
    }),
    confirm: jest.fn(async (intentId: string) => {
      return { ...this.mockResponses.paymentIntent, id: intentId, status: 'succeeded' };
    }),
    cancel: jest.fn(async (intentId: string) => {
      return { ...this.mockResponses.paymentIntent, id: intentId, status: 'canceled' };
    }),
  };

  // Refunds API
  refunds = {
    create: jest.fn(async (params: any) => {
      return {
        id: 're_test_mock',
        amount: params.amount,
        payment_intent: params.payment_intent,
        status: 'succeeded',
      };
    }),
  };

  // Billing Portal API
  billingPortal = {
    sessions: {
      create: jest.fn(async (params: any) => {
        return {
          id: 'bps_test_mock',
          url: 'https://billing.stripe.com/test_session',
          customer: params.customer,
        };
      }),
    },
  };

  // Webhooks
  webhooks = {
    constructEvent: jest.fn((payload: string | Buffer, signature: string, secret: string) => {
      this.callHistory.webhookConstructEvent.push({ payload, signature, secret });

      // Parse the payload to return a mock event
      let eventData: any;
      try {
        eventData = typeof payload === 'string' ? JSON.parse(payload) : JSON.parse(payload.toString());
      } catch {
        eventData = {
          type: 'checkout.session.completed',
          data: { object: this.mockResponses.checkoutSession },
        };
      }

      return {
        id: 'evt_test_mock',
        type: eventData.type || 'checkout.session.completed',
        data: eventData.data || { object: this.mockResponses.checkoutSession },
      };
    }),
  };

  // Subscriptions API (for potential future use)
  subscriptions = {
    create: jest.fn(async (params: any) => {
      return {
        id: 'sub_test_mock',
        customer: params.customer,
        status: 'active',
        items: { data: [{ price: { id: params.items[0]?.price } }] },
      };
    }),
    retrieve: jest.fn(async (subscriptionId: string) => {
      return {
        id: subscriptionId,
        status: 'active',
        customer: 'cus_test_mock',
      };
    }),
    update: jest.fn(async (subscriptionId: string, params: any) => {
      return {
        id: subscriptionId,
        status: 'active',
        ...params,
      };
    }),
    cancel: jest.fn(async (subscriptionId: string) => {
      return {
        id: subscriptionId,
        status: 'canceled',
      };
    }),
  };
}

// Export singleton instance
export const mockStripe = new MockStripe();

// Helper to create a mock webhook event
export const createMockWebhookEvent = (
  type: string,
  data: any
): { type: string; data: { object: any }; id: string } => {
  return {
    id: `evt_test_${Date.now()}`,
    type,
    data: { object: data },
  };
};

// Helper to create mock checkout session completed event
export const createCheckoutCompletedEvent = (metadata: Record<string, string> = {}) => {
  return createMockWebhookEvent('checkout.session.completed', {
    id: 'cs_test_mock',
    payment_status: 'paid',
    metadata,
  });
};

// Helper to create mock payment intent failed event
export const createPaymentFailedEvent = (errorMessage: string = 'Card declined') => {
  return createMockWebhookEvent('payment_intent.payment_failed', {
    id: 'pi_test_mock',
    status: 'failed',
    last_payment_error: { message: errorMessage },
    metadata: {},
  });
};
