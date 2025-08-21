import { cva, type VariantProps } from 'class-variance-authority';

import { cn } from '@/lib/utils';

const cardVariants = cva('bg-white', {
  variants: {
    variant: {
      primary: 'border-black border-b-2',
      secondary: 'border-black border-b border-dashed',
      tertiary: 'max-w-[325px] border-zinc-400 border-b border-dashed',
    },
  },
  defaultVariants: {
    variant: 'primary',
  },
});

interface CardProps
  extends React.ComponentProps<'div'>,
    VariantProps<typeof cardVariants> {}

function Card({ className, variant, ...props }: CardProps) {
  return (
    <div
      className={cn(cardVariants({ variant }), className)}
      data-slot="card"
      {...props}
    />
  );
}

function CardHeader({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div className={cn('pb-2', className)} data-slot="card-header" {...props} />
  );
}

function CardTitle({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div
      className={cn('font-semibold text-zinc-900', className)}
      data-slot="card-title"
      {...props}
    />
  );
}

function CardDescription({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div
      className={cn('text-sm text-zinc-600', className)}
      data-slot="card-description"
      {...props}
    />
  );
}

function CardAction({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div className={cn('', className)} data-slot="card-action" {...props} />
  );
}

function CardContent({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div
      className={cn('py-3', className)}
      data-slot="card-content"
      {...props}
    />
  );
}

function CardFooter({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div
      className={cn('flex items-center pt-3', className)}
      data-slot="card-footer"
      {...props}
    />
  );
}

export {
  Card,
  CardHeader,
  CardFooter,
  CardTitle,
  CardAction,
  CardDescription,
  CardContent,
};
