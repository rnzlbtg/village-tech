import { TableSkeleton } from '@/components/shared/LoadingSkeletons'

export default function HouseholdsLoading() {
  return (
    <div className="space-y-6">
      <div className="animate-pulse">
        <div className="h-8 bg-gray-300 rounded w-48 mb-2"></div>
        <div className="h-4 bg-gray-200 rounded w-64"></div>
      </div>
      <div className="bg-white rounded-lg shadow p-6">
        <TableSkeleton rows={10} columns={7} />
      </div>
    </div>
  )
}
