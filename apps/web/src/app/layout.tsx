import type { Metadata } from 'next';
import { IBM_Plex_Mono, Inter } from 'next/font/google';
import '../index.css';
import { GoogleAnalytics } from '@/components/google-analytics';
import Header from '@/components/header';
import Providers from '@/components/providers';

const inter = Inter({
  variable: '--font-inter',
  subsets: ['latin'],
  display: 'swap',
});

const ibmPlexMono = IBM_Plex_Mono({
  variable: '--font-ibm-plex-mono',
  weight: ['400', '500', '600'],
  subsets: ['latin'],
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'Basecase. | Software should just work.',
  description:
    'Simple tools that respect you. They load instantly. They work forever. They cost what they actually cost to make. This is software at its most honest.',
  keywords: ['software', 'tools', 'simple', 'honest', 'basecase'],
  authors: [{ name: 'Basecase' }],
  creator: 'Basecase',
  publisher: 'Basecase',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://basecase.space',
    siteName: 'Basecase.',
    title: 'Basecase. | Software should just work.',
    description:
      'Simple tools that respect you. They load instantly. They work forever. They cost what they actually cost to make.',
    images: [
      {
        url: 'https://basecase.space/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Basecase.',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Basecase. | Software should just work.',
    description:
      'Simple tools that respect you. They load instantly. They work forever.',
    creator: '@basecase',
    images: ['https://basecase.space/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${inter.variable} ${ibmPlexMono.variable} font-sans antialiased`}
      >
        <Providers>
          <Header />
          <main>{children}</main>
        </Providers>
        <GoogleAnalytics />
      </body>
    </html>
  );
}
