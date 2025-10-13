'use client'

type Priority = 'normal' | 'high' | 'urgent'

export function PrioritySelector({
  value,
  onChange,
}: {
  value: Priority
  onChange: (priority: Priority) => void
}) {
  const priorities: { value: Priority; label: string; description: string; color: string }[] = [
    {
      value: 'normal',
      label: 'Normal',
      description: 'Standard announcement, no special notifications',
      color: 'bg-blue-50 border-blue-300 text-blue-700',
    },
    {
      value: 'high',
      label: 'High',
      description: 'Important announcement, appears prominently',
      color: 'bg-yellow-50 border-yellow-300 text-yellow-700',
    },
    {
      value: 'urgent',
      label: 'Urgent',
      description: 'Critical announcement, sends push notifications',
      color: 'bg-red-50 border-red-300 text-red-700',
    },
  ]

  return (
    <div className="space-y-2">
      {priorities.map(priority => (
        <label
          key={priority.value}
          className={`flex items-start p-3 border-2 rounded-lg cursor-pointer transition-all ${
            value === priority.value
              ? priority.color
              : 'bg-white border-gray-200 hover:border-gray-300'
          }`}
        >
          <input
            type="radio"
            name="priority"
            value={priority.value}
            checked={value === priority.value}
            onChange={e => onChange(e.target.value as Priority)}
            className="mt-0.5 mr-3"
          />
          <div className="flex-1">
            <div className="font-medium">{priority.label}</div>
            <div className="text-sm opacity-80 mt-0.5">{priority.description}</div>
          </div>
        </label>
      ))}
    </div>
  )
}
