'use client';

import { EyeIcon, EyeSlashIcon } from '@phosphor-icons/react';
import { useState } from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

type PasswordInputProps = {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
};

export function PasswordInput({
  value,
  onChange,
  disabled,
}: PasswordInputProps) {
  const [showPassword, setShowPassword] = useState(false);

  return (
    <div className="space-y-1.5">
      <Label className="font-medium text-xs text-zinc-700" htmlFor="password">
        Password
      </Label>
      <div className="relative">
        <Input
          className="h-9 border-zinc-300 pr-9 text-sm focus:border-zinc-400"
          disabled={disabled}
          id="password"
          onChange={(e) => onChange(e.target.value)}
          placeholder="••••••••"
          required
          type={showPassword ? 'text' : 'password'}
          value={value}
        />
        <button
          className="-translate-y-1/2 absolute top-1/2 right-2.5 text-zinc-400 transition-colors hover:text-zinc-600"
          onClick={() => setShowPassword(!showPassword)}
          tabIndex={-1}
          type="button"
        >
          {showPassword ? (
            <EyeSlashIcon className="h-4 w-4" weight="duotone" />
          ) : (
            <EyeIcon className="h-4 w-4" weight="duotone" />
          )}
        </button>
      </div>
    </div>
  );
}
