'use client';

import { useInstantAuth, useSession } from '@basecase/auth';
import { db } from '@basecase/database';
import { Toaster } from './ui/sonner';

export default function Providers({ children }: { children: React.ReactNode }) {
  const { data: sessionData, isPending } = useSession();

  // Sync auth state between Better Auth and InstantDB
  // Note: This may show a "Record not found" error during sign-out - this is harmless
  useInstantAuth({
    db,
    sessionData,
    isPending,
  });

  return (
    <>
      {children}
      <Toaster richColors />
    </>
  );
}
