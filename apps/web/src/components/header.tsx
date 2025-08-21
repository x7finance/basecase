import Link from 'next/link';
import { Suspense } from 'react';
import HeaderAuth from './header-auth';
import { Loader } from './ui/loader';

export default function Header() {
  return (
    <nav className="sticky top-0 z-50 border-zinc-200 border-b bg-white">
      <div className="mx-auto flex max-w-[650px] items-center justify-between px-4 py-2">
        <Link
          className="font-medium text-sm text-zinc-900 hover:text-zinc-600"
          href="/"
        >
          Basecase.
        </Link>

        <div className="flex items-center gap-4 text-xs">
          <Link className="text-zinc-600 hover:text-zinc-900" href="/sports">
            Sports
          </Link>
          <Suspense fallback={<Loader size="sm" />}>
            <HeaderAuth />
          </Suspense>
        </div>
      </div>
    </nav>
  );
}
