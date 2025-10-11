import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { notFound } from 'next/navigation'
import { getTenant } from '@/lib/actions/tenant'
import TenantForm from '@/components/tenants/TenantForm'

interface TenantEditPageProps {
  params: {
    id: string
  }
}

export default async function TenantEditPage({ params }: TenantEditPageProps) {
  const result = await getTenant(params.id)

  if (!result.success || !result.data) {
    notFound()
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-4">
        <Link href={`/tenants/${params.id}`} className="text-gray-600 hover:text-gray-800">
          <ArrowLeft className="h-6 w-6" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Edit Community</h1>
          <p className="text-gray-600 mt-1">Update community information</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <TenantForm mode="edit" initialData={result.data} />
      </div>
    </div>
  )
}
