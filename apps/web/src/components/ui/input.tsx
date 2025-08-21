import type { ComponentProps } from 'react';
import { cn } from '@/lib/utils';

function Input({ className, type, ...props }: ComponentProps<'input'>) {
  return (
    <input
      className={cn(
        'relative block h-7 w-full appearance-none rounded-none border border-black bg-white px-1 py-0.5 text-black text-sm outline-none',
        'shadow-[inset_2px_2px_#ddd] focus:shadow-[inset_2px_2px_#bbb]',
        'placeholder:text-zinc-500 disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50',
        className
      )}
      data-slot="input"
      type={type}
      {...props}
    />
  );
}

export { Input };
