'use client';

import { EnvelopeSimpleIcon } from '@phosphor-icons/react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

type EmailInputProps = {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
};

export function EmailInput({ value, onChange, disabled }: EmailInputProps) {
  return (
    <div className="space-y-1.5">
      <Label className="font-medium text-xs text-zinc-700" htmlFor="email">
        Email
      </Label>
      <div className="relative">
        <Input
          className="h-9 border-zinc-300 pl-9 text-sm focus:border-zinc-400"
          disabled={disabled}
          id="email"
          onChange={(e) => onChange(e.target.value)}
          placeholder="name@example.com"
          required
          type="email"
          value={value}
        />
        <EnvelopeSimpleIcon
          className="-translate-y-1/2 absolute top-1/2 left-2.5 h-4 w-4 text-zinc-400"
          weight="duotone"
        />
      </div>
    </div>
  );
}
