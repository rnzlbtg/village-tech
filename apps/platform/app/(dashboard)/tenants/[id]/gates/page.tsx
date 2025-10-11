import Link from 'next/link'
import { Plus } from 'lucide-react'
import { getGates } from '@/lib/actions/gate'
import GateList from '@/components/gates/GateList'

interface GatesPageProps {
  params: {
    id: string
  }
}

export default async function GatesPage({ params }: GatesPageProps) {
  const gates = await getGates(params.id)

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Gates & Entrances</h1>
          <p className="text-gray-600 mt-1">Manage entry points and gate equipment</p>
        </div>
        <Link
          href={`/tenants/${params.id}/gates/new`}
          className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg flex items-center transition-colors duration-200"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Gate
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow p-4">
        <div className="flex items-center justify-between mb-4">
          <p className="text-sm text-gray-600">
            <span className="font-semibold text-gray-800">{gates.length}</span>{' '}
            {gates.length === 1 ? 'gate' : 'gates'} total
          </p>
        </div>
      </div>

      <GateList gates={gates} tenantId={params.id} />
    </div>
  )
}
