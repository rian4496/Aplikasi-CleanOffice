-- Migration: Master Data Schema
-- Description: Creates tables for Organizations, Employees, Budgets, Vendors, and Asset Categories with RLS policies.

-- 1. Master Organizations (Departments/Bidang)
create table if not exists public.master_organizations (
    id uuid not null default gen_random_uuid(),
    code text not null,
    name text not null,
    parent_id uuid references public.master_organizations(id),
    type text check (type in ('dinas', 'bidang', 'seksi', 'upt')),
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    primary key (id)
);

-- 2. Master Employees (Pegawai)
create table if not exists public.master_employees (
    id uuid not null default gen_random_uuid(),
    nip text unique not null,
    full_name text not null,
    email text,
    phone text,
    position text,
    organization_id uuid references public.master_organizations(id),
    status text default 'active' check (status in ('active', 'inactive', 'retired')),
    photo_url text,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    primary key (id)
);

-- 3. Master Budgets (Anggaran)
create table if not exists public.master_budgets (
    id uuid not null default gen_random_uuid(),
    fiscal_year int not null, -- e.g., 2024
    source_name text not null, -- e.g., "APBD Murni", "DAK"
    total_amount numeric(15, 2) not null default 0,
    remaining_amount numeric(15, 2) not null default 0,
    status text default 'active' check (status in ('active', 'closed')),
    description text,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    primary key (id)
);

-- 4. Master Vendors (Penyedia)
create table if not exists public.master_vendors (
    id uuid not null default gen_random_uuid(),
    name text not null,
    address text,
    contact_person text,
    phone text,
    email text,
    tax_id text, -- NPWP
    bank_account text,
    bank_name text,
    status text default 'active',
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    primary key (id)
);

-- 5. Master Asset Categories (Kategori Aset)
create table if not exists public.master_asset_categories (
    id uuid not null default gen_random_uuid(),
    code text unique not null,
    name text not null,
    description text,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    primary key (id)
);

-- Enable RLS
alter table public.master_organizations enable row level security;
alter table public.master_employees enable row level security;
alter table public.master_budgets enable row level security;
alter table public.master_vendors enable row level security;
alter table public.master_asset_categories enable row level security;

-- Policies (Allow Read for Authenticated, Write for Admin Only - simplified for MVP to Allow All Auth)
create policy "Enable read access for authenticated users" on public.master_organizations for select using (auth.role() = 'authenticated');
create policy "Enable insert for authenticated users" on public.master_organizations for insert with check (auth.role() = 'authenticated');
create policy "Enable update for authenticated users" on public.master_organizations for update using (auth.role() = 'authenticated');
create policy "Enable delete for authenticated users" on public.master_organizations for delete using (auth.role() = 'authenticated');

create policy "Enable read access for authenticated users" on public.master_employees for select using (auth.role() = 'authenticated');
create policy "Enable insert for authenticated users" on public.master_employees for insert with check (auth.role() = 'authenticated');
create policy "Enable update for authenticated users" on public.master_employees for update using (auth.role() = 'authenticated');
create policy "Enable delete for authenticated users" on public.master_employees for delete using (auth.role() = 'authenticated');

create policy "Enable read access for authenticated users" on public.master_budgets for select using (auth.role() = 'authenticated');
create policy "Enable insert for authenticated users" on public.master_budgets for insert with check (auth.role() = 'authenticated');
create policy "Enable update for authenticated users" on public.master_budgets for update using (auth.role() = 'authenticated');
create policy "Enable delete for authenticated users" on public.master_budgets for delete using (auth.role() = 'authenticated');

create policy "Enable read access for authenticated users" on public.master_vendors for select using (auth.role() = 'authenticated');
create policy "Enable insert for authenticated users" on public.master_vendors for insert with check (auth.role() = 'authenticated');
create policy "Enable update for authenticated users" on public.master_vendors for update using (auth.role() = 'authenticated');
create policy "Enable delete for authenticated users" on public.master_vendors for delete using (auth.role() = 'authenticated');

create policy "Enable read access for authenticated users" on public.master_asset_categories for select using (auth.role() = 'authenticated');
create policy "Enable insert for authenticated users" on public.master_asset_categories for insert with check (auth.role() = 'authenticated');
create policy "Enable update for authenticated users" on public.master_asset_categories for update using (auth.role() = 'authenticated');
create policy "Enable delete for authenticated users" on public.master_asset_categories for delete using (auth.role() = 'authenticated');
