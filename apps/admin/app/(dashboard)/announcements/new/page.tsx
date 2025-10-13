import { AnnouncementForm } from '@/components/announcements/AnnouncementForm'

export const metadata = {
  title: 'Create Announcement | Admin',
  description: 'Create a new community announcement',
}

export default function NewAnnouncementPage() {
  return (
    <div className="container mx-auto py-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold">Create Announcement</h1>
        <p className="text-gray-600 mt-1">Send a message to residents and staff</p>
      </div>

      <div className="max-w-3xl">
        <AnnouncementForm />
      </div>
    </div>
  )
}
