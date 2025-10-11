'use client'

import { Toaster as Sonner } from 'sonner'

type ToasterProps = React.ComponentProps<typeof Sonner>

const Toaster = ({ ...props }: ToasterProps) => {
  return (
    <Sonner
      className="toaster group"
      position="top-right"
      toastOptions={{
        classNames: {
          toast:
            'group toast group-[.toaster]:bg-white group-[.toaster]:text-gray-900 group-[.toaster]:border group-[.toaster]:shadow-lg group-[.toaster]:rounded-lg group-[.toaster]:p-4',
          description: 'group-[.toast]:text-gray-600 group-[.toast]:text-sm',
          actionButton:
            'group-[.toast]:bg-primary group-[.toast]:text-white group-[.toast]:rounded group-[.toast]:px-3 group-[.toast]:py-1.5',
          cancelButton:
            'group-[.toast]:bg-gray-100 group-[.toast]:text-gray-700 group-[.toast]:rounded group-[.toast]:px-3 group-[.toast]:py-1.5',
          error:
            '!bg-red-50 !text-red-900 !border-red-300 [&>svg]:text-red-600 [&_[data-description]]:text-red-700',
          success:
            '!bg-green-50 !text-green-900 !border-green-300 [&>svg]:text-green-600 [&_[data-description]]:text-green-700',
          warning:
            '!bg-amber-50 !text-amber-900 !border-amber-300 [&>svg]:text-amber-600 [&_[data-description]]:text-amber-700',
          info: '!bg-blue-50 !text-blue-900 !border-blue-300 [&>svg]:text-blue-600 [&_[data-description]]:text-blue-700',
          loading:
            '!bg-gray-50 !text-gray-900 !border-gray-300 [&>svg]:text-gray-600 [&_[data-description]]:text-gray-700',
        },
      }}
      {...props}
    />
  )
}

export { Toaster }
