'use client';

import { Menu as DropdownMenuPrimitive } from '@base-ui-components/react/menu';
import { CheckIcon, CircleIcon } from '@phosphor-icons/react';
import type { ComponentProps } from 'react';
import { cn } from '@/lib/utils';

function DropdownMenu({
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.Root>) {
  return <DropdownMenuPrimitive.Root data-slot="dropdown-menu" {...props} />;
}

function DropdownMenuTrigger({
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.Trigger>) {
  return (
    <DropdownMenuPrimitive.Trigger
      data-slot="dropdown-menu-trigger"
      {...props}
      className={cn(props.className, 'cursor-pointer!')}
    />
  );
}

function DropdownMenuPortal({
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.Portal>) {
  return (
    <DropdownMenuPrimitive.Portal data-slot="dropdown-menu-portal" {...props} />
  );
}

function DropdownMenuBackdrop({
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.Backdrop>) {
  return (
    <DropdownMenuPrimitive.Backdrop
      data-slot="dropdown-menu-backdrop"
      {...props}
    />
  );
}

type DropdownMenuContentProps = Omit<
  ComponentProps<typeof DropdownMenuPrimitive.Positioner>,
  'render'
>;

function DropdownMenuContent({
  className,
  sideOffset = 4,
  children,
  ...props
}: DropdownMenuContentProps) {
  return (
    <DropdownMenuPortal>
      <DropdownMenuBackdrop />
      <DropdownMenuPrimitive.Positioner
        className="z-50 size-auto"
        data-slot="dropdown-menu-positioner"
        sideOffset={sideOffset}
        {...props}
      >
        <DropdownMenuPrimitive.Popup
          className={cn(
            'max-h-[var(--available-height)] min-w-[8rem] max-w-[var(--available-width)] overflow-y-auto overflow-x-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md transition-[transform,scale,opacity] duration-150 ease-out',
            '[transform-origin:var(--transform-origin)] data-[ending-style]:scale-95 data-[starting-style]:scale-95 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0',
            'focus:outline-none data-[popup-open]:outline-none data-[popup-open]:ring-0',
            className
          )}
          data-slot="dropdown-menu-content"
        >
          {children}
        </DropdownMenuPrimitive.Popup>
      </DropdownMenuPrimitive.Positioner>
    </DropdownMenuPortal>
  );
}

interface DropdownMenuItemProps
  extends ComponentProps<typeof DropdownMenuPrimitive.Item> {
  inset?: boolean;
  variant?: 'default' | 'destructive';
}

function DropdownMenuItem({
  className,
  inset,
  variant = 'default',
  ...props
}: DropdownMenuItemProps) {
  return (
    <DropdownMenuPrimitive.Item
      className={cn(
        "data-[variant=destructive]:*:[svg]:!text-destructive relative flex cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none outline-hidden transition-all duration-150 focus:outline-none focus:ring-0 focus-visible:outline-none focus-visible:ring-0 data-[variant=destructive]:data-[highlighted]:bg-destructive/10 data-[variant=destructive]:data-[highlighted]:text-destructive data-[disabled]:pointer-events-none data-[highlighted]:bg-zinc-500/10 data-[inset]:pl-8 data-[variant=destructive]:text-destructive data-[disabled]:opacity-50 data-[highlighted]:brightness-125 data-[highlighted]:saturate-150 dark:data-[variant=destructive]:data-[highlighted]:bg-destructive/20 dark:data-[highlighted]:bg-accent/50 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground [&_svg]:shrink-0",
        className
      )}
      data-inset={inset}
      data-slot="dropdown-menu-item"
      data-variant={variant}
      {...props}
    />
  );
}

function DropdownMenuGroup({
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.Group>) {
  return (
    <DropdownMenuPrimitive.Group data-slot="dropdown-menu-group" {...props} />
  );
}

interface DropdownMenuGroupLabelProps
  extends ComponentProps<typeof DropdownMenuPrimitive.GroupLabel> {
  inset?: boolean;
}

function DropdownMenuGroupLabel({
  className,
  inset,
  ...props
}: DropdownMenuGroupLabelProps) {
  return (
    <DropdownMenuPrimitive.GroupLabel
      className={cn(
        'px-2 py-1.5 font-medium text-sm leading-none data-[inset]:pl-8',
        className
      )}
      data-inset={inset}
      data-slot="dropdown-menu-group-label"
      {...props}
    />
  );
}

function DropdownMenuRadioGroup({
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.RadioGroup>) {
  return (
    <DropdownMenuPrimitive.RadioGroup
      data-slot="dropdown-menu-radio-group"
      {...props}
    />
  );
}

function DropdownMenuRadioItem({
  className,
  children,
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.RadioItem>) {
  return (
    <DropdownMenuPrimitive.RadioItem
      className={cn(
        "relative flex cursor-default select-none items-center gap-2 rounded-sm py-1.5 pr-2 pl-8 text-sm outline-none transition-colors data-[disabled]:pointer-events-none data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground data-[disabled]:opacity-50 [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0",
        className
      )}
      data-slot="dropdown-menu-radio-item"
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <DropdownMenuPrimitive.RadioItemIndicator className="duration-150 ease-out data-[ending-style]:scale-60 data-[starting-style]:scale-60">
          <CircleIcon className="size-2 fill-current" />
        </DropdownMenuPrimitive.RadioItemIndicator>
      </span>
      {children}
    </DropdownMenuPrimitive.RadioItem>
  );
}

function DropdownMenuCheckboxItem({
  className,
  children,
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.CheckboxItem>) {
  return (
    <DropdownMenuPrimitive.CheckboxItem
      className={cn(
        "relative flex cursor-default select-none items-center gap-2 rounded-sm py-1.5 pr-2 pl-8 text-sm outline-none transition-colors data-[disabled]:pointer-events-none data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground data-[disabled]:opacity-50 [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0",
        className
      )}
      data-slot="dropdown-menu-checkbox-item"
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <DropdownMenuPrimitive.CheckboxItemIndicator className="duration-150 ease-out data-[ending-style]:scale-60 data-[starting-style]:scale-60">
          <CheckIcon className="size-4" />
        </DropdownMenuPrimitive.CheckboxItemIndicator>
      </span>
      {children}
    </DropdownMenuPrimitive.CheckboxItem>
  );
}

function DropdownMenuSubMenuTrigger({
  className,
  ...props
}: ComponentProps<typeof DropdownMenuPrimitive.SubmenuTrigger>) {
  return (
    <DropdownMenuPrimitive.SubmenuTrigger
      className={cn(
        'data-[popup-open]:bg-accent data-[popup-open]:text-accent-foreground',
        className
      )}
      data-slot="dropdown-menu-sub-menu-trigger"
      {...props}
    />
  );
}

function DropdownMenuSeparator({
  className,
  ...props
}: Omit<
  ComponentProps<typeof DropdownMenuPrimitive.Separator>,
  'orientation'
>) {
  return (
    <DropdownMenuPrimitive.Separator
      className={cn('-mx-1 my-1 h-px bg-border', className)}
      data-slot="dropdown-menu-separator"
      {...props}
    />
  );
}

function DropdownMenuShortcut({ className, ...props }: ComponentProps<'span'>) {
  return (
    <span
      className={cn(
        'ml-auto text-muted-foreground text-xs tracking-widest',
        className
      )}
      data-slot="dropdown-menu-shortcut"
      {...props}
    />
  );
}

export {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuPortal,
  DropdownMenuBackdrop,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuGroup,
  DropdownMenuGroupLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuCheckboxItem,
  DropdownMenuSubMenuTrigger,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
};
