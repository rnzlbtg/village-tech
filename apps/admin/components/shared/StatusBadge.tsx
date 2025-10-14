import { CheckCircle, XCircle, Clock, AlertCircle, MinusCircle, Ban } from 'lucide-react'

export type BadgeVariant =
  | 'success'
  | 'error'
  | 'warning'
  | 'info'
  | 'pending'
  | 'default'
  | 'active'
  | 'inactive'

interface StatusBadgeProps {
  status: string
  variant?: BadgeVariant
  showIcon?: boolean
  className?: string
}

const variantStyles: Record<BadgeVariant, { bg: string; text: string; icon?: any }> = {
  success: {
    bg: 'bg-green-100',
    text: 'text-green-800',
    icon: CheckCircle,
  },
  error: {
    bg: 'bg-red-100',
    text: 'text-red-800',
    icon: XCircle,
  },
  warning: {
    bg: 'bg-yellow-100',
    text: 'text-yellow-800',
    icon: AlertCircle,
  },
  info: {
    bg: 'bg-blue-100',
    text: 'text-blue-800',
    icon: AlertCircle,
  },
  pending: {
    bg: 'bg-orange-100',
    text: 'text-orange-800',
    icon: Clock,
  },
  active: {
    bg: 'bg-green-100',
    text: 'text-green-800',
    icon: CheckCircle,
  },
  inactive: {
    bg: 'bg-gray-100',
    text: 'text-gray-800',
    icon: MinusCircle,
  },
  default: {
    bg: 'bg-gray-100',
    text: 'text-gray-800',
  },
}

// Auto-detect variant based on status string
function getVariantFromStatus(status: string): BadgeVariant {
  const lowerStatus = status.toLowerCase()

  // Success states
  if (
    ['approved', 'paid', 'completed', 'active', 'verified', 'confirmed', 'delivered'].includes(
      lowerStatus
    )
  ) {
    return 'success'
  }

  // Error states
  if (
    ['rejected', 'failed', 'cancelled', 'voided', 'declined', 'error', 'denied'].includes(
      lowerStatus
    )
  ) {
    return 'error'
  }

  // Warning states
  if (
    ['overdue', 'expiring', 'partial', 'on_hold', 'suspended', 'expired'].includes(lowerStatus)
  ) {
    return 'warning'
  }

  // Pending states
  if (['pending', 'processing', 'reviewing', 'submitted', 'in_progress'].includes(lowerStatus)) {
    return 'pending'
  }

  // Inactive states
  if (['inactive', 'archived', 'disabled', 'moved_out'].includes(lowerStatus)) {
    return 'inactive'
  }

  // Info states
  if (['draft', 'scheduled', 'upcoming'].includes(lowerStatus)) {
    return 'info'
  }

  return 'default'
}

export default function StatusBadge({
  status,
  variant,
  showIcon = true,
  className = '',
}: StatusBadgeProps) {
  const finalVariant = variant || getVariantFromStatus(status)
  const styles = variantStyles[finalVariant]
  const Icon = styles.icon

  // Format status text (replace underscores, capitalize)
  const formattedStatus = status
    .replace(/_/g, ' ')
    .split(' ')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join(' ')

  return (
    <span
      className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${styles.bg} ${styles.text} ${className}`}
    >
      {showIcon && Icon && <Icon className="h-3.5 w-3.5" />}
      {formattedStatus}
    </span>
  )
}

// Priority Badge (for announcements, etc.)
interface PriorityBadgeProps {
  priority: 'normal' | 'urgent' | 'critical'
  className?: string
}

export function PriorityBadge({ priority, className = '' }: PriorityBadgeProps) {
  const variants: Record<string, BadgeVariant> = {
    normal: 'info',
    urgent: 'warning',
    critical: 'error',
  }

  return <StatusBadge status={priority} variant={variants[priority]} className={className} />
}

// Payment Status Badge
interface PaymentStatusBadgeProps {
  status: 'unpaid' | 'partial' | 'paid' | 'overdue' | 'cancelled'
  amount?: number
  amountPaid?: number
  className?: string
}

export function PaymentStatusBadge({
  status,
  amount,
  amountPaid,
  className = '',
}: PaymentStatusBadgeProps) {
  const getDetails = () => {
    if (status === 'partial' && amount && amountPaid !== undefined) {
      const percentage = Math.round((amountPaid / amount) * 100)
      return `${status} (${percentage}%)`
    }
    return status
  }

  return <StatusBadge status={getDetails()} className={className} />
}

// Permit Status Badge
interface PermitStatusBadgeProps {
  status: 'pending' | 'approved' | 'rejected' | 'active' | 'expired' | 'on_hold'
  expiryDate?: string
  className?: string
}

export function PermitStatusBadge({
  status,
  expiryDate,
  className = '',
}: PermitStatusBadgeProps) {
  const isExpiringSoon =
    expiryDate && new Date(expiryDate) < new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)

  if (status === 'active' && isExpiringSoon) {
    return <StatusBadge status="expiring soon" variant="warning" className={className} />
  }

  return <StatusBadge status={status} className={className} />
}
