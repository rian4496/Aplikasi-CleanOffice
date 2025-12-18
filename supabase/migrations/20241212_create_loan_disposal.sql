-- Create transactions_disposal table
create table if not exists public.transactions_disposal (
  id uuid default gen_random_uuid() primary key,
  code text not null default '',
  asset_id uuid not null references public.master_assets(id),
  proposer_id uuid references auth.users(id),
  reason text not null,
  description text,
  estimated_value numeric default 0,
  status text not null default 'draft', -- draft, verified, approved, executed, disposed
  approval_date timestamp with time zone,
  approved_by uuid references auth.users(id),
  final_disposal_type text, -- auction, grant, destruction
  final_value numeric,
  execution_date timestamp with time zone,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable RLS for transactions_disposal
alter table public.transactions_disposal enable row level security;

create policy "Enable all for authenticated users"
  on public.transactions_disposal for all
  to authenticated
  using (true)
  with check (true);


-- Create transactions_loans table
create table if not exists public.transactions_loans (
  id uuid default gen_random_uuid() primary key,
  request_number text not null,
  borrower_name text not null,
  borrower_address text,
  borrower_contact text,
  asset_id uuid not null references public.master_assets(id),
  start_date timestamp with time zone not null,
  duration_years integer not null default 1,
  end_date timestamp with time zone not null,
  status text not null default 'draft', -- draft, submitted, verified, approved, active, returned
  rejection_reason text,
  application_letter_doc text,
  agreement_doc text,
  bast_handover_doc text,
  bast_return_doc text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable RLS for transactions_loans
alter table public.transactions_loans enable row level security;

create policy "Enable all for authenticated users"
  on public.transactions_loans for all
  to authenticated
  using (true)
  with check (true);
