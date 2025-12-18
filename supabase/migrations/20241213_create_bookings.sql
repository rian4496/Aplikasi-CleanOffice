-- Create transactions_bookings table
create table if not exists public.transactions_bookings (
  id uuid default gen_random_uuid() primary key,
  asset_id uuid not null references public.master_assets(id),
  employee_id uuid references auth.users(id), -- Or text if referencing external employee table
  department text,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone not null,
  purpose text not null,
  status text not null default 'pending', -- pending, approved, active, completed, rejected, cancelled
  rejection_reason text,
  proof_of_return text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable RLS for transactions_bookings
alter table public.transactions_bookings enable row level security;

create policy "Enable all for authenticated users"
  on public.transactions_bookings for all
  to authenticated
  using (true)
  with check (true);
