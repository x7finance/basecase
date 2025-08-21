'use client';

import { useSession } from '@basecase/auth/client';
import Link from 'next/link';
import { useEffect, useState } from 'react';

export default function Home() {
  const { data: session } = useSession();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <div className="bg-white">
      {/* Main Content */}
      <main className="pt-6 pb-12">
        <article className="mx-auto max-w-[650px] px-4">
          {/* Opening Statement */}
          <section
            className={`space-y-4 transition-all duration-700 ${mounted ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'}`}
          >
            <h1 className="font-bold text-xl text-zinc-900 leading-tight">
              Software should just work.
            </h1>

            <p className="text-sm text-zinc-700 leading-relaxed">
              Not bloated. Not expensive. Not complicated.
            </p>

            <p className="text-xs text-zinc-600 leading-relaxed">
              We make the tools you reach for every day. A timer. A notepad. A
              calculator. The things that should have been perfect decades ago,
              but somehow got worse.
            </p>

            <p className="text-xs text-zinc-600 leading-relaxed">
              Every piece of software we make does one thing beautifully. We
              sell it at{' '}
              <span className="font-medium font-mono">cost plus 15%</span>{' '}
              because that's all we need. When software isn't chasing profits,
              it can chase perfection instead.
            </p>

            <p className="text-xs text-zinc-600 leading-relaxed">
              No subscriptions. No ads. No features you didn't ask for.
              <br />
              Just tools that work, priced like they should be.
            </p>

            <p className="font-medium font-mono text-xs text-zinc-700">
              This is software at its most honest.
            </p>
            <p className="font-bold font-mono text-sm text-zinc-900 leading-relaxed">
              Basecase.
            </p>
          </section>

          {/* Divider */}
          <hr className="my-8 border-zinc-200" />

          {/* Vision Section */}
          <section
            className={`space-y-3 transition-all delay-200 duration-700 ${mounted ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'}`}
          >
            <p className="text-xs text-zinc-600 italic leading-relaxed">
              That's the vision. Simple tools that respect you. They load
              instantly. They work forever. They cost what they actually cost to
              make. We believe when you remove the greed from software, what's
              left is something pure. Something worth making.
            </p>
          </section>

          {/* Call to Action */}
          <section
            className={`mt-12 transition-all delay-300 duration-700 ${mounted ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'}`}
          >
            <div className="flex flex-col gap-3 sm:flex-row">
              <Link
                className="inline-flex items-center justify-center border border-black bg-white px-3 py-1.5 text-black text-xs shadow-[2px_2px_#bbb] transition-all hover:shadow-[1px_1px_#bbb] active:translate-x-[1px] active:translate-y-[1px] active:shadow-none"
                href="/sports"
              >
                See an example
              </Link>
              <Link
                className="inline-flex items-center justify-center gap-1 border border-emerald-900 bg-emerald-700 px-3 py-1.5 text-white text-xs shadow-[2px_2px_#064e3b] transition-all hover:bg-emerald-600 hover:shadow-[1px_1px_#064e3b] active:translate-x-[1px] active:translate-y-[1px] active:shadow-none"
                href={session ? '/profile' : '/auth'}
              >
                Start building
                <span>→</span>
              </Link>
            </div>
          </section>

          {/* Footer */}
          <footer
            className={`mt-16 border-zinc-200 border-t pt-6 transition-all delay-400 duration-700 ${mounted ? 'opacity-100' : 'opacity-0'}`}
          >
            <p className="font-mono text-xs text-zinc-500">Basecase.</p>
          </footer>
        </article>
      </main>
    </div>
  );
}
