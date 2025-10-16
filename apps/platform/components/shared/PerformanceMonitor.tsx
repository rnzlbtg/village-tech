'use client'

import { useEffect } from 'react'
import { usePathname } from 'next/navigation'
import { performanceMonitor } from '@/lib/monitoring/performance'

export default function PerformanceMonitor() {
  const pathname = usePathname()

  useEffect(() => {
    // Measure page load time
    if (typeof window !== 'undefined') {
      // Wait for page to fully load
      window.addEventListener('load', () => {
        const pageName = pathname.replace(/\//g, '_') || 'home'
        performanceMonitor.measurePageLoad(pageName)
      })

      // Log summary in development mode
      if (process.env.NODE_ENV === 'development') {
        // Log performance summary every 30 seconds
        const interval = setInterval(() => {
          const summary = performanceMonitor.getSummary()
          if (Object.keys(summary).length > 0) {
            console.group('Performance Summary')
            console.table(summary)
            console.groupEnd()
          }
        }, 30000)

        return () => clearInterval(interval)
      }
    }
  }, [pathname])

  // Monitor slow operations
  useEffect(() => {
    if (typeof window === 'undefined') return

    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        // Log long tasks (> 50ms)
        if (entry.duration > 50) {
          console.warn(`Long task detected: ${entry.name} took ${entry.duration.toFixed(2)}ms`)
        }
      }
    })

    try {
      observer.observe({ entryTypes: ['longtask', 'measure'] })
    } catch (e) {
      // PerformanceObserver not supported
    }

    return () => observer.disconnect()
  }, [])

  return null // This component doesn't render anything
}
