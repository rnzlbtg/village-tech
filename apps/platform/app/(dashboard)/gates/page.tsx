import { getTenants } from '@/lib/actions/tenant'
import GateManagementClient from '@/components/gates/GateManagementClient'

export default async function GatesManagementPage() {
  const tenants = await getTenants()

  return <GateManagementClient tenants={tenants} />
}
