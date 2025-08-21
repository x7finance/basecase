'use client';

import { signIn } from '@basecase/auth/client';
import { GoogleLogoIcon } from '@phosphor-icons/react';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Loader } from '@/components/ui/loader';

type GoogleSignInButtonProps = {
  disabled?: boolean;
  onError?: (error: string) => void;
};

export function GoogleSignInButton({
  disabled,
  onError,
}: GoogleSignInButtonProps) {
  const [isLoading, setIsLoading] = useState(false);

  const handleGoogleSignIn = async () => {
    try {
      setIsLoading(true);
      await signIn.social({
        provider: 'google',
        callbackURL: '/',
      });
    } catch (_error) {
      // biome-ignore lint/suspicious/noConsole: I want to log the error here
      console.error(_error);
      onError?.('Failed to sign in with Google');
      setIsLoading(false);
    }
  };

  return (
    <Button
      className="h-9 w-full text-sm"
      disabled={disabled || isLoading}
      onClick={handleGoogleSignIn}
      variant="default"
    >
      {isLoading ? (
        <Loader size="sm" variant="primary" />
      ) : (
        <GoogleLogoIcon className="mr-2 h-4 w-4" weight="bold" />
      )}
      Continue with Google
    </Button>
  );
}
