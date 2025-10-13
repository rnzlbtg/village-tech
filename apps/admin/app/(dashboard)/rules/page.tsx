import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { redirect } from 'next/navigation'
import { RulesEditor } from '@/components/rules/RulesEditor'
import { CurfewSettings } from '@/components/rules/CurfewSettings'

export const metadata = {
  title: 'Village Rules | Admin',
  description: 'Manage village rules and curfew settings',
}

export default async function VillageRulesPage() {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  if (!tenantId) {
    redirect('/login')
  }

  // Get village rules and curfew settings from association_settings
  const { data: settings, error } = await supabase
    .from('association_settings')
    .select('village_rules, curfew_settings')
    .eq('tenant_id', tenantId)
    .single()

  if (error) {
    console.error('Error fetching settings:', error)
  }

  const villageRules = settings?.village_rules || []
  const curfewSettings = settings?.curfew_settings || null

  // Get published rules
  const publishedRules = villageRules.filter((rule: any) => rule.published)
  const draftRules = villageRules.filter((rule: any) => !rule.published)

  return (
    <div className="container mx-auto py-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold">Village Rules & Curfew</h1>
          <p className="text-gray-600 mt-1">
            Manage community rules, guidelines, and curfew times
          </p>
        </div>
        <a
          href="/rules/new"
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Create New Rule
        </a>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Published Rules */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Published Rules</h2>
            {publishedRules.length > 0 ? (
              <div className="space-y-4">
                {publishedRules.map((rule: any) => (
                  <div
                    key={rule.id}
                    className="border border-gray-200 rounded-lg p-4 hover:border-blue-300 transition-colors"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h3 className="font-semibold text-lg text-gray-900">{rule.title}</h3>
                        <p className="text-sm text-gray-500 mt-1">
                          Effective: {new Date(rule.effective_date).toLocaleDateString()} | Version{' '}
                          {rule.version}
                        </p>
                        <p className="text-sm text-gray-700 mt-2 line-clamp-2">{rule.content}</p>
                      </div>
                      <div className="ml-4">
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                          Published
                        </span>
                      </div>
                    </div>
                    <div className="mt-3 flex gap-2">
                      <a
                        href={`/rules/${rule.id}`}
                        className="text-sm text-blue-600 hover:text-blue-800"
                      >
                        View Details
                      </a>
                      <a
                        href={`/rules/${rule.id}/edit`}
                        className="text-sm text-gray-600 hover:text-gray-800"
                      >
                        Edit
                      </a>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-500 text-center py-8">
                No published rules yet. Create and publish your first rule!
              </p>
            )}
          </div>

          {/* Draft Rules */}
          {draftRules.length > 0 && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Draft Rules</h2>
              <div className="space-y-4">
                {draftRules.map((rule: any) => (
                  <div
                    key={rule.id}
                    className="border border-gray-200 rounded-lg p-4 hover:border-yellow-300 transition-colors"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h3 className="font-semibold text-lg text-gray-900">{rule.title}</h3>
                        <p className="text-sm text-gray-500 mt-1">
                          Created: {new Date(rule.created_at).toLocaleDateString()}
                        </p>
                      </div>
                      <div className="ml-4">
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">
                          Draft
                        </span>
                      </div>
                    </div>
                    <div className="mt-3 flex gap-2">
                      <a
                        href={`/rules/${rule.id}/edit`}
                        className="text-sm text-blue-600 hover:text-blue-800"
                      >
                        Edit
                      </a>
                      <a
                        href={`/rules/${rule.id}/publish`}
                        className="text-sm text-green-600 hover:text-green-800"
                      >
                        Publish
                      </a>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Rules History */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Rules History</h2>
            <p className="text-sm text-gray-600 mb-4">
              View all rule versions and track changes over time
            </p>
            <div className="space-y-2">
              {villageRules
                .sort((a: any, b: any) => b.version - a.version)
                .slice(0, 5)
                .map((rule: any) => (
                  <div
                    key={`${rule.id}-${rule.version}`}
                    className="flex items-center justify-between py-2 border-b border-gray-100"
                  >
                    <div>
                      <span className="text-sm font-medium text-gray-900">{rule.title}</span>
                      <span className="text-xs text-gray-500 ml-2">v{rule.version}</span>
                    </div>
                    <span className="text-xs text-gray-500">
                      {new Date(rule.updated_at || rule.created_at).toLocaleDateString()}
                    </span>
                  </div>
                ))}
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Curfew Settings */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Curfew Settings</h2>
            <CurfewSettings currentSettings={curfewSettings} />
          </div>

          {/* Statistics */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Statistics</h2>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Total Rules</span>
                <span className="text-sm font-semibold text-gray-900">{villageRules.length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Published</span>
                <span className="text-sm font-semibold text-green-600">
                  {publishedRules.length}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Drafts</span>
                <span className="text-sm font-semibold text-yellow-600">
                  {draftRules.length}
                </span>
              </div>
              <div className="flex justify-between pt-2 border-t border-gray-200">
                <span className="text-sm text-gray-600">Curfew Active</span>
                <span
                  className={`text-sm font-semibold ${curfewSettings?.active ? 'text-green-600' : 'text-gray-400'}`}
                >
                  {curfewSettings?.active ? 'Yes' : 'No'}
                </span>
              </div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Quick Actions</h2>
            <div className="space-y-2">
              <button className="w-full px-4 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 text-left">
                Export All Rules (PDF)
              </button>
              <button className="w-full px-4 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 text-left">
                Email Rules to All Residents
              </button>
              <button className="w-full px-4 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 text-left">
                View Violation Reports
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
