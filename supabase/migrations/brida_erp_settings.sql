-- SETTINGS MODULE MIGRATION
-- Agency Profile, Audit Logs, and User Profiles (if not exists)

-- 1. Agency Profiles (Single Row Table)
CREATE TABLE IF NOT EXISTS agency_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    short_name TEXT,
    address TEXT,
    phone TEXT,
    email TEXT,
    website TEXT,
    logo_url TEXT,
    city TEXT,
    
    -- JSONB for Signers array (simplifies management for now)
    signers JSONB DEFAULT '[]'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS
ALTER TABLE agency_profiles ENABLE ROW LEVEL SECURITY;

-- Allow read access to authenticated users
CREATE POLICY "Allow read access for authenticated users" ON agency_profiles
    FOR SELECT USING (auth.role() = 'authenticated');

-- Allow update access only to admins (for now all authenticated users)
CREATE POLICY "Allow update access for authenticated users" ON agency_profiles
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Allow insert if empty
CREATE POLICY "Allow insert if empty" ON agency_profiles
    FOR INSERT WITH CHECK (true);


-- 2. Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL, -- 'create', 'update', 'delete', 'login'
    module TEXT NOT NULL, -- 'asset', 'procurement', 'settings'
    target_id TEXT, -- ID of the object impacted
    details TEXT, -- Simple description
    
    -- Metadata (JSONB for future proofing)
    metadata JSONB, 
    
    ip_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for admins" ON audit_logs
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow insert for authenticated users" ON audit_logs
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');


-- 3. Public Profiles (Sync with Auth)
-- This usually exists, but ensuring it has necessary fields
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  role TEXT DEFAULT 'employee', -- 'admin', 'employee', 'technician'
  department_id TEXT,
  nip TEXT,
  avatar_url TEXT,
  status TEXT DEFAULT 'active', -- 'active', 'inactive'
  
  updated_at TIMESTAMP WITH TIME ZONE
);

-- RLS for Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);
