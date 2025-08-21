'use client';

import { signOut, useSession } from '@basecase/auth';
import {
  CircleNotchIcon,
  SignInIcon,
  SignOutIcon,
} from '@phosphor-icons/react';
import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

export function AuthButton() {
  const { data, isPending } = useSession();
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  const handleSignOut = async () => {
    setIsLoading(true);
    try {
      await signOut();
      router.push('/');
    } catch (error) {
      // biome-ignore lint/suspicious/noConsole: we're in a client component
      console.error('Sign out error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isPending || isLoading) {
    return (
      <Button disabled size="sm" variant="ghost">
        <CircleNotchIcon className="h-4 w-4 animate-spin" />
      </Button>
    );
  }

  if (data?.user) {
    return (
      <DropdownMenu>
        <DropdownMenuTrigger
          render={(props) => (
            <Button {...props} size="sm" variant="ghost">
              {data.user.email || 'User'}
            </Button>
          )}
        />
        <DropdownMenuContent align="end">
          <DropdownMenuItem onClick={handleSignOut}>
            <SignOutIcon className="mr-2 h-4 w-4" />
            Sign Out
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    );
  }

  return (
    <Button onClick={() => router.push('/auth')} size="sm" variant="ghost">
      <SignInIcon className="mr-2 h-4 w-4" />
      Sign In
    </Button>
  );
}
