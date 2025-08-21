import { cn } from '@/lib/utils';

type LoaderProps = {
  size?: 'xs' | 'sm' | 'md' | 'lg';
  className?: string;
  variant?: 'primary' | 'secondary';
};

export function Loader({
  size = 'md',
  className,
  variant = 'primary',
}: LoaderProps) {
  const sizeClasses = {
    xs: 'h-3 w-3 border',
    sm: 'h-4 w-4 border',
    md: 'h-5 w-5 border-2',
    lg: 'h-6 w-6 border-2',
  };

  const variantClasses = {
    primary: 'border-zinc-300 border-t-zinc-600',
    secondary: 'border-white/30 border-t-white',
  };

  return (
    <div
      className={cn(
        'animate-spin rounded-full',
        sizeClasses[size],
        variantClasses[variant],
        className
      )}
    />
  );
}
