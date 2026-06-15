-- =====================================================================
-- RLS POLICIES FOR CRM AUTOMOTIZADO
-- TABLES: profiles, companies, leads, deals, tasks, activities
-- =====================================================================

-- 1. Enable Row Level Security (RLS) on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies to prevent conflicts
DROP POLICY IF EXISTS "Allow public read access to profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow admin full access to profiles" ON public.profiles;

DROP POLICY IF EXISTS "Allow team members to view companies" ON public.companies;
DROP POLICY IF EXISTS "Allow admin to manage companies" ON public.companies;

DROP POLICY IF EXISTS "Sellers can view own leads" ON public.leads;
DROP POLICY IF EXISTS "Sellers can insert own leads" ON public.leads;
DROP POLICY IF EXISTS "Sellers can update own leads" ON public.leads;
DROP POLICY IF EXISTS "Sellers can delete own leads" ON public.leads;

DROP POLICY IF EXISTS "Sellers can view own deals" ON public.deals;
DROP POLICY IF EXISTS "Sellers can insert own deals" ON public.deals;
DROP POLICY IF EXISTS "Sellers can update own deals" ON public.deals;
DROP POLICY IF EXISTS "Sellers can delete own deals" ON public.deals;

DROP POLICY IF EXISTS "Assigned users can view tasks" ON public.tasks;
DROP POLICY IF EXISTS "Assigned users can update tasks" ON public.tasks;
DROP POLICY IF EXISTS "Admin can manage tasks" ON public.tasks;

DROP POLICY IF EXISTS "Team members can view activities" ON public.activities;
DROP POLICY IF EXISTS "Team members can insert activities" ON public.activities;
DROP POLICY IF EXISTS "Admin can manage activities" ON public.activities;

-- 3. Security Definer Helper Function
-- Using SECURITY DEFINER bypasses RLS recursion issues when checking user roles from the profiles table.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- TABLE: profiles
-- =====================================================================
CREATE POLICY "Allow public read access to profiles" 
  ON public.profiles FOR SELECT 
  TO authenticated 
  USING (true);

CREATE POLICY "Allow users to update their own profile" 
  ON public.profiles FOR UPDATE 
  TO authenticated 
  USING (auth.uid() = id) 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Allow admin full access to profiles" 
  ON public.profiles FOR ALL 
  TO authenticated 
  USING (public.is_admin());

-- =====================================================================
-- TABLE: companies
-- =====================================================================
CREATE POLICY "Allow team members to view companies" 
  ON public.companies FOR SELECT 
  TO authenticated 
  USING (true);

CREATE POLICY "Allow admin to manage companies" 
  ON public.companies FOR ALL 
  TO authenticated 
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- =====================================================================
-- TABLE: leads
-- =====================================================================
CREATE POLICY "Sellers can view own leads" 
  ON public.leads FOR SELECT 
  TO authenticated 
  USING (owner_id = auth.uid() OR public.is_admin());

CREATE POLICY "Sellers can insert own leads" 
  ON public.leads FOR INSERT 
  TO authenticated 
  WITH CHECK (owner_id = auth.uid() OR public.is_admin());

CREATE POLICY "Sellers can update own leads" 
  ON public.leads FOR UPDATE 
  TO authenticated 
  USING (owner_id = auth.uid() OR public.is_admin())
  WITH CHECK (owner_id = auth.uid() OR public.is_admin());

CREATE POLICY "Sellers can delete own leads" 
  ON public.leads FOR DELETE 
  TO authenticated 
  USING (owner_id = auth.uid() OR public.is_admin());

-- =====================================================================
-- TABLE: deals
-- =====================================================================
CREATE POLICY "Sellers can view own deals" 
  ON public.deals FOR SELECT 
  TO authenticated 
  USING (owner_id = auth.uid() OR public.is_admin());

CREATE POLICY "Sellers can insert own deals" 
  ON public.deals FOR INSERT 
  TO authenticated 
  WITH CHECK (owner_id = auth.uid() OR public.is_admin());

CREATE POLICY "Sellers can update own deals" 
  ON public.deals FOR UPDATE 
  TO authenticated 
  USING (owner_id = auth.uid() OR public.is_admin())
  WITH CHECK (owner_id = auth.uid() OR public.is_admin());

CREATE POLICY "Sellers can delete own deals" 
  ON public.deals FOR DELETE 
  TO authenticated 
  USING (owner_id = auth.uid() OR public.is_admin());

-- =====================================================================
-- TABLE: tasks
-- =====================================================================
CREATE POLICY "Assigned users can view tasks" 
  ON public.tasks FOR SELECT 
  TO authenticated 
  USING (assigned_to = auth.uid() OR public.is_admin());

CREATE POLICY "Assigned users can update tasks" 
  ON public.tasks FOR UPDATE 
  TO authenticated 
  USING (assigned_to = auth.uid() OR public.is_admin())
  WITH CHECK (assigned_to = auth.uid() OR public.is_admin());

CREATE POLICY "Admin can manage tasks" 
  ON public.tasks FOR ALL 
  TO authenticated 
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- =====================================================================
-- TABLE: activities
-- =====================================================================
CREATE POLICY "Team members can view activities" 
  ON public.activities FOR SELECT 
  TO authenticated 
  USING (true);

CREATE POLICY "Team members can insert activities" 
  ON public.activities FOR INSERT 
  TO authenticated 
  WITH CHECK (true);

CREATE POLICY "Admin can manage activities" 
  ON public.activities FOR ALL 
  TO authenticated 
  USING (public.is_admin())
  WITH CHECK (public.is_admin());
