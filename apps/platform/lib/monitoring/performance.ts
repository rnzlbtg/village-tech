/**
 * Performance Monitoring Utilities
 * Track page load times, API response times, and user interactions
 */

interface PerformanceMetric {
  name: string
  value: number
  timestamp: number
  metadata?: Record<string, any>
}

class PerformanceMonitor {
  private metrics: PerformanceMetric[] = []
  private maxMetrics = 100 // Keep last 100 metrics in memory

  /**
   * Record a performance metric
   */
  record(name: string, value: number, metadata?: Record<string, any>) {
    const metric: PerformanceMetric = {
      name,
      value,
      timestamp: Date.now(),
      metadata,
    }

    this.metrics.push(metric)

    // Keep only last N metrics
    if (this.metrics.length > this.maxMetrics) {
      this.metrics.shift()
    }

    // Log to console in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Performance] ${name}: ${value.toFixed(2)}ms`, metadata || '')
    }

    // Send to analytics service (implement as needed)
    this.sendToAnalytics(metric)
  }

  /**
   * Measure page load time
   */
  measurePageLoad(pageName: string) {
    if (typeof window === 'undefined') return

    try {
      const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming

      if (navigation) {
        // Total page load time
        const loadTime = navigation.loadEventEnd - navigation.fetchStart

        // Individual metrics
        const metrics = {
          domContentLoaded: navigation.domContentLoadedEventEnd - navigation.fetchStart,
          domInteractive: navigation.domInteractive - navigation.fetchStart,
          firstPaint: this.getFirstPaint(),
          loadComplete: loadTime,
        }

        this.record(`page_load_${pageName}`, loadTime, metrics)
      }
    } catch (error) {
      console.error('Error measuring page load:', error)
    }
  }

  /**
   * Measure component render time
   */
  measureRender(componentName: string, renderTime: number) {
    this.record(`render_${componentName}`, renderTime)
  }

  /**
   * Measure API call time
   */
  measureApiCall(endpoint: string, duration: number, status?: number) {
    this.record(`api_${endpoint}`, duration, { status })
  }

  /**
   * Measure database query time
   */
  measureQuery(queryName: string, duration: number) {
    this.record(`query_${queryName}`, duration)
  }

  /**
   * Get first paint time
   */
  private getFirstPaint(): number {
    if (typeof window === 'undefined') return 0

    const paintMetrics = performance.getEntriesByType('paint')
    const firstPaint = paintMetrics.find((entry) => entry.name === 'first-contentful-paint')
    return firstPaint ? firstPaint.startTime : 0
  }

  /**
   * Get all metrics
   */
  getMetrics(): PerformanceMetric[] {
    return [...this.metrics]
  }

  /**
   * Get metrics by name pattern
   */
  getMetricsByName(pattern: string): PerformanceMetric[] {
    return this.metrics.filter((m) => m.name.includes(pattern))
  }

  /**
   * Get average metric value
   */
  getAverage(metricName: string): number {
    const metrics = this.getMetricsByName(metricName)
    if (metrics.length === 0) return 0

    const sum = metrics.reduce((acc, m) => acc + m.value, 0)
    return sum / metrics.length
  }

  /**
   * Get performance summary
   */
  getSummary() {
    const summary: Record<string, { count: number; avg: number; min: number; max: number }> = {}

    this.metrics.forEach((metric) => {
      if (!summary[metric.name]) {
        summary[metric.name] = { count: 0, avg: 0, min: Infinity, max: 0 }
      }

      const s = summary[metric.name]
      s.count++
      s.avg = (s.avg * (s.count - 1) + metric.value) / s.count
      s.min = Math.min(s.min, metric.value)
      s.max = Math.max(s.max, metric.value)
    })

    return summary
  }

  /**
   * Clear all metrics
   */
  clear() {
    this.metrics = []
  }

  /**
   * Send metric to analytics service
   * Implement based on your analytics provider
   */
  private sendToAnalytics(metric: PerformanceMetric) {
    // Example: Send to Google Analytics, Mixpanel, etc.
    if (typeof window !== 'undefined' && (window as any).gtag) {
      ;(window as any).gtag('event', 'performance', {
        metric_name: metric.name,
        metric_value: metric.value,
        ...metric.metadata,
      })
    }
  }
}

// Singleton instance
export const performanceMonitor = new PerformanceMonitor()

/**
 * Hook for measuring component render time
 */
export function usePerformanceMonitor(componentName: string) {
  if (typeof window === 'undefined') return

  const startTime = performance.now()

  return () => {
    const endTime = performance.now()
    const renderTime = endTime - startTime
    performanceMonitor.measureRender(componentName, renderTime)
  }
}

/**
 * Measure async function execution time
 */
export async function measureAsync<T>(
  name: string,
  fn: () => Promise<T>
): Promise<T> {
  const start = performance.now()
  try {
    const result = await fn()
    const duration = performance.now() - start
    performanceMonitor.record(name, duration)
    return result
  } catch (error) {
    const duration = performance.now() - start
    performanceMonitor.record(name, duration, { error: true })
    throw error
  }
}

/**
 * Decorator for measuring function execution time
 */
export function measure(name?: string) {
  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value
    const metricName = name || `${target.constructor.name}.${propertyKey}`

    descriptor.value = async function (...args: any[]) {
      const start = performance.now()
      try {
        const result = await originalMethod.apply(this, args)
        const duration = performance.now() - start
        performanceMonitor.record(metricName, duration)
        return result
      } catch (error) {
        const duration = performance.now() - start
        performanceMonitor.record(metricName, duration, { error: true })
        throw error
      }
    }

    return descriptor
  }
}

/**
 * Log performance summary to console
 */
export function logPerformanceSummary() {
  const summary = performanceMonitor.getSummary()
  console.table(summary)
}
