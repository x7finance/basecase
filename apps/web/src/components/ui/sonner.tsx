'use client';

import { XIcon } from '@phosphor-icons/react';
import { Toaster as Sonner, type ToasterProps } from 'sonner';

const Toaster = ({ ...props }: ToasterProps) => {
  return (
    <Sonner
      closeButton
      expand={false}
      gap={-10}
      icons={{
        close: <XIcon className="h-4 w-4" />,
      }}
      position="top-center"
      richColors
      toastOptions={{
        duration: 4000,
        className: 'group',
        style: {
          border: '1px solid #000',
          borderRadius: '0',
          boxShadow: '3px 3px 0 #000',
          padding: '12px',
          fontSize: '13px',
          fontFamily: 'system-ui, -apple-system, sans-serif',
          background: '#fff',
          color: '#000',
        },
        classNames: {
          closeButton:
            'absolute top-2 right-2 left-auto transform-none ' +
            'border-0 bg-transparent text-zinc-600 hover:text-zinc-900 ' +
            'transition-colors cursor-pointer ' +
            'opacity-100 group-hover:opacity-100 ' +
            '!w-4 !h-4 !p-0',
          toast: 'relative pr-8',
          title: 'font-semibold text-zinc-900 text-sm',
          description: 'text-zinc-600 text-xs mt-1',
          error: 'bg-red-50 border-red-500 text-red-900',
          success: 'bg-emerald-50 border-emerald-500 text-emerald-900',
          warning: 'bg-yellow-50 border-yellow-500 text-yellow-900',
          info: 'bg-blue-50 border-blue-500 text-blue-900',
        },
      }}
      {...props}
    />
  );
};

export { Toaster };
