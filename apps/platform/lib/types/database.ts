// Database types - Generated from Supabase schema
// In production, run: npx supabase gen types typescript --project-id <project-id> > lib/types/database.ts

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      tenants: {
        Row: {
          id: string
          name: string
          address: string
          city: string | null
          state: string | null
          country: string
          postal_code: string | null
          contact_name: string | null
          contact_email: string | null
          contact_phone: string | null
          subscription_status: 'active' | 'inactive' | 'suspended' | 'trial'
          subscription_plan: string | null
          max_users: number | null
          max_residences: number | null
          settings: Json
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          address: string
          city?: string | null
          state?: string | null
          country?: string
          postal_code?: string | null
          contact_name?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          subscription_status?: 'active' | 'inactive' | 'suspended' | 'trial'
          subscription_plan?: string | null
          max_users?: number | null
          max_residences?: number | null
          settings?: Json
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          address?: string
          city?: string | null
          state?: string | null
          country?: string
          postal_code?: string | null
          contact_name?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          subscription_status?: 'active' | 'inactive' | 'suspended' | 'trial'
          subscription_plan?: string | null
          max_users?: number | null
          max_residences?: number | null
          settings?: Json
          created_at?: string
          updated_at?: string
        }
      }
      properties: {
        Row: {
          id: string
          tenant_id: string
          name: string
          property_type: 'building' | 'lot' | 'section' | 'phase'
          address: string | null
          description: string | null
          total_units: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          tenant_id: string
          name: string
          property_type?: 'building' | 'lot' | 'section' | 'phase'
          address?: string | null
          description?: string | null
          total_units?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          tenant_id?: string
          name?: string
          property_type?: 'building' | 'lot' | 'section' | 'phase'
          address?: string | null
          description?: string | null
          total_units?: number
          created_at?: string
          updated_at?: string
        }
      }
      residence_units: {
        Row: {
          id: string
          tenant_id: string
          property_id: string
          unit_number: string
          unit_type: 'residential' | 'commercial' | 'mixed'
          floor_number: number | null
          building_section: string | null
          lot_number: string | null
          address: string | null
          status: 'available' | 'occupied' | 'reserved' | 'maintenance'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          tenant_id: string
          property_id: string
          unit_number: string
          unit_type?: 'residential' | 'commercial' | 'mixed'
          floor_number?: number | null
          building_section?: string | null
          lot_number?: string | null
          address?: string | null
          status?: 'available' | 'occupied' | 'reserved' | 'maintenance'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          tenant_id?: string
          property_id?: string
          unit_number?: string
          unit_type?: 'residential' | 'commercial' | 'mixed'
          floor_number?: number | null
          building_section?: string | null
          lot_number?: string | null
          address?: string | null
          status?: 'available' | 'occupied' | 'reserved' | 'maintenance'
          created_at?: string
          updated_at?: string
        }
      }
      gates: {
        Row: {
          id: string
          tenant_id: string
          name: string
          location: string | null
          description: string | null
          gate_type: 'main' | 'pedestrian' | 'service' | 'emergency'
          operational_status: 'active' | 'inactive' | 'maintenance'
          equipment_config: Json
          has_rfid_reader: boolean
          has_barrier: boolean
          operating_hours: Json | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          tenant_id: string
          name: string
          location?: string | null
          description?: string | null
          gate_type?: 'main' | 'pedestrian' | 'service' | 'emergency'
          operational_status?: 'active' | 'inactive' | 'maintenance'
          equipment_config?: Json
          has_rfid_reader?: boolean
          has_barrier?: boolean
          operating_hours?: Json | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          tenant_id?: string
          name?: string
          location?: string | null
          description?: string | null
          gate_type?: 'main' | 'pedestrian' | 'service' | 'emergency'
          operational_status?: 'active' | 'inactive' | 'maintenance'
          equipment_config?: Json
          has_rfid_reader?: boolean
          has_barrier?: boolean
          operating_hours?: Json | null
          created_at?: string
          updated_at?: string
        }
      }
    }
  }
}
