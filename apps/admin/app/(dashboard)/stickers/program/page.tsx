import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import StickerProgramForm from './StickerProgramForm'

export const metadata = {
  title: 'Sticker Program Configuration | Admin',
  description: 'Configure vehicle sticker program settings',
}

export default async function StickerProgramPage() {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  // Get current active program
  const { data: currentProgram } = await supabase
    .from('sticker_programs')
    .select('*')
    .eq('tenant_id', tenantId)
    .eq('active', true)
    .maybeSingle()

  // Get all programs (history)
  const { data: allPrograms } = await supabase
    .from('sticker_programs')
    .select('*')
    .eq('tenant_id', tenantId)
    .order('created_at', { ascending: false })

  return (
    <div className="p-6 max-w-4xl">
      <div className="mb-6">
        <h1 className="text-2xl font-bold mb-2">Sticker Program Configuration</h1>
        <p className="text-gray-600">
          Configure vehicle sticker allocation limits for your community
        </p>
      </div>

      {currentProgram && (
        <div className="mb-8 p-6 bg-blue-50 rounded-lg border border-blue-200">
          <h3 className="font-semibold text-lg mb-4">Current Active Program</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-gray-600">Program Name</p>
              <p className="font-medium">{currentProgram.program_name}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Stickers per Household</p>
              <p className="font-medium text-2xl">{currentProgram.stickers_per_household}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Effective Date</p>
              <p className="font-medium">
                {new Date(currentProgram.effective_date).toLocaleDateString()}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Expiry Date</p>
              <p className="font-medium">
                {currentProgram.expiry_date
                  ? new Date(currentProgram.expiry_date).toLocaleDateString()
                  : 'No expiry'}
              </p>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white border rounded-lg p-6 mb-8">
        <h2 className="text-xl font-semibold mb-4">
          {currentProgram ? 'Create New Program' : 'Create Sticker Program'}
        </h2>
        <p className="text-sm text-gray-600 mb-6">
          {currentProgram
            ? 'Creating a new program will deactivate the current one.'
            : 'Set up your first vehicle sticker program.'}
        </p>
        <StickerProgramForm />
      </div>

      {allPrograms && allPrograms.length > 0 && (
        <div className="bg-white border rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">Program History</h2>
          <div className="space-y-4">
            {allPrograms.map((program) => (
              <div
                key={program.id}
                className={`p-4 rounded-lg border ${
                  program.active
                    ? 'bg-green-50 border-green-200'
                    : 'bg-gray-50 border-gray-200'
                }`}
              >
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="font-semibold">{program.program_name}</h3>
                      {program.active && (
                        <span className="px-2 py-1 bg-green-100 text-green-800 text-xs rounded">
                          ACTIVE
                        </span>
                      )}
                    </div>
                    <div className="grid grid-cols-3 gap-4 text-sm">
                      <div>
                        <p className="text-gray-600">Allocation</p>
                        <p className="font-medium">
                          {program.stickers_per_household} per household
                        </p>
                      </div>
                      <div>
                        <p className="text-gray-600">Effective</p>
                        <p className="font-medium">
                          {new Date(program.effective_date).toLocaleDateString()}
                        </p>
                      </div>
                      <div>
                        <p className="text-gray-600">Expiry</p>
                        <p className="font-medium">
                          {program.expiry_date
                            ? new Date(program.expiry_date).toLocaleDateString()
                            : 'No expiry'}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
