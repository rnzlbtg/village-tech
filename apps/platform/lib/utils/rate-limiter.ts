// Simple in-memory rate limiter
// For production, consider using Redis or a dedicated rate limiting service

interface RateLimitEntry {
  count: number
  resetTime: number
}

class RateLimiter {
  private requests: Map<string, RateLimitEntry> = new Map()
  private maxRequests: number
  private windowMs: number

  constructor(maxRequests: number = 10, windowMs: number = 60000) {
    this.maxRequests = maxRequests
    this.windowMs = windowMs

    // Clean up expired entries every minute
    setInterval(() => this.cleanup(), 60000)
  }

  check(identifier: string): { allowed: boolean; remaining: number; resetTime: number } {
    const now = Date.now()
    const entry = this.requests.get(identifier)

    if (!entry || now > entry.resetTime) {
      // New window
      const resetTime = now + this.windowMs
      this.requests.set(identifier, { count: 1, resetTime })
      return { allowed: true, remaining: this.maxRequests - 1, resetTime }
    }

    if (entry.count >= this.maxRequests) {
      // Rate limit exceeded
      return { allowed: false, remaining: 0, resetTime: entry.resetTime }
    }

    // Increment count
    entry.count++
    this.requests.set(identifier, entry)
    return { allowed: true, remaining: this.maxRequests - entry.count, resetTime: entry.resetTime }
  }

  reset(identifier: string): void {
    this.requests.delete(identifier)
  }

  private cleanup(): void {
    const now = Date.now()
    for (const [key, entry] of this.requests.entries()) {
      if (now > entry.resetTime) {
        this.requests.delete(key)
      }
    }
  }

  getStats(): { totalKeys: number } {
    return { totalKeys: this.requests.size }
  }
}

// Singleton instance for bulk import (10 requests per minute per user)
export const bulkImportLimiter = new RateLimiter(10, 60000)

// Singleton instance for general API (100 requests per minute per user)
export const apiLimiter = new RateLimiter(100, 60000)

// Helper function to get client identifier (IP or user ID)
export function getClientIdentifier(request: Request, userId?: string): string {
  if (userId) return `user:${userId}`

  // Try to get IP from headers (works with most proxies/load balancers)
  const forwarded = request.headers.get('x-forwarded-for')
  const realIp = request.headers.get('x-real-ip')
  const ip = forwarded?.split(',')[0] || realIp || 'unknown'

  return `ip:${ip}`
}
