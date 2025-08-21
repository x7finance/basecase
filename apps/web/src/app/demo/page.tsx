/** biome-ignore-all lint/style/noMagicNumbers: because */
'use client';

import { useState } from 'react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

export default function DemoPage() {
  const [message, setMessage] = useState('');

  const triggerToast = (
    type: 'success' | 'error' | 'info' | 'warning' | 'default'
  ) => {
    const messages = {
      success: 'Operation completed successfully!',
      error: 'Something went wrong. Please try again.',
      info: "Here's some useful information for you.",
      warning: 'Please proceed with caution.',
      default: 'This is a default toast message.',
    };

    /** biome-ignore lint/nursery/noUnnecessaryConditions: type is a required parameter */
    switch (type) {
      case 'success':
        toast.success(messages.success);
        break;
      case 'error':
        toast.error(messages.error);
        break;
      case 'info':
        toast.info(messages.info);
        break;
      case 'warning':
        toast.warning(messages.warning);
        break;
      default:
        toast(messages.default);
    }
  };

  const triggerWithDescription = () => {
    toast.success('File uploaded', {
      description: 'Your file has been successfully uploaded to the server.',
    });
  };

  const triggerWithAction = () => {
    toast('Event has been created', {
      action: {
        label: 'Undo',
        onClick: () => {
          // biome-ignore lint/suspicious/noConsole: because
          console.log('Undo clicked');
        },
      },
    });
  };

  const triggerPromise = () => {
    const promise = new Promise((resolve) => {
      setTimeout(() => resolve('Data loaded'), 2000);
    });

    toast.promise(promise, {
      loading: 'Loading data...',
      success: 'Data loaded successfully!',
      error: 'Failed to load data',
    });
  };

  const triggerCustom = () => {
    toast.custom((t) => (
      <div className="flex items-center gap-2 rounded border border-black bg-white p-3 text-sm shadow-[2px_2px_#bbb]">
        <span className="text-zinc-900">Custom toast #{t}</span>
      </div>
    ));
  };

  return (
    <div className="bg-white">
      <div className="pt-6 pb-12">
        <div className="mx-auto max-w-[650px] px-4">
          <Card variant="primary">
            <div className="p-4">
              <h1 className="mb-4 font-bold text-lg text-zinc-900">
                Toast Demo Page
              </h1>
              <p className="mb-6 text-xs text-zinc-600">
                Test different toast notifications. Click any button below to
                trigger a toast.
              </p>

              <div className="space-y-4">
                {/* Basic Toasts */}
                <div>
                  <h2 className="mb-2 font-bold text-xs text-zinc-900">
                    Basic Toasts
                  </h2>
                  <div className="flex flex-wrap gap-2">
                    <Button
                      onClick={() => triggerToast('default')}
                      size="sm"
                      variant="secondary"
                    >
                      Default
                    </Button>
                    <Button
                      onClick={() => triggerToast('success')}
                      size="sm"
                      variant="secondary"
                    >
                      Success
                    </Button>
                    <Button
                      onClick={() => triggerToast('error')}
                      size="sm"
                      variant="secondary"
                    >
                      Error
                    </Button>
                    <Button
                      onClick={() => triggerToast('info')}
                      size="sm"
                      variant="secondary"
                    >
                      Info
                    </Button>
                    <Button
                      onClick={() => triggerToast('warning')}
                      size="sm"
                      variant="secondary"
                    >
                      Warning
                    </Button>
                  </div>
                </div>

                {/* Advanced Toasts */}
                <div>
                  <h2 className="mb-2 font-bold text-xs text-zinc-900">
                    Advanced Toasts
                  </h2>
                  <div className="flex flex-wrap gap-2">
                    <Button
                      onClick={triggerWithDescription}
                      size="sm"
                      variant="secondary"
                    >
                      With Description
                    </Button>
                    <Button
                      onClick={triggerWithAction}
                      size="sm"
                      variant="secondary"
                    >
                      With Action
                    </Button>
                    <Button
                      onClick={triggerPromise}
                      size="sm"
                      variant="secondary"
                    >
                      Promise Toast
                    </Button>
                    <Button
                      onClick={triggerCustom}
                      size="sm"
                      variant="secondary"
                    >
                      Custom Toast
                    </Button>
                  </div>
                </div>

                {/* Custom Message */}
                <div>
                  <h2 className="mb-2 font-bold text-xs text-zinc-900">
                    Custom Message
                  </h2>
                  <div className="flex gap-2">
                    <input
                      className="h-8 flex-1 border border-zinc-300 px-2 text-xs focus:border-zinc-400 focus:outline-none"
                      onChange={(e) => setMessage(e.target.value)}
                      placeholder="Enter custom message..."
                      type="text"
                      value={message}
                    />
                    <Button
                      disabled={!message}
                      onClick={() => {
                        if (message) {
                          toast(message);
                          setMessage('');
                        }
                      }}
                      size="sm"
                      variant="primary"
                    >
                      Send Toast
                    </Button>
                  </div>
                </div>

                {/* Multiple Toasts */}
                <div>
                  <h2 className="mb-2 font-bold text-xs text-zinc-900">
                    Stress Test
                  </h2>
                  <Button
                    onClick={() => {
                      toast.success('First toast');
                      setTimeout(() => toast.error('Second toast'), 200);
                      setTimeout(() => toast.info('Third toast'), 400);
                      setTimeout(() => toast.warning('Fourth toast'), 600);
                      setTimeout(() => toast('Fifth toast'), 800);
                    }}
                    size="sm"
                    variant="secondary"
                  >
                    Trigger Multiple Toasts
                  </Button>
                </div>
              </div>

              <div className="mt-6 border-zinc-200 border-t pt-4">
                <p className="text-xs text-zinc-500">
                  Note: This is a demo page for testing toast notifications. The
                  X button should appear in the top right of each toast without
                  any animations.
                </p>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
