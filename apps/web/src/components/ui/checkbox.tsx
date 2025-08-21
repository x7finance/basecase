'use client';

import { Checkbox as CheckboxPrimitive } from '@base-ui-components/react/checkbox';
import { CheckIcon, MinusIcon } from '@phosphor-icons/react';
import type { ComponentProps } from 'react';
import { cn } from '@/lib/utils';

function Checkbox({
  parent = false,
  className,
  ...props
}: ComponentProps<typeof CheckboxPrimitive.Root>) {
  return (
    <CheckboxPrimitive.Root
      className={cn(
        'peer size-4 shrink-0 cursor-pointer rounded-sm border border-primary shadow outline-none duration-150 ease-out focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 data-[checked]:border-primary data-[checked]:bg-primary data-[indeterminate]:bg-border data-[checked]:text-primary-foreground data-[indeterminate]:text-primary dark:border-primary/50',
        parent && '-ml-4',
        className
      )}
      data-parent={parent}
      data-slot="checkbox"
      parent={parent}
      {...props}
    >
      <CheckboxPrimitive.Indicator
        className={cn(
          'flex h-full items-center justify-center text-current duration-150 ease-out data-[unchecked]:hidden data-[ending-style]:scale-60 data-[starting-style]:scale-60'
        )}
        data-slot="checkbox-indicator"
        render={(indicatorProps, state) => (
          <span {...indicatorProps}>
            {state.indeterminate ? (
              <MinusIcon className="size-4" />
            ) : (
              <CheckIcon className="size-4" />
            )}
          </span>
        )}
      />
    </CheckboxPrimitive.Root>
  );
}

export { Checkbox };
