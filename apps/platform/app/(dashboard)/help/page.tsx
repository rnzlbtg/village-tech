import { BookOpen, Mail, MessageCircle, FileQuestion, Video, ExternalLink } from 'lucide-react'
import Link from 'next/link'

export default function HelpPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-800">Help & Support</h1>
        <p className="text-gray-600 mt-1">
          Find answers to your questions and get assistance
        </p>
      </div>

      {/* Quick Links */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Link
          href="/help/getting-started"
          className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-lg transition-shadow"
        >
          <div className="flex items-start space-x-4">
            <div className="bg-primary-light p-3 rounded-lg">
              <BookOpen className="h-6 w-6 text-primary" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-800 mb-1">Getting Started</h3>
              <p className="text-sm text-gray-600">
                Learn the basics of using the platform
              </p>
            </div>
          </div>
        </Link>

        <Link
          href="/help/user-guides"
          className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-lg transition-shadow"
        >
          <div className="flex items-start space-x-4">
            <div className="bg-blue-100 p-3 rounded-lg">
              <FileQuestion className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-800 mb-1">User Guides</h3>
              <p className="text-sm text-gray-600">
                Step-by-step guides for common tasks
              </p>
            </div>
          </div>
        </Link>

        <Link
          href="/help/video-tutorials"
          className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-lg transition-shadow"
        >
          <div className="flex items-start space-x-4">
            <div className="bg-purple-100 p-3 rounded-lg">
              <Video className="h-6 w-6 text-purple-600" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-800 mb-1">Video Tutorials</h3>
              <p className="text-sm text-gray-600">Watch video guides and demos</p>
            </div>
          </div>
        </Link>
      </div>

      {/* FAQs */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b">
          <h2 className="text-xl font-semibold text-gray-800">
            Frequently Asked Questions
          </h2>
        </div>
        <div className="divide-y">
          <details className="p-6 cursor-pointer">
            <summary className="font-medium text-gray-800 hover:text-primary">
              How do I create a new residential community?
            </summary>
            <p className="mt-3 text-sm text-gray-600">
              Navigate to the Tenants page and click "Create New Community". Follow the
              wizard to set up your community details, gates, and initial admin user.
            </p>
          </details>

          <details className="p-6 cursor-pointer">
            <summary className="font-medium text-gray-800 hover:text-primary">
              How do I add properties and residence units?
            </summary>
            <p className="mt-3 text-sm text-gray-600">
              Go to the specific tenant's detail page, navigate to the Properties tab, and
              click "Add Property". Once created, you can add individual residence units to
              each property.
            </p>
          </details>

          <details className="p-6 cursor-pointer">
            <summary className="font-medium text-gray-800 hover:text-primary">
              How do I manage admin users for a community?
            </summary>
            <p className="mt-3 text-sm text-gray-600">
              From the tenant's detail page, go to the Admin Users tab. You can add new
              admin users with different roles (Admin Head or Admin Officer) and manage
              their permissions.
            </p>
          </details>

          <details className="p-6 cursor-pointer">
            <summary className="font-medium text-gray-800 hover:text-primary">
              What do the different user roles mean?
            </summary>
            <p className="mt-3 text-sm text-gray-600">
              <strong>Super Admin:</strong> Full platform access across all communities.
              <br />
              <strong>Admin Head:</strong> Full access within their assigned community.
              <br />
              <strong>Admin Officer:</strong> Limited administrative access within their
              community.
              <br />
              <strong>Resident:</strong> Access to resident-facing features.
              <br />
              <strong>Sentinel:</strong> Security guard access for gate management.
            </p>
          </details>

          <details className="p-6 cursor-pointer">
            <summary className="font-medium text-gray-800 hover:text-primary">
              How can I view audit logs?
            </summary>
            <p className="mt-3 text-sm text-gray-600">
              Super admins can access the Audit Logs page from the main navigation. This
              shows all system activities including user creation, data modifications, and
              deletions.
            </p>
          </details>

          <details className="p-6 cursor-pointer">
            <summary className="font-medium text-gray-800 hover:text-primary">
              How do I reset a user's password?
            </summary>
            <p className="mt-3 text-sm text-gray-600">
              Navigate to the Users page, find the user you want to reset, and click the
              "Reset Password" button. The user will receive instructions via email to set a
              new password.
            </p>
          </details>
        </div>
      </div>

      {/* Contact Support */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold text-gray-800 mb-4">
          Still need help?
        </h2>
        <p className="text-gray-600 mb-6">
          Can't find what you're looking for? Contact our support team.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <a
            href="mailto:support@example.com"
            className="flex items-center space-x-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Mail className="h-5 w-5 text-primary" />
            <div>
              <p className="font-medium text-gray-800">Email Support</p>
              <p className="text-sm text-gray-600">support@example.com</p>
            </div>
          </a>

          <a
            href="#"
            className="flex items-center space-x-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <MessageCircle className="h-5 w-5 text-primary" />
            <div>
              <p className="font-medium text-gray-800">Live Chat</p>
              <p className="text-sm text-gray-600">Available 9 AM - 5 PM</p>
            </div>
          </a>
        </div>
      </div>

      {/* External Resources */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold text-gray-800 mb-4">
          External Resources
        </h2>
        <div className="space-y-3">
          <a
            href="https://docs.example.com"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-between p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center space-x-3">
              <ExternalLink className="h-5 w-5 text-gray-400" />
              <span className="text-gray-800">Full Documentation</span>
            </div>
            <span className="text-sm text-gray-500">docs.example.com</span>
          </a>

          <a
            href="https://api.example.com/docs"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-between p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center space-x-3">
              <ExternalLink className="h-5 w-5 text-gray-400" />
              <span className="text-gray-800">API Documentation</span>
            </div>
            <span className="text-sm text-gray-500">api.example.com</span>
          </a>

          <a
            href="https://status.example.com"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-between p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center space-x-3">
              <ExternalLink className="h-5 w-5 text-gray-400" />
              <span className="text-gray-800">System Status</span>
            </div>
            <span className="text-sm text-gray-500">status.example.com</span>
          </a>
        </div>
      </div>
    </div>
  )
}
