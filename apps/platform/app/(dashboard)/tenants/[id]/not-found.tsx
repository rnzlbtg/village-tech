import Link from 'next/link'
import { AlertCircle, ArrowLeft } from 'lucide-react'

export default function TenantNotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] space-y-6">
      <div className="text-center space-y-4">
        <AlertCircle className="h-16 w-16 text-gray-400 mx-auto" />
        <h1 className="text-3xl font-bold text-gray-800">Community Not Found</h1>
        <p className="text-gray-600 max-w-md">
          The community you're looking for doesn't exist or has been removed.
        </p>
      </div>

      <Link
        href="/tenants"
        className="bg-primary hover:bg-secondary text-white px-6 py-3 rounded-lg flex items-center transition-colors duration-200"
      >
        <ArrowLeft className="h-5 w-5 mr-2" />
        Back to Communities
      </Link>
    </div>
  )
}
