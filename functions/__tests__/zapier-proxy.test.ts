/**
 * Tests for triggerZapierWorkflow Cloud Function
 */

import { createMockCallableContext } from './mocks';

// Mock axios before importing the module under test
jest.mock('axios', () => ({
  default: {
    post: jest.fn(),
  },
  post: jest.fn(),
}));

import axios from 'axios';

// We need to import the function after mocks are set up.
// The setup.ts file already mocks firebase-functions, so onCall returns
// the handler directly.
let triggerZapierWorkflow: any;

beforeAll(() => {
  // Set the environment variable before importing
  process.env.ZAPIER_MCP_URL = 'https://zapier.test/webhook';
});

describe('triggerZapierWorkflow', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    process.env.ZAPIER_MCP_URL = 'https://zapier.test/webhook';
    // Re-import to pick up env changes
    jest.isolateModules(() => {
      const mod = require('../src/zapier-proxy');
      triggerZapierWorkflow = mod.triggerZapierWorkflow;
    });
  });

  // ============================================================================
  // Authentication
  // ============================================================================
  describe('authentication', () => {
    test('rejects unauthenticated calls', async () => {
      const context = createMockCallableContext({ auth: null });

      await expect(
        triggerZapierWorkflow(
          { zapName: 'test', payload: { key: 'value' } },
          context
        )
      ).rejects.toThrow(/Must be logged in/);
    });

    test('accepts authenticated calls', async () => {
      (axios.post as jest.Mock).mockResolvedValue({
        status: 200,
        data: { success: true },
      });

      const context = createMockCallableContext();

      const result = await triggerZapierWorkflow(
        { zapName: 'test-zap', payload: { key: 'value' } },
        context
      );

      expect(result).toEqual({ success: true, statusCode: 200 });
    });
  });

  // ============================================================================
  // Input validation
  // ============================================================================
  describe('input validation', () => {
    test('rejects missing zapName', async () => {
      const context = createMockCallableContext();

      await expect(
        triggerZapierWorkflow({ payload: { key: 'value' } }, context)
      ).rejects.toThrow(/zapName/);
    });

    test('rejects non-string zapName', async () => {
      const context = createMockCallableContext();

      await expect(
        triggerZapierWorkflow(
          { zapName: 123, payload: { key: 'value' } },
          context
        )
      ).rejects.toThrow(/zapName/);
    });

    test('rejects missing payload', async () => {
      const context = createMockCallableContext();

      await expect(
        triggerZapierWorkflow({ zapName: 'test' }, context)
      ).rejects.toThrow(/payload/);
    });

    test('rejects non-object payload', async () => {
      const context = createMockCallableContext();

      await expect(
        triggerZapierWorkflow(
          { zapName: 'test', payload: 'not-an-object' },
          context
        )
      ).rejects.toThrow(/payload/);
    });
  });

  // ============================================================================
  // Environment variable
  // ============================================================================
  describe('environment variable', () => {
    test('throws when ZAPIER_MCP_URL is not set', async () => {
      delete process.env.ZAPIER_MCP_URL;

      // Re-import to pick up env changes
      let fn: any;
      jest.isolateModules(() => {
        const mod = require('../src/zapier-proxy');
        fn = mod.triggerZapierWorkflow;
      });

      const context = createMockCallableContext();

      await expect(
        fn({ zapName: 'test', payload: { key: 'value' } }, context)
      ).rejects.toThrow(/not configured/);
    });
  });

  // ============================================================================
  // Zapier forwarding
  // ============================================================================
  describe('Zapier forwarding', () => {
    test('forwards payload to Zapier URL', async () => {
      (axios.post as jest.Mock).mockResolvedValue({
        status: 200,
        data: {},
      });

      const context = createMockCallableContext();
      const payload = { venue_name: 'Test Bar', location: 'NYC' };

      await triggerZapierWorkflow(
        { zapName: 'venue-signup', payload },
        context
      );

      expect(axios.post).toHaveBeenCalledWith(
        'https://zapier.test/webhook',
        expect.objectContaining({
          zap_name: 'venue-signup',
          payload: expect.objectContaining({
            venue_name: 'Test Bar',
            location: 'NYC',
            triggered_by: 'test-user-id',
          }),
        }),
        expect.objectContaining({
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
          timeout: 15000,
        })
      );
    });

    test('includes caller uid in forwarded payload', async () => {
      (axios.post as jest.Mock).mockResolvedValue({
        status: 200,
        data: {},
      });

      const context = createMockCallableContext({
        auth: { uid: 'custom-uid', token: { email: 'a@b.com' } },
      });

      await triggerZapierWorkflow(
        { zapName: 'test', payload: { foo: 'bar' } },
        context
      );

      const callArgs = (axios.post as jest.Mock).mock.calls[0];
      expect(callArgs[1].payload.triggered_by).toBe('custom-uid');
    });

    test('returns success: true for 200 response', async () => {
      (axios.post as jest.Mock).mockResolvedValue({ status: 200 });

      const context = createMockCallableContext();
      const result = await triggerZapierWorkflow(
        { zapName: 'test', payload: {} },
        context
      );

      expect(result).toEqual({ success: true, statusCode: 200 });
    });

    test('returns success: true for 201 response', async () => {
      (axios.post as jest.Mock).mockResolvedValue({ status: 201 });

      const context = createMockCallableContext();
      const result = await triggerZapierWorkflow(
        { zapName: 'test', payload: {} },
        context
      );

      expect(result).toEqual({ success: true, statusCode: 201 });
    });

    test('returns success: false for non-2xx response', async () => {
      (axios.post as jest.Mock).mockResolvedValue({ status: 400 });

      const context = createMockCallableContext();
      const result = await triggerZapierWorkflow(
        { zapName: 'test', payload: {} },
        context
      );

      expect(result).toEqual({ success: false, statusCode: 400 });
    });

    test('throws internal error when axios fails', async () => {
      (axios.post as jest.Mock).mockRejectedValue(
        new Error('Network error')
      );

      const context = createMockCallableContext();

      await expect(
        triggerZapierWorkflow(
          { zapName: 'test', payload: {} },
          context
        )
      ).rejects.toThrow(/Failed to trigger workflow/);
    });
  });
});
