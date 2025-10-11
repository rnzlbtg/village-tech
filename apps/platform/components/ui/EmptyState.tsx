import { LucideIcon } from 'lucide-react'

interface EmptyStateProps {
  icon: LucideIcon
  title: string
  description: string
  action?: {
    label: string
    onClick: () => void
  }
}

export default function EmptyState({ icon: Icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex items-center justify-center min-h-[300px]">
      <div className="text-center space-y-4 max-w-md">
        <div className="flex justify-center">
          <div className="p-4 bg-gray-100 rounded-full">
            <Icon className="h-12 w-12 text-gray-400" />
          </div>
        </div>
        <h3 className="text-lg font-semibold text-gray-800">{title}</h3>
        <p className="text-gray-600">{description}</p>
        {action && (
          <button
            onClick={action.onClick}
            className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
          >
            {action.label}
          </button>
        )}
      </div>
    </div>
  )
}
