'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { CurfewSettings } from './CurfewSettings'
import { CreateRuleModal } from './CreateRuleModal'
import { publishRules, getVillageRules, getCurfewSettings } from '@/lib/actions/rules'

export function RulesPageContent() {
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false)
  const [rules, setRules] = useState<any[]>([])
  const [curfewSettings, setCurfewSettings] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [publishing, setPublishing] = useState<string | null>(null)
  const supabase = createClient()

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true)

        // Get current user to extract tenant_id
        const { data: { user } } = await supabase.auth.getUser()
        const tenantId = user?.app_metadata?.tenant_id || user?.user_metadata?.tenant_id

        if (!tenantId) {
          console.error('No tenant_id found in user metadata')
          return
        }

        // Load rules and curfew settings in parallel
        const [rulesResult, curfewResult] = await Promise.all([
          getVillageRules(),
          getCurfewSettings()
        ])

        if (rulesResult.success) {
          setRules(rulesResult.data)
        } else {
          console.error('Error fetching rules:', rulesResult.error)
        }

        if (curfewResult.success) {
          setCurfewSettings(curfewResult.data)
        } else {
          console.error('Error fetching curfew settings:', curfewResult.error)
        }
      } catch (error) {
        console.error('Error loading data:', error)
      } finally {
        setLoading(false)
      }
    }

    loadData()
  }, [supabase])

  const publishedRules = rules.filter((rule: any) => rule.published)
  const draftRules = rules.filter((rule: any) => !rule.published)

  const handleCreateSuccess = () => {
    setIsCreateModalOpen(false)
    // Reload data to get the updated rules
    window.location.reload()
  }

  const handlePublishRule = async (ruleId: string) => {
    setPublishing(ruleId)

    try {
      const result = await publishRules({
        rules_id: ruleId,
        notify_residents: true,
        notify_guards: true
      })

      if (result.success) {
        // Reload the page to show updated rules
        window.location.reload()
      } else {
        alert(`Error publishing rule: ${result.error}`)
      }
    } catch (error) {
      console.error('Error publishing rule:', error)
      alert('Failed to publish rule. Please try again.')
    } finally {
      setPublishing(null)
    }
  }

  if (loading) {
    return (
      <div className="container mx-auto py-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/3 mb-6"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2 mb-8"></div>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-20 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="container mx-auto py-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold">Village Rules & Curfew</h1>
          <p className="text-gray-600 mt-1">
            Manage community rules, guidelines, and curfew times
          </p>
        </div>
        <button
          onClick={() => setIsCreateModalOpen(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Create New Rule
        </button>
      </div>

      <CreateRuleModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
      />

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
                        <div className="flex items-center gap-4 text-sm text-gray-500 mt-1">
                          <span>Category: {rule.rule_category}</span>
                          <span>Effective: {new Date(rule.effective_date).toLocaleDateString()}</span>
                        </div>
                        <p className="text-sm text-gray-700 mt-2 line-clamp-2">{rule.description}</p>
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
                        <div className="flex items-center gap-4 text-sm text-gray-500 mt-1">
                          <span>Category: {rule.rule_category}</span>
                          <span>Created: {new Date(rule.created_at).toLocaleDateString()}</span>
                        </div>
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
                      <button
                        onClick={() => handlePublishRule(rule.id)}
                        disabled={publishing === rule.id}
                        className="text-sm text-green-600 hover:text-green-800 disabled:text-green-400 disabled:cursor-not-allowed"
                      >
                        {publishing === rule.id ? 'Publishing...' : 'Publish'}
                      </button>
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
              {rules
                .sort((a: any, b: any) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime())
                .slice(0, 5)
                .map((rule: any) => (
                  <div
                    key={`${rule.id}-${rule.updated_at}`}
                    className="flex items-center justify-between py-2 border-b border-gray-100"
                  >
                    <div>
                      <span className="text-sm font-medium text-gray-900">{rule.title}</span>
                      <span className="text-xs text-gray-500 ml-2">Last updated</span>
                    </div>
                    <span className="text-xs text-gray-500">
                      {new Date(rule.updated_at).toLocaleDateString()}
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
                <span className="text-sm font-semibold text-gray-900">{rules.length}</span>
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