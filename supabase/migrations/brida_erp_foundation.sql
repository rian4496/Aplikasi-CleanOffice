-- =====================================================
-- BRIDA ERP FOUNDATION - COMPLETE MASTER DATA V1
-- Run this in Supabase SQL Editor
-- =====================================================

-- Enable extensions
create extension if not exists "uuid-ossp";

-- =====================================================
-- 1. MASTER ORGANISASI (Departments)
-- =====================================================
create table if not exists departments (
  id uuid primary key default uuid_generate_v4(),
  code text not null, -- e.g. '01.01'
  name text not null, -- e.g. 'Sekretariat'
  parent_id uuid references departments(id),
  description text,
  created_at timestamptz default now()
);

-- =====================================================
-- 2. MASTER PEGAWAI (SDM)
-- =====================================================
create table if not exists master_pegawai (
  id uuid primary key default uuid_generate_v4(),
  nip text unique not null,
  nama_lengkap text not null,
  email text,
  no_hp text,
  jabatan text,
  golongan text,
  unit_kerja_id uuid references departments(id),
  foto_url text,
  status text check (status in ('aktif', 'pensiun', 'pindah')) default 'aktif',
  created_at timestamptz default now()
);

-- =====================================================
-- 3. MASTER ANGGARAN (Finance)
-- =====================================================
create table if not exists master_anggaran (
  id uuid primary key default uuid_generate_v4(),
  kode_rekening text unique not null,
  uraian text not null,
  tahun_anggaran int not null,
  pagu_awal numeric default 0,
  pagu_terpakai numeric default 0,
  created_at timestamptz default now()
);

-- =====================================================
-- 4. MASTER ASET (Inventory)
-- =====================================================
create table if not exists master_assets (
  id uuid primary key default uuid_generate_v4(),
  asset_code text unique not null, -- e.g. 'AST-2024-001'
  name text not null,
  condition_id text, -- 'baik', 'rusak_ringan', 'rusak_berat'
  location_id text, -- Just a string for now, or link to a locations table if exists
  image_url text,
  purchase_date date,
  price numeric default 0,
  created_at timestamptz default now()
);

-- =====================================================
-- 5. MASTER VENDOR (Supply Chain)
-- =====================================================
create table if not exists master_vendor (
  id uuid primary key default uuid_generate_v4(),
  nama_perusahaan text not null,
  npwp text,
  kontak_person text,
  status_verifikasi text check (status_verifikasi in ('verified', 'unverified', 'blacklist')) default 'unverified',
  rating numeric default 0,
  alamat text,
  no_telepon text,
  created_at timestamptz default now()
);

-- =====================================================
-- RLS POLICIES
-- =====================================================
alter table departments enable row level security;
alter table master_pegawai enable row level security;
alter table master_anggaran enable row level security;
alter table master_assets enable row level security;
alter table master_vendor enable row level security;

-- READ: Authenticated users can read all
create policy "Read Departments" on departments for select using (auth.role() = 'authenticated');
create policy "Read Pegawai" on master_pegawai for select using (auth.role() = 'authenticated');
create policy "Read Anggaran" on master_anggaran for select using (auth.role() = 'authenticated');
create policy "Read Assets" on master_assets for select using (auth.role() = 'authenticated');
create policy "Read Vendors" on master_vendor for select using (auth.role() = 'authenticated');

-- WRITE: Authenticated users (Admin) can write
-- In production, check for specific role claims
create policy "Write Departments" on departments for all using (auth.role() = 'authenticated');
create policy "Write Pegawai" on master_pegawai for all using (auth.role() = 'authenticated');
create policy "Write Anggaran" on master_anggaran for all using (auth.role() = 'authenticated');
create policy "Write Assets" on master_assets for all using (auth.role() = 'authenticated');
create policy "Write Vendors" on master_vendor for all using (auth.role() = 'authenticated');
