import { cva, type VariantProps } from 'class-variance-authority';
import { forwardRef } from 'react';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'relative inline-flex cursor-pointer select-none appearance-none items-center justify-center gap-1 whitespace-nowrap rounded-none text-center no-underline outline-none transition-all disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default:
          'border border-black bg-white text-black shadow-[2px_2px_#bbb] hover:shadow-[1px_1px_#bbb] active:translate-x-[1px] active:translate-y-[1px] active:shadow-none',
        primary:
          'border border-emerald-900 bg-emerald-700 text-white shadow-[2px_2px_#064e3b] hover:bg-emerald-600 hover:shadow-[1px_1px_#064e3b] active:translate-x-[1px] active:translate-y-[1px] active:shadow-none',
        destructive:
          'border border-red-900 bg-red-50 text-red-900 shadow-[2px_2px_#ffbbb] hover:shadow-[1px_1px_#ffbbb] active:translate-x-[1px] active:translate-y-[1px] active:shadow-none',
        outline:
          'border border-black bg-white text-black shadow-[2px_2px_#bbb] hover:shadow-[1px_1px_#bbb] active:translate-x-[1px] active:translate-y-[1px] active:shadow-none',
        secondary:
          'border border-black bg-zinc-100 text-black shadow-[2px_2px_#bbb] hover:shadow-[1px_1px_#bbb] active:translate-x-[1px] active:translate-y-[1px] active:shadow-none',
        ghost:
          'border-0 bg-transparent text-black shadow-none hover:bg-zinc-100',
        link: 'border-0 bg-transparent text-black underline-offset-4 shadow-none hover:underline',
      },
      size: {
        default: 'h-8 px-3 text-sm',
        sm: 'h-7 px-2 text-xs',
        lg: 'h-10 px-4 text-base',
        icon: 'size-8',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  /**
   * The HTML type attribute for the button
   */
  type?: 'button' | 'submit' | 'reset';
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, children, type = 'button', ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        data-slot="button"
        ref={ref}
        type={type}
        {...props}
      >
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';

export { Button, buttonVariants };
