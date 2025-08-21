/** biome-ignore-all lint/a11y/noLabelWithoutControl: we're in the label file dummy */
import type { ComponentProps } from 'react';
import { cn } from '@/lib/utils';

function Label({ className, ...props }: ComponentProps<'label'>) {
  return (
    <label
      className={cn(
        'font-medium text-sm leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70',
        className
      )}
      {...props}
    />
  );
}

export { Label };
