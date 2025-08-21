// Export all templates

// Export all services
export * from './services';
export * from './templates';

// Export all types
export * from './types';

import { getBetterAuthEmailConfig } from './services/better-auth';
// Re-export specific items for convenience
import { createEmailService } from './services/resend';

export {
  createBetterAuthEmailHandlers,
  getBetterAuthEmailConfig,
} from './services/better-auth';
export { createEmailService, EmailService } from './services/resend';

// Export a default configuration helper
export function createEmailConfig(options: {
  resendApiKey: string;
  from?: string;
  appName?: string;
  baseUrl?: string;
}) {
  return {
    service: createEmailService({
      apiKey: options.resendApiKey,
      from: options.from,
      appName: options.appName,
      baseUrl: options.baseUrl,
    }),
    betterAuth: getBetterAuthEmailConfig({
      resendApiKey: options.resendApiKey,
      from: options.from,
      appName: options.appName,
      baseUrl: options.baseUrl,
    }),
  };
}
