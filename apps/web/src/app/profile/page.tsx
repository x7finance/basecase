'use client';

import { signOut, useSession } from '@basecase/auth/client';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { toast } from 'sonner';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Loader } from '@/components/ui/loader';

const ACCOUNT_ID_LENGTH = 8;
const TIME_SLICE_LENGTH = 8;

export default function ProfilePage() {
  const router = useRouter();
  const { data: session, isPending } = useSession();
  const [isSigningOut, setIsSigningOut] = useState(false);

  useEffect(() => {
    if (!(isPending || session)) {
      router.push('/auth');
    }
  }, [session, isPending, router]);

  const handleSignOut = async () => {
    try {
      setIsSigningOut(true);
      await signOut({
        fetchOptions: {
          onSuccess: () => {
            router.push('/');
          },
        },
      });
    } catch (error) {
      // biome-ignore lint/suspicious/noConsole: I want to log the error here
      console.error(error);
      toast.error('Failed to sign out');
      setIsSigningOut(false);
    }
  };

  if (isPending) {
    return (
      <div className="bg-white">
        <div className="pt-6 pb-12">
          <div className="mx-auto max-w-[650px] px-4">
            <div className="flex justify-center py-8">
              <Loader size="md" />
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!session) {
    return null;
  }

  const user = session.user;
  const initials = user.name
    ? user.name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .toUpperCase()
    : user.email?.[0].toUpperCase() || 'U';

  return (
    <div className="bg-white">
      <div className="pt-6 pb-12">
        <div className="mx-auto max-w-[650px] px-4">
          {/* Profile Header */}
          <div className="mb-4">
            <h1 className="font-bold text-sm text-zinc-900">Profile</h1>
            <div className="mt-1 border-black border-b-2" />
          </div>

          {/* Account Section */}
          <div className="grid grid-cols-2 gap-6">
            {/* Left Column - Account Details */}
            <div>
              <h2 className="mb-3 font-bold text-xs text-zinc-900">Account</h2>

              {/* Avatar and Name */}
              <div className="mb-4 flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center border border-zinc-400 bg-zinc-100 font-mono text-xs text-zinc-900">
                  {user.image ? (
                    <Image
                      alt={user.name || 'User'}
                      className="h-full w-full object-cover"
                      height={48}
                      src={user.image}
                      width={48}
                    />
                  ) : (
                    initials
                  )}
                </div>
                <div>
                  <div className="font-mono text-xs text-zinc-900">
                    {user.name || 'User'}
                  </div>
                  <div className="font-mono text-xs text-zinc-500">
                    ACCOUNT MANAGEMENT SYSTEM
                  </div>
                </div>
              </div>

              {/* Profile Information Table */}
              <div className="border border-zinc-300">
                <div className="border-zinc-300 border-b bg-zinc-100 px-2 py-1">
                  <h3 className="font-bold text-xs">Profile Information</h3>
                </div>
                <table className="w-full text-xs">
                  <tbody>
                    <tr className="border-zinc-200 border-b">
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Account №
                      </td>
                      <td className="px-2 py-1 font-mono">
                        {user.id
                          ? `ACC${user.id.slice(0, ACCOUNT_ID_LENGTH).toUpperCase()}`
                          : 'N/A'}
                      </td>
                    </tr>
                    <tr className="border-zinc-200 border-b">
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Status
                      </td>
                      <td className="px-2 py-1">
                        <Badge size="sm" variant="success">
                          Active
                        </Badge>
                      </td>
                    </tr>
                    <tr className="border-zinc-200 border-b">
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Email
                      </td>
                      <td className="px-2 py-1 font-mono">{user.email}</td>
                    </tr>
                    <tr>
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Member since
                      </td>
                      <td className="px-2 py-1 font-mono">
                        {user.createdAt
                          ? new Date(user.createdAt).toLocaleDateString(
                              'en-US',
                              {
                                year: 'numeric',
                                month: 'short',
                              }
                            )
                          : 'N/A'}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              {/* Management Table */}
              <div className="mt-4 border border-zinc-300">
                <div className="border-zinc-300 border-b bg-zinc-100 px-2 py-1">
                  <h3 className="font-bold text-xs">Management</h3>
                </div>
                <table className="w-full text-xs">
                  <tbody>
                    <tr className="border-zinc-200 border-b">
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Login Method
                      </td>
                      <td className="px-2 py-1 font-mono">OAuth</td>
                    </tr>
                    <tr className="border-zinc-200 border-b">
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Last Login
                      </td>
                      <td className="px-2 py-1 font-mono">
                        {new Date().toISOString().split('T')[0]}{' '}
                        {new Date().toTimeString().slice(0, TIME_SLICE_LENGTH)}{' '}
                        UTC
                      </td>
                    </tr>
                    <tr className="border-zinc-200 border-b">
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Email Verified
                      </td>
                      <td className="px-2 py-1 font-mono">
                        {user.emailVerified ? 'Yes' : 'No'}
                      </td>
                    </tr>
                    <tr>
                      <td className="border-zinc-200 border-r px-2 py-1 font-medium">
                        Profile
                      </td>
                      <td className="px-2 py-1">
                        <Button
                          className="h-5 px-2 py-0 text-xs"
                          disabled={isSigningOut}
                          onClick={handleSignOut}
                          variant="secondary"
                        >
                          {isSigningOut ? <Loader size="xs" /> : 'SIGN OUT →'}
                        </Button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            {/* Right Column - Additional Info */}
            <div>
              <h2 className="mb-3 font-bold text-xs text-zinc-900">Activity</h2>

              <Card variant="secondary">
                <div className="px-2 py-2">
                  <h3 className="mb-2 font-bold text-xs">Recent Activity</h3>
                  <p className="font-mono text-xs text-zinc-500">
                    No recent activity.
                  </p>
                </div>
              </Card>

              <div className="mt-4">
                <Card variant="tertiary">
                  <div className="px-2 py-2">
                    <h3 className="mb-2 font-bold text-xs">Resources</h3>
                    <div className="space-y-1">
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-xs">Account Type</span>
                        <Badge size="sm" variant="success">
                          FREE
                        </Badge>
                      </div>
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-xs">Storage</span>
                        <span className="font-mono text-xs text-zinc-600">
                          100MB
                        </span>
                      </div>
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-xs">API Calls</span>
                        <span className="font-mono text-xs text-zinc-600">
                          1000/mo
                        </span>
                      </div>
                    </div>
                  </div>
                </Card>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
