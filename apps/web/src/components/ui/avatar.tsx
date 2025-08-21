'use client';

import Image from 'next/image';
import {
  forwardRef,
  type HTMLAttributes,
  type ImgHTMLAttributes,
  type ReactNode,
  useState,
} from 'react';
import { cn } from '@/lib/utils';

interface AvatarProps extends HTMLAttributes<HTMLDivElement> {
  children?: ReactNode;
}

const Avatar = forwardRef<HTMLDivElement, AvatarProps>(
  ({ className, children, ...props }, ref) => (
    <div
      className={cn(
        'relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full',
        className
      )}
      ref={ref}
      {...props}
    >
      {children}
    </div>
  )
);
Avatar.displayName = 'Avatar';

interface AvatarImageProps
  extends Omit<
    ImgHTMLAttributes<HTMLImageElement>,
    'height' | 'width' | 'src'
  > {
  src: string;
  height?: number;
  width?: number;
}

const DEFAULT_AVATAR_SIZE = 40;

const AvatarImage = forwardRef<HTMLImageElement, AvatarImageProps>(
  ({ className, alt, height, width, src, ...props }, ref) => {
    const [hasError, setHasError] = useState(false);

    if (hasError) {
      return null;
    }

    return (
      <Image
        alt={alt || ''}
        className={cn('aspect-square h-full w-full object-cover', className)}
        height={height || DEFAULT_AVATAR_SIZE}
        onError={() => setHasError(true)}
        ref={ref}
        src={src}
        tabIndex={-1}
        width={width || DEFAULT_AVATAR_SIZE}
        {...props}
      />
    );
  }
);
AvatarImage.displayName = 'AvatarImage';

interface AvatarFallbackProps extends HTMLAttributes<HTMLDivElement> {
  children?: ReactNode;
}

const AvatarFallback = forwardRef<HTMLDivElement, AvatarFallbackProps>(
  ({ className, children, ...props }, ref) => {
    return (
      <div
        className={cn(
          'flex h-full w-full items-center justify-center rounded-full bg-muted',
          className
        )}
        ref={ref}
        {...props}
      >
        {children}
      </div>
    );
  }
);
AvatarFallback.displayName = 'AvatarFallback';

export { Avatar, AvatarImage, AvatarFallback };
