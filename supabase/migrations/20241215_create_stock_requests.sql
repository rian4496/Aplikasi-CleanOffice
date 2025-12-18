-- Migration: 20241215_create_stock_requests.sql
-- Description: Adds table for Stock Requests (Employee requests items from Admin)

-- 1. STOCK REQUESTS TABLE
CREATE TABLE IF NOT EXISTS public.stock_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES public.inventory_items(id) ON DELETE CASCADE,
    item_name TEXT, -- Cache for display
    requester_id UUID NOT NULL REFERENCES auth.users(id),
    requester_name TEXT, -- Cache for display
    requested_quantity INTEGER NOT NULL CHECK (requested_quantity > 0),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'fulfilled', 'cancelled')),
    notes TEXT,
    
    -- Admin Approval / Fulfillment info
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES auth.users(id),
    approved_by_name TEXT,
    
    fulfilled_at TIMESTAMP WITH TIME ZONE,
    fulfilled_by UUID REFERENCES auth.users(id),
    fulfilled_by_name TEXT,
    
    rejection_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.stock_requests ENABLE ROW LEVEL SECURITY;

-- Policies
-- 1. Employees can view their own requests
CREATE POLICY "Users can view own requests" 
ON public.stock_requests FOR SELECT 
TO authenticated 
USING (auth.uid() = requester_id OR 
       EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));

-- 2. Employees can insert their own requests
CREATE POLICY "Users can create requests" 
ON public.stock_requests FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = requester_id);

-- 3. Admins can update requests (approve/reject/fulfill)
CREATE POLICY "Admins can update requests" 
ON public.stock_requests FOR UPDATE
TO authenticated 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));
