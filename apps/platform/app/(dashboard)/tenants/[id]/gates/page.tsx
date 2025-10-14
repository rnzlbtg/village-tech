import { getGates } from '@/lib/actions/gate'
import GatesPageClient from '@/components/gates/GatesPageClient'

interface GatesPageProps {
  params: {
    id: string
  }
}

export default async function GatesPage(props: GatesPageProps) {
  const params = await props.params
  const gates = await getGates(params.id)

  return <GatesPageClient gates={gates} tenantId={params.id} />
}
