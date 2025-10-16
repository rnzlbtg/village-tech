'use client'

import { forwardRef, InputHTMLAttributes, SelectHTMLAttributes, TextareaHTMLAttributes } from 'react'
import { AlertCircle } from 'lucide-react'

interface BaseFieldProps {
  label: string
  error?: string
  required?: boolean
  helpText?: string
  className?: string
}

// Input Field
interface InputFieldProps extends BaseFieldProps, Omit<InputHTMLAttributes<HTMLInputElement>, 'className'> {}

export const InputField = forwardRef<HTMLInputElement, InputFieldProps>(
  ({ label, error, required, helpText, className = '', ...props }, ref) => {
    return (
      <div className={className}>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
        <input
          ref={ref}
          className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors ${
            error
              ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
              : 'border-gray-300 focus:border-primary focus:ring-primary'
          }`}
          {...props}
        />
        {helpText && !error && <p className="mt-1 text-sm text-gray-500">{helpText}</p>}
        {error && (
          <div className="mt-1 flex items-center gap-1 text-sm text-red-600">
            <AlertCircle className="h-4 w-4" />
            <span>{error}</span>
          </div>
        )}
      </div>
    )
  }
)

InputField.displayName = 'InputField'

// Select Field
interface SelectFieldProps extends BaseFieldProps, Omit<SelectHTMLAttributes<HTMLSelectElement>, 'className'> {
  options: { value: string | number; label: string }[]
  placeholder?: string
}

export const SelectField = forwardRef<HTMLSelectElement, SelectFieldProps>(
  ({ label, error, required, helpText, options, placeholder, className = '', ...props }, ref) => {
    return (
      <div className={className}>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
        <select
          ref={ref}
          className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors ${
            error
              ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
              : 'border-gray-300 focus:border-primary focus:ring-primary'
          }`}
          {...props}
        >
          {placeholder && (
            <option value="" disabled>
              {placeholder}
            </option>
          )}
          {options.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        {helpText && !error && <p className="mt-1 text-sm text-gray-500">{helpText}</p>}
        {error && (
          <div className="mt-1 flex items-center gap-1 text-sm text-red-600">
            <AlertCircle className="h-4 w-4" />
            <span>{error}</span>
          </div>
        )}
      </div>
    )
  }
)

SelectField.displayName = 'SelectField'

// Textarea Field
interface TextareaFieldProps extends BaseFieldProps, Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, 'className'> {}

export const TextareaField = forwardRef<HTMLTextAreaElement, TextareaFieldProps>(
  ({ label, error, required, helpText, className = '', ...props }, ref) => {
    return (
      <div className={className}>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
        <textarea
          ref={ref}
          className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors ${
            error
              ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
              : 'border-gray-300 focus:border-primary focus:ring-primary'
          }`}
          {...props}
        />
        {helpText && !error && <p className="mt-1 text-sm text-gray-500">{helpText}</p>}
        {error && (
          <div className="mt-1 flex items-center gap-1 text-sm text-red-600">
            <AlertCircle className="h-4 w-4" />
            <span>{error}</span>
          </div>
        )}
      </div>
    )
  }
)

TextareaField.displayName = 'TextareaField'

// Checkbox Field
interface CheckboxFieldProps extends BaseFieldProps, Omit<InputHTMLAttributes<HTMLInputElement>, 'type' | 'className'> {}

export const CheckboxField = forwardRef<HTMLInputElement, CheckboxFieldProps>(
  ({ label, error, helpText, className = '', ...props }, ref) => {
    return (
      <div className={className}>
        <div className="flex items-start">
          <input
            ref={ref}
            type="checkbox"
            className={`mt-1 h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary focus:ring-offset-2 transition-colors ${
              error ? 'border-red-300' : ''
            }`}
            {...props}
          />
          <div className="ml-3">
            <label className="text-sm font-medium text-gray-700">{label}</label>
            {helpText && !error && <p className="text-sm text-gray-500">{helpText}</p>}
            {error && (
              <div className="flex items-center gap-1 text-sm text-red-600">
                <AlertCircle className="h-4 w-4" />
                <span>{error}</span>
              </div>
            )}
          </div>
        </div>
      </div>
    )
  }
)

CheckboxField.displayName = 'CheckboxField'

// Radio Group Field
interface RadioOption {
  value: string | number
  label: string
  helpText?: string
}

interface RadioGroupFieldProps extends BaseFieldProps {
  name: string
  options: RadioOption[]
  value?: string | number
  onChange: (value: string | number) => void
}

export function RadioGroupField({
  label,
  error,
  required,
  helpText,
  name,
  options,
  value,
  onChange,
  className = '',
}: RadioGroupFieldProps) {
  return (
    <div className={className}>
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {label}
        {required && <span className="text-red-500 ml-1">*</span>}
      </label>
      <div className="space-y-3">
        {options.map((option) => (
          <div key={option.value} className="flex items-start">
            <input
              type="radio"
              id={`${name}-${option.value}`}
              name={name}
              value={option.value}
              checked={value === option.value}
              onChange={(e) => onChange(e.target.value)}
              className="mt-1 h-4 w-4 border-gray-300 text-primary focus:ring-primary focus:ring-offset-2"
            />
            <div className="ml-3">
              <label
                htmlFor={`${name}-${option.value}`}
                className="text-sm font-medium text-gray-700 cursor-pointer"
              >
                {option.label}
              </label>
              {option.helpText && <p className="text-sm text-gray-500">{option.helpText}</p>}
            </div>
          </div>
        ))}
      </div>
      {helpText && !error && <p className="mt-2 text-sm text-gray-500">{helpText}</p>}
      {error && (
        <div className="mt-2 flex items-center gap-1 text-sm text-red-600">
          <AlertCircle className="h-4 w-4" />
          <span>{error}</span>
        </div>
      )}
    </div>
  )
}
