import { CardSkeleton, TableSkeleton } from '@/components/shared/LoadingSkeletons'

export default function FeesLoading() {
  return (
    <div className="space-y-6">
      <div className="animate-pulse">
        <div className="h-8 bg-gray-300 rounded w-48 mb-2"></div>
        <div className="h-4 bg-gray-200 rounded w-64"></div>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {Array.from({ length: 4 }).map((_, i) => (
          <CardSkeleton key={i} />
        ))}
      </div>
      <div className="bg-white rounded-lg shadow p-6">
        <TableSkeleton rows={8} columns={6} />
      </div>
    </div>
  )
}
