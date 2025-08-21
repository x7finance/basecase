'use client';

import { EmailInput } from '@/components/auth/email-input';
import { GoogleSignInButton } from '@/components/auth/google-signin-button';
import { PasswordInput } from '@/components/auth/password-input';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Loader } from '@/components/ui/loader';
import { Separator } from '@/components/ui/separator';
import { useAuthForm } from '@/hooks/use-auth-form';

export default function AuthPage() {
  const {
    isSignUp,
    email,
    password,
    name,
    isLoading,
    error,
    setEmail,
    setPassword,
    setName,
    setError,
    toggleMode,
    handleSubmit,
  } = useAuthForm();

  return (
    <div className="bg-white">
      <div className="pt-6 pb-12">
        <div className="mx-auto max-w-[450px] px-4">
          <Card variant="primary">
            <CardHeader className="space-y-2 pb-4 text-center">
              <CardTitle className="font-bold text-xl text-zinc-900 tracking-tight">
                {isSignUp ? 'Create an account' : 'Welcome back'}
              </CardTitle>
              <CardDescription className="text-xs text-zinc-600">
                {isSignUp ? 'Get started with Basecase' : 'Sign in to continue'}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              <GoogleSignInButton disabled={isLoading} onError={setError} />

              <div className="relative py-2">
                <div className="absolute inset-0 flex items-center">
                  <Separator className="bg-zinc-200" />
                </div>
                <div className="relative flex justify-center">
                  <span className="bg-white px-2 text-[10px] text-zinc-500 uppercase tracking-wider">
                    Or continue with email
                  </span>
                </div>
              </div>

              <form className="space-y-3" onSubmit={handleSubmit}>
                {error && (
                  <div className="rounded-md border border-red-200 bg-red-50 p-2.5 text-red-700 text-xs">
                    {error}
                  </div>
                )}

                {isSignUp && (
                  <div className="space-y-1.5">
                    <Label
                      className="font-medium text-xs text-zinc-700"
                      htmlFor="name"
                    >
                      Name
                    </Label>
                    <Input
                      className="h-9 border-zinc-300 text-sm focus:border-zinc-400"
                      disabled={isLoading}
                      id="name"
                      onChange={(e) => setName(e.target.value)}
                      placeholder="John Doe"
                      required={isSignUp}
                      type="text"
                      value={name}
                    />
                  </div>
                )}

                <EmailInput
                  disabled={isLoading}
                  onChange={setEmail}
                  value={email}
                />

                <PasswordInput
                  disabled={isLoading}
                  onChange={setPassword}
                  value={password}
                />

                <Button
                  className="h-9 w-full text-sm"
                  disabled={isLoading}
                  type="submit"
                  variant="primary"
                >
                  {isLoading ? (
                    <Loader size="sm" variant="secondary" />
                  ) : (
                    <>
                      {isSignUp ? 'Create account' : 'Sign in'}
                      <span className="ml-1">→</span>
                    </>
                  )}
                </Button>
              </form>

              <div className="pt-1 text-center text-xs">
                <span className="text-zinc-600">
                  {isSignUp
                    ? 'Already have an account?'
                    : "Don't have an account?"}
                </span>{' '}
                <button
                  className="font-medium text-zinc-900 underline underline-offset-2 transition-colors hover:text-zinc-700 focus:outline-none"
                  disabled={isLoading}
                  onClick={toggleMode}
                  type="button"
                >
                  {isSignUp ? 'Sign in' : 'Sign up'}
                </button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
