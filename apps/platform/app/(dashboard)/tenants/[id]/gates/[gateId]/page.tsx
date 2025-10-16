import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { notFound } from 'next/navigation'
import { getGate } from '@/lib/actions/gate'
import GateForm from '@/components/gates/GateForm'

interface GateDetailPageProps {
  params: {
    id: string
    gateId: string
  }
}

export default async function GateDetailPage({ params }: GateDetailPageProps) {
  const result = await getGate(params.gateId)

  if (!result.success || !result.data) {
    notFound()
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-4">
        <Link
          href={`/tenants/${params.id}/gates`}
          className="text-gray-600 hover:text-gray-800 transition-colors"
        >
          <ArrowLeft className="h-6 w-6" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Edit Gate</h1>
          <p className="text-gray-600 mt-1">Update gate configuration and settings</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <GateForm tenantId={params.id} initialData={result.data} mode="edit" />
      </div>
    </div>
  )
}
