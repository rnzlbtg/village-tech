'use client'

import { useState } from 'react'

export function PermitApiTest() {
  const [result, setResult] = useState<string>('')
  const [loading, setLoading] = useState(false)

  const testApiCall = async (action: string, permitId: string = '47eafd3c-f415-4831-a8df-d1954b18203c') => {
    setLoading(true)
    setResult('')

    try {
      console.log(`🧪 Testing API call: ${action} for permit ${permitId}`)

      const response = await fetch(`/api/permits/${permitId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: action,
          data: action === 'reject'
            ? { rejection_reason: 'Test rejection reason - this is a test' }
            : action === 'hold'
            ? { hold_reason: 'Test hold reason - this is a test' }
            : {}
        }),
      })

      const responseData = await response.json()
      console.log(`🧪 API Response:`, responseData)

      setResult(`Status: ${response.status}\n${JSON.stringify(responseData, null, 2)}`)
    } catch (error) {
      console.error(`🧪 API Error:`, error)
      setResult(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6 bg-yellow-50 border-2 border-yellow-200 rounded-lg max-w-2xl mx-auto my-8">
      <h2 className="text-xl font-bold mb-4">🧪 Permit API Test</h2>
      <p className="text-sm text-gray-600 mb-4">
        Test the permits API to verify logging and functionality.
        Check the server console for logs.
      </p>

      <div className="space-y-4">
        <div className="flex gap-2 flex-wrap">
          <button
            onClick={() => testApiCall('approve')}
            disabled={loading}
            className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50"
          >
            Test Approve
          </button>

          <button
            onClick={() => testApiCall('reject')}
            disabled={loading}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50"
          >
            Test Reject
          </button>

          <button
            onClick={() => testApiCall('hold')}
            disabled={loading}
            className="px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700 disabled:opacity-50"
          >
            Test Hold
          </button>

          <button
            onClick={() => testApiCall('complete')}
            disabled={loading}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
          >
            Test Complete
          </button>

          <button
            onClick={() => testApiCall('invalid-action')}
            disabled={loading}
            className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50"
          >
            Test Invalid Action
          </button>
        </div>

        {loading && (
          <div className="text-blue-600">Loading... Check server console for logs!</div>
        )}

        {result && (
          <div className="mt-4 p-4 bg-gray-100 rounded border">
            <h3 className="font-semibold mb-2">Response:</h3>
            <pre className="text-xs overflow-auto whitespace-pre-wrap">
              {result}
            </pre>
          </div>
        )}

        <div className="text-xs text-gray-500 mt-4">
          <p>💡 Check your server console for logs like:</p>
          <code>📋 POST /permits/[id] - Action: approve</code>
        </div>
      </div>
    </div>
  )
}