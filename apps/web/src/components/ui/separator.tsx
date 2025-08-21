/** biome-ignore-all lint/a11y/useAriaPropsSupportedByRole: unsure, leaving for now */
'use client';

import { forwardRef } from 'react';
import { cn } from '@/lib/utils';

interface SeparatorProps extends React.HTMLAttributes<HTMLDivElement> {
  orientation?: 'horizontal' | 'vertical';
  decorative?: boolean;
}

const Separator = forwardRef<HTMLDivElement, SeparatorProps>(
  (
    { className, orientation = 'horizontal', decorative = true, ...props },
    ref
  ) => (
    <div
      aria-orientation={orientation}
      className={cn(
        'shrink-0 bg-border',
        orientation === 'horizontal' ? 'h-[1px] w-full' : 'h-full w-[1px]',
        className
      )}
      ref={ref}
      role={decorative ? 'none' : 'separator'}
      {...props}
    />
  )
);
Separator.displayName = 'Separator';

export { Separator };
