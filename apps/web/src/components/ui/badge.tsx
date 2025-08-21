import { cva, type VariantProps } from 'class-variance-authority';
import type { ComponentProps } from 'react';
import { cn } from '@/lib/utils';

const badgeVariants = cva(
  'inline-flex items-center border border-black font-bold font-mono text-xs uppercase tracking-wider',
  {
    variants: {
      variant: {
        default: 'bg-white text-black',
        success: 'border-emerald-900 bg-emerald-700 text-white',
        warning: 'border-amber-700 bg-amber-500 text-black',
        error: 'border-red-800 bg-red-600 text-white',
        info: 'border-blue-800 bg-blue-600 text-white',
        muted: 'border-zinc-300 bg-zinc-100 text-zinc-600',
      },
      size: {
        sm: 'px-1 py-0 text-[10px]',
        md: 'px-1.5 py-0.5 text-xs',
        lg: 'px-2 py-1 text-xs',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'md',
    },
  }
);

interface BadgeProps
  extends ComponentProps<'span'>,
    VariantProps<typeof badgeVariants> {}

export function Badge({ className, variant, size, ...props }: BadgeProps) {
  return (
    <span
      className={cn(badgeVariants({ variant, size }), className)}
      {...props}
    />
  );
}
