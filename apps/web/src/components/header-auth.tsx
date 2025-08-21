'use client';

import { useSession } from '@basecase/auth/client';
import Link from 'next/link';
import { Loader } from '@/components/ui/loader';

export default function HeaderAuth() {
  const { data: session, isPending } = useSession();

  if (isPending) {
    return <Loader size="sm" />;
  }

  if (session) {
    return (
      <Link className="text-zinc-600 hover:text-zinc-900" href="/profile">
        Profile
      </Link>
    );
  }

  return (
    <Link className="text-zinc-600 hover:text-zinc-900" href="/auth">
      Sign in
    </Link>
  );
}
