/**
 * Comprehensive error messages with recovery suggestions
 * Provides user-friendly error messages and actionable recovery steps
 */

export interface ErrorWithRecovery {
  title: string
  message: string
  recovery: string[]
  technicalDetails?: string
}

export const ErrorMessages = {
  // Authentication Errors
  AUTH_FAILED: {
    title: 'Authentication Failed',
    message: 'We could not verify your credentials. Please check your email and password.',
    recovery: [
      'Double-check your email address and password',
      'Try resetting your password using the "Forgot Password" link',
      'Clear your browser cache and cookies',
      'Contact support if the problem persists',
    ],
  },

  SESSION_EXPIRED: {
    title: 'Session Expired',
    message: 'Your session has expired for security reasons.',
    recovery: [
      'Please log in again to continue',
      'Enable "Remember Me" for longer sessions',
      'Check your browser settings allow cookies',
    ],
  },

  UNAUTHORIZED: {
    title: 'Unauthorized Access',
    message: 'You do not have permission to access this resource.',
    recovery: [
      'Verify you are logged in with the correct account',
      'Contact your administrator to request access',
      'Check if your account role has changed',
    ],
  },

  // Network Errors
  NETWORK_ERROR: {
    title: 'Network Connection Error',
    message: 'We could not connect to the server. Please check your internet connection.',
    recovery: [
      'Check your internet connection',
      'Try refreshing the page',
      'Disable any VPN or proxy that might be blocking the connection',
      'Contact your network administrator if on a corporate network',
    ],
  },

  TIMEOUT: {
    title: 'Request Timeout',
    message: 'The request took too long to complete.',
    recovery: [
      'Try again - this might be a temporary issue',
      'Check your internet speed',
      'Try with a smaller dataset or fewer filters',
      'Contact support if timeouts persist',
    ],
  },

  // Data Validation Errors
  VALIDATION_ERROR: {
    title: 'Validation Error',
    message: 'The information you provided could not be validated.',
    recovery: [
      'Review all required fields are filled out',
      'Check that email addresses are in the correct format',
      'Ensure phone numbers are valid',
      'Verify dates are in the correct format',
    ],
  },

  DUPLICATE_ENTRY: {
    title: 'Duplicate Entry',
    message: 'This record already exists in the system.',
    recovery: [
      'Check if a similar record already exists',
      'Try searching for the existing record to update it instead',
      'Contact support if you believe this is an error',
    ],
  },

  INVALID_FILE: {
    title: 'Invalid File',
    message: 'The file you uploaded could not be processed.',
    recovery: [
      'Check the file format is supported (CSV, Excel, PDF, etc.)',
      'Ensure the file is not corrupted',
      'Verify the file size is under the limit (10MB)',
      'Try converting the file to a different format',
    ],
  },

  // Database Errors
  DATABASE_ERROR: {
    title: 'Database Error',
    message: 'We encountered an issue while accessing the database.',
    recovery: [
      'Try refreshing the page',
      'Wait a few moments and try again',
      'Contact support if the error persists',
      'Check system status page for ongoing issues',
    ],
  },

  RECORD_NOT_FOUND: {
    title: 'Record Not Found',
    message: 'The requested record could not be found.',
    recovery: [
      'Verify the link you used is correct',
      'The record may have been deleted by another user',
      'Try searching for the record by name or ID',
      'Go back to the list view and try again',
    ],
  },

  FOREIGN_KEY_CONSTRAINT: {
    title: 'Cannot Delete Record',
    message: 'This record cannot be deleted because other records depend on it.',
    recovery: [
      'Delete or reassign dependent records first',
      'Check for related properties, units, or users',
      'Use archive/deactivate instead of delete if available',
      'Contact support for assistance with data cleanup',
    ],
  },

  // File Upload Errors
  FILE_TOO_LARGE: {
    title: 'File Too Large',
    message: 'The file you are trying to upload exceeds the maximum size limit.',
    recovery: [
      'Compress the file before uploading',
      'Split large files into smaller parts',
      'Current limit is 10MB per file',
      'Contact support to request a higher limit if needed',
    ],
  },

  UNSUPPORTED_FILE_TYPE: {
    title: 'Unsupported File Type',
    message: 'This file type is not supported.',
    recovery: [
      'Convert the file to a supported format (CSV, XLSX, PDF, PNG, JPG)',
      'Check the file extension is correct',
      'Ensure the file is not corrupted',
    ],
  },

  // Bulk Import Errors
  IMPORT_ERROR: {
    title: 'Import Failed',
    message: 'We encountered errors while importing your data.',
    recovery: [
      'Download the error report to see which rows failed',
      'Fix the errors in your spreadsheet',
      'Ensure all required columns are present',
      'Check that data formats match the template',
      'Try importing a smaller batch of records',
    ],
  },

  RATE_LIMIT_EXCEEDED: {
    title: 'Too Many Requests',
    message: 'You have exceeded the rate limit for this operation.',
    recovery: [
      'Wait a few minutes before trying again',
      'Reduce the frequency of your requests',
      'Import smaller batches of data',
      'Contact support to increase your rate limit',
    ],
  },

  // Server Errors
  SERVER_ERROR: {
    title: 'Server Error',
    message: 'Something went wrong on our end. Our team has been notified.',
    recovery: [
      'Try again in a few minutes',
      'Refresh the page',
      'Clear your browser cache if the problem persists',
      'Contact support with the error details if this continues',
    ],
  },

  SERVICE_UNAVAILABLE: {
    title: 'Service Temporarily Unavailable',
    message: 'The service is temporarily unavailable. We are working to restore it.',
    recovery: [
      'Check the system status page for updates',
      'Try again in a few minutes',
      'Follow our status updates on social media',
      'Contact support for estimated recovery time',
    ],
  },
}

/**
 * Get error details with recovery suggestions
 */
export function getErrorDetails(
  errorCode: keyof typeof ErrorMessages,
  technicalDetails?: string
): ErrorWithRecovery {
  const error = ErrorMessages[errorCode] || ErrorMessages.SERVER_ERROR

  return {
    ...error,
    technicalDetails,
  }
}

/**
 * Format error for display
 */
export function formatError(error: unknown): ErrorWithRecovery {
  if (error instanceof Error) {
    // Check for specific error patterns
    if (error.message.includes('Network')) {
      return getErrorDetails('NETWORK_ERROR', error.message)
    }
    if (error.message.includes('timeout')) {
      return getErrorDetails('TIMEOUT', error.message)
    }
    if (error.message.includes('duplicate') || error.message.includes('already exists')) {
      return getErrorDetails('DUPLICATE_ENTRY', error.message)
    }
    if (error.message.includes('not found')) {
      return getErrorDetails('RECORD_NOT_FOUND', error.message)
    }
    if (error.message.includes('foreign key')) {
      return getErrorDetails('FOREIGN_KEY_CONSTRAINT', error.message)
    }
    if (error.message.includes('validation')) {
      return getErrorDetails('VALIDATION_ERROR', error.message)
    }
    if (error.message.includes('Unauthorized') || error.message.includes('401')) {
      return getErrorDetails('UNAUTHORIZED', error.message)
    }

    // Generic server error
    return getErrorDetails('SERVER_ERROR', error.message)
  }

  return getErrorDetails('SERVER_ERROR', String(error))
}
