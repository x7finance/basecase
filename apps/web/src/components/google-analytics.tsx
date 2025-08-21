import { env } from '@basecase/env';
import { GoogleAnalytics as NextGoogleAnalytics } from '@next/third-parties/google';

export function GoogleAnalytics() {
  const gaId = env.NEXT_PUBLIC_GA_MEASUREMENT_ID;

  if (!gaId) {
    // biome-ignore lint/suspicious/noConsole: we're in a server component
    console.warn(
      'Google Analytics: NEXT_PUBLIC_GA_MEASUREMENT_ID is not defined'
    );
    return null;
  }

  return <NextGoogleAnalytics gaId={gaId} />;
}
