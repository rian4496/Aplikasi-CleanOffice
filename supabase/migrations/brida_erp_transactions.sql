-- =====================================================
-- BRIDA ERP PHASE 2: TRANSACTIONS
-- Run this AFTER brida_erp_foundation.sql
-- =====================================================

-- =====================================================
-- 1. PROCUREMENT (PENGADAAN)
-- =====================================================

-- 1A. Procurement Header
create table if not exists transactions_procurement (
  id uuid primary key default uuid_generate_v4(),
  code text unique not null, -- e.g. 'REQ-2025-001'
  request_date date not null default CURRENT_DATE,
  requester_id uuid references master_pegawai(id), -- Who asked?
  
  -- Status Flow: pending -> approved_admin -> approved_head -> po_generated -> completed -> rejected
  status text check (status in ('pending', 'approved_admin', 'approved_head', 'po_generated', 'completed', 'rejected')) default 'pending',
  
  description text,
  total_estimated_budget numeric default 0,
  
  -- Linked PO (filled later)
  po_number text,
  vendor_id uuid references master_vendor(id),
  
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 1B. Procurement Items
create table if not exists transaction_procurement_items (
  id uuid primary key default uuid_generate_v4(),
  procurement_id uuid references transactions_procurement(id) on delete cascade,
  
  item_name text not null,
  quantity int not null default 1,
  unit_price_estimate numeric default 0,
  total_price_estimate numeric generated always as (quantity * unit_price_estimate) stored,
  
  -- Link to Anggaran (Source of Funds)
  budget_id uuid references master_anggaran(id),
  
  created_at timestamptz default now()
);

-- =====================================================
-- 2. MAINTENANCE (PERBAIKAN)
-- =====================================================

create table if not exists transactions_maintenance (
  id uuid primary key default uuid_generate_v4(),
  code text unique, -- e.g. MT-2025-001
  
  -- The Asset being fixed
  asset_id uuid references master_assets(id),
  
  -- Who reported it?
  reporter_id uuid references master_pegawai(id),
  
  -- Details
  issue_title text not null,
  issue_description text,
  priority text check (priority in ('low', 'normal', 'high', 'urgent')) default 'normal',
  
  -- Assignment
  assigned_technician_id uuid references master_pegawai(id), -- Internal Staff
  external_vendor_id uuid references master_vendor(id), -- If outsourced
  
  -- Workflow: reported -> assigned -> in_progress -> pending_parts -> completed -> verified
  status text check (status in ('reported', 'assigned', 'in_progress', 'pending_parts', 'completed', 'verified')) default 'reported',
  
  -- Fulfillment
  scheduled_date timestamptz,
  completion_date timestamptz,
  notes_technician text,
  cost_material numeric default 0,
  cost_labor numeric default 0,
  total_cost numeric generated always as (cost_material + cost_labor) stored,
  
  proof_photo_before text,
  proof_photo_after text,
  
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- =====================================================
-- RLS POLICIES
-- =====================================================

alter table transactions_procurement enable row level security;
alter table transaction_procurement_items enable row level security;
alter table transactions_maintenance enable row level security;

-- Simple Policies for Web Admin (Authenticated = All Access for now)
create policy "Admin Ops Procurement" on transactions_procurement for all using (auth.role() = 'authenticated');
create policy "Admin Ops Procurement Items" on transaction_procurement_items for all using (auth.role() = 'authenticated');
create policy "Admin Ops Maintenance" on transactions_maintenance for all using (auth.role() = 'authenticated');
