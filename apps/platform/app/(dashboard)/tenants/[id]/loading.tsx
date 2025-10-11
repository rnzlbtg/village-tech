export default function TenantDetailLoading() {
  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-4">
        <div className="h-6 w-6 bg-gray-200 rounded animate-pulse" />
        <div>
          <div className="h-8 w-64 bg-gray-200 rounded animate-pulse mb-2" />
          <div className="h-4 w-48 bg-gray-200 rounded animate-pulse" />
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="bg-white border rounded-lg p-6">
            <div className="flex items-center space-x-3">
              <div className="h-12 w-12 bg-gray-200 rounded-lg animate-pulse" />
              <div className="space-y-2 flex-1">
                <div className="h-5 w-24 bg-gray-200 rounded animate-pulse" />
                <div className="h-4 w-32 bg-gray-200 rounded animate-pulse" />
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-lg shadow p-6 space-y-6">
        <div className="h-6 w-48 bg-gray-200 rounded animate-pulse" />
        {[1, 2, 3, 4, 5].map((i) => (
          <div key={i} className="h-10 bg-gray-200 rounded animate-pulse" />
        ))}
      </div>
    </div>
  )
}
