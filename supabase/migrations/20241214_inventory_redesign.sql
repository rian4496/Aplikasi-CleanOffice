-- Migration: 20241214_inventory_redesign.sql
-- Description: Adds detailed tracking for Inventory (Consumables)

-- 1. ENUMS (If not already exists, handled gracefully in application logic using strings for flexibility)
-- We will use TEXT constraints for flexibility.

-- 2. STOCK MOVEMENTS (Riwayat Transaksi)
CREATE TABLE IF NOT EXISTS public.stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES public.inventory_items(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('IN', 'OUT', 'ADJUST')), -- IN=Masuk, OUT=Keluar, ADJUST=Opname/Manual
    quantity INTEGER NOT NULL, -- Positive for IN, Negative for OUT usually, but we store delta.
    reference_id TEXT, -- PO Number, Request ID, or Opname ID
    notes TEXT,
    performed_by UUID NULL REFERENCES auth.users(id),
    performed_by_name TEXT, -- Cache name for display
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.stock_movements ENABLE ROW LEVEL SECURITY;

-- Policies for stock_movements
CREATE POLICY "Enable read access for authenticated users" 
ON public.stock_movements FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Enable insert for authenticated users" 
ON public.stock_movements FOR INSERT 
TO authenticated 
WITH CHECK (true);


-- 3. STOCK OPNAMES (Stock Taking / Audit)
CREATE TABLE IF NOT EXISTS public.stock_opnames (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opname_number TEXT NOT NULL, -- e.g., 'OPN-2024-12-001'
    status TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'COMPLETED', 'CANCELLED')),
    notes TEXT,
    performed_by UUID NOT NULL REFERENCES auth.users(id),
    performed_by_name TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- Enable RLS
ALTER TABLE public.stock_opnames ENABLE ROW LEVEL SECURITY;

-- Policies for stock_opnames
CREATE POLICY "Enable all access for admin users" 
ON public.stock_opnames FOR ALL 
TO authenticated 
USING (true); -- Ideally restrict to admin role, but keeping open for now (MVP)

-- 4. STOCK OPNAME ITEMS (Detail per item in an opname)
CREATE TABLE IF NOT EXISTS public.stock_opname_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opname_id UUID NOT NULL REFERENCES public.stock_opnames(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES public.inventory_items(id) ON DELETE CASCADE,
    system_stock INTEGER NOT NULL, -- Snapshot of stock when opname started
    actual_stock INTEGER, -- Inputted by user
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.stock_opname_items ENABLE ROW LEVEL SECURITY;

-- Policies for stock_opname_items
CREATE POLICY "Enable all access for admin users" 
ON public.stock_opname_items FOR ALL 
TO authenticated 
USING (true);

-- 5. FUNCTION to Auto-Update Inventory Stock on Movement Insert
-- (Optional: Can be handled in app logic, but DB trigger is safer)
CREATE OR REPLACE FUNCTION public.handle_stock_movement()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.inventory_items
    SET 
        current_stock = current_stock + NEW.quantity,
        updated_at = NOW()
    WHERE id = NEW.item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
DROP TRIGGER IF EXISTS on_stock_movement_insert ON public.stock_movements;
CREATE TRIGGER on_stock_movement_insert
AFTER INSERT ON public.stock_movements
FOR EACH ROW
EXECUTE FUNCTION public.handle_stock_movement();
