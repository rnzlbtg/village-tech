import { requireSuperAdmin } from '@/lib/auth/helpers'
import RolesManagement from '@/components/users/RolesManagement'
import { getRoles } from '@/lib/actions/roles'

export default async function RolesPage() {
  await requireSuperAdmin()

  const rolesResult = await getRoles()
  const roles = rolesResult.success ? rolesResult.data : []

  return (
    <div className="space-y-6">
      <RolesManagement roles={roles} />
    </div>
  )
}
