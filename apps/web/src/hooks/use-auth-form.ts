'use client';

import { signIn, signUp } from '@basecase/auth/client';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

export function useAuthForm() {
  const router = useRouter();
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const resetForm = () => {
    setEmail('');
    setPassword('');
    setName('');
    setError('');
  };

  const toggleMode = () => {
    setIsSignUp(!isSignUp);
    resetForm();
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      const result = isSignUp
        ? await signUp.email({ email, password, name })
        : await signIn.email({ email, password });

      if (result.error) {
        throw new Error(result.error.message);
      }

      router.push('/');
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Failed to sign in';
      setError(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return {
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
  };
}
