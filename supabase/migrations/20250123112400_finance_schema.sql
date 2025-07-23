-- Location: supabase/migrations/20250123112400_finance_schema.sql
-- Schema Analysis: Fresh project - creating complete finance application schema
-- Integration Type: Complete new schema for finance application
-- Dependencies: auth.users (provided by Supabase)

-- 1. Custom Types
CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'member');
CREATE TYPE public.ipo_status AS ENUM ('upcoming', 'ongoing', 'closed', 'listed');
CREATE TYPE public.transaction_type AS ENUM ('buy', 'sell', 'dividend');
CREATE TYPE public.insight_type AS ENUM ('positive', 'negative', 'neutral', 'warning');

-- 2. Core Tables
-- User profiles table (intermediary for auth relationships)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'member'::public.user_role,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- IPO listings table
CREATE TABLE public.ipo_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL,
    company_logo TEXT,
    price_range TEXT NOT NULL,
    lot_size INTEGER NOT NULL,
    issue_size TEXT NOT NULL,
    open_date TIMESTAMPTZ NOT NULL,
    close_date TIMESTAMPTZ NOT NULL,
    listing_date TIMESTAMPTZ,
    status public.ipo_status NOT NULL DEFAULT 'upcoming'::public.ipo_status,
    category TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Portfolio holdings table
CREATE TABLE public.portfolio_holdings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    company_name TEXT NOT NULL,
    company_logo TEXT,
    symbol TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL,
    current_price DECIMAL(10,2) NOT NULL,
    purchase_date TIMESTAMPTZ NOT NULL,
    category TEXT NOT NULL,
    dividend_yield DECIMAL(5,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Portfolio transactions table
CREATE TABLE public.portfolio_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    holding_id UUID REFERENCES public.portfolio_holdings(id) ON DELETE SET NULL,
    company_name TEXT NOT NULL,
    symbol TEXT NOT NULL,
    transaction_type public.transaction_type NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    fees DECIMAL(10,2) DEFAULT 0.0,
    transaction_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Financial reports table
CREATE TABLE public.financial_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    company_name TEXT NOT NULL,
    report_period TEXT NOT NULL,
    key_metrics JSONB,
    analysis_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Financial insights table
CREATE TABLE public.financial_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID REFERENCES public.financial_reports(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    insight_type public.insight_type NOT NULL,
    value TEXT,
    trend TEXT,
    score DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User bookmarks for IPOs
CREATE TABLE public.user_ipo_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    ipo_id UUID REFERENCES public.ipo_listings(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, ipo_id)
);

-- Market news table
CREATE TABLE public.market_news (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    summary TEXT,
    author TEXT,
    source TEXT,
    image_url TEXT,
    published_at TIMESTAMPTZ NOT NULL,
    tags TEXT[],
    is_trending BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_portfolio_holdings_user_id ON public.portfolio_holdings(user_id);
CREATE INDEX idx_portfolio_transactions_user_id ON public.portfolio_transactions(user_id);
CREATE INDEX idx_portfolio_transactions_holding_id ON public.portfolio_transactions(holding_id);
CREATE INDEX idx_financial_reports_user_id ON public.financial_reports(user_id);
CREATE INDEX idx_financial_insights_report_id ON public.financial_insights(report_id);
CREATE INDEX idx_ipo_listings_status ON public.ipo_listings(status);
CREATE INDEX idx_ipo_listings_category ON public.ipo_listings(category);
CREATE INDEX idx_user_ipo_bookmarks_user_id ON public.user_ipo_bookmarks(user_id);
CREATE INDEX idx_market_news_published_at ON public.market_news(published_at);
CREATE INDEX idx_market_news_trending ON public.market_news(is_trending);

-- 4. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_holdings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_ipo_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ipo_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_news ENABLE ROW LEVEL SECURITY;

-- 5. Helper Functions
CREATE OR REPLACE FUNCTION public.is_owner(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT auth.uid() = user_uuid
$$;

CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role::TEXT = required_role
)
$$;

CREATE OR REPLACE FUNCTION public.owns_report(report_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.financial_reports fr
    WHERE fr.id = report_uuid AND fr.user_id = auth.uid()
)
$$;

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'member'::public.user_role)
  );  
  RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update timestamp function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Update triggers
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_portfolio_holdings_updated_at
    BEFORE UPDATE ON public.portfolio_holdings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_financial_reports_updated_at
    BEFORE UPDATE ON public.financial_reports
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_ipo_listings_updated_at
    BEFORE UPDATE ON public.ipo_listings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_market_news_updated_at
    BEFORE UPDATE ON public.market_news
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 6. RLS Policies
-- User profiles policies
CREATE POLICY "users_own_profile" ON public.user_profiles
FOR ALL USING (public.is_owner(id)) WITH CHECK (public.is_owner(id));

-- Portfolio policies
CREATE POLICY "users_own_portfolio" ON public.portfolio_holdings
FOR ALL USING (public.is_owner(user_id)) WITH CHECK (public.is_owner(user_id));

CREATE POLICY "users_own_transactions" ON public.portfolio_transactions
FOR ALL USING (public.is_owner(user_id)) WITH CHECK (public.is_owner(user_id));

-- Financial reports policies
CREATE POLICY "users_own_reports" ON public.financial_reports
FOR ALL USING (public.is_owner(user_id)) WITH CHECK (public.is_owner(user_id));

CREATE POLICY "users_own_insights" ON public.financial_insights
FOR SELECT USING (public.owns_report(report_id));

-- IPO bookmarks policies
CREATE POLICY "users_own_bookmarks" ON public.user_ipo_bookmarks
FOR ALL USING (public.is_owner(user_id)) WITH CHECK (public.is_owner(user_id));

-- Public read policies
CREATE POLICY "public_read_ipos" ON public.ipo_listings
FOR SELECT TO public USING (true);

CREATE POLICY "public_read_news" ON public.market_news
FOR SELECT TO public USING (true);

-- Admin policies
CREATE POLICY "admin_manage_ipos" ON public.ipo_listings
FOR ALL TO authenticated USING (public.has_role('admin')) WITH CHECK (public.has_role('admin'));

CREATE POLICY "admin_manage_news" ON public.market_news
FOR ALL TO authenticated USING (public.has_role('admin')) WITH CHECK (public.has_role('admin'));

-- 7. Sample Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    ipo1_uuid UUID := gen_random_uuid();
    ipo2_uuid UUID := gen_random_uuid();
    holding1_uuid UUID := gen_random_uuid();
    holding2_uuid UUID := gen_random_uuid();
    report1_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@financeinsight.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@financeinsight.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe", "role": "member"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Sample IPO listings
    INSERT INTO public.ipo_listings (id, company_name, company_logo, price_range, lot_size, issue_size, open_date, close_date, listing_date, status, category, description) VALUES
        (ipo1_uuid, 'TechCorp Solutions', 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop&crop=center', '₹450-500', 30, '₹2,500 Cr', now() + interval '5 days', now() + interval '8 days', now() + interval '15 days', 'upcoming'::public.ipo_status, 'Technology', 'Leading technology solutions provider'),
        (ipo2_uuid, 'FinanceGrow Ltd', 'https://images.pexels.com/photos/3483098/pexels-photo-3483098.jpeg?w=100&h=100&fit=crop&crop=center', '₹320-350', 50, '₹1,800 Cr', now() - interval '2 days', now() + interval '1 day', null, 'ongoing'::public.ipo_status, 'Finance', 'Financial services and investment solutions');

    -- Sample portfolio holdings
    INSERT INTO public.portfolio_holdings (id, user_id, company_name, company_logo, symbol, quantity, purchase_price, current_price, purchase_date, category, dividend_yield) VALUES
        (holding1_uuid, user_uuid, 'TechCorp Solutions', 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop&crop=center', 'TECH', 50, 485.0, 520.0, now() - interval '30 days', 'Technology', 2.5),
        (holding2_uuid, user_uuid, 'FinanceGrow Ltd', 'https://images.pexels.com/photos/3483098/pexels-photo-3483098.jpeg?w=100&h=100&fit=crop&crop=center', 'FGRO', 75, 335.0, 342.0, now() - interval '45 days', 'Finance', 3.2);

    -- Sample transactions
    INSERT INTO public.portfolio_transactions (user_id, holding_id, company_name, symbol, transaction_type, quantity, price, fees, transaction_date) VALUES
        (user_uuid, holding1_uuid, 'TechCorp Solutions', 'TECH', 'buy'::public.transaction_type, 50, 485.0, 15.0, now() - interval '30 days'),
        (user_uuid, holding2_uuid, 'FinanceGrow Ltd', 'FGRO', 'buy'::public.transaction_type, 75, 335.0, 20.0, now() - interval '45 days');

    -- Sample financial report
    INSERT INTO public.financial_reports (id, user_id, file_name, company_name, report_period, key_metrics) VALUES
        (report1_uuid, user_uuid, 'techcorp_q3_2024.pdf', 'TechCorp Solutions', 'Q3 2024', '{"revenue": "₹12.5B", "netIncome": "₹2.1B", "totalDebt": "₹3.2B", "cashFlow": "₹1.8B"}'::jsonb);

    -- Sample financial insights
    INSERT INTO public.financial_insights (report_id, category, title, description, insight_type, value, trend, score) VALUES
        (report1_uuid, 'Revenue', 'Strong Revenue Growth', 'Company shows consistent 15% YoY revenue growth', 'positive'::public.insight_type, '15%', 'up', 85.0),
        (report1_uuid, 'Profitability', 'Improved Margins', 'Operating margin increased from 12% to 14%', 'positive'::public.insight_type, '14%', 'up', 78.0);

    -- Sample market news
    INSERT INTO public.market_news (title, content, summary, author, source, image_url, published_at, tags, is_trending) VALUES
        ('Tech Sector Shows Strong Q4 Performance', 'Technology companies are reporting better than expected earnings for Q4 2024...', 'Tech stocks surge on strong quarterly results', 'Financial Times', 'Financial Times', 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=200&fit=crop', now() - interval '2 hours', ARRAY['technology', 'earnings', 'stocks'], true),
        ('IPO Market Heats Up in 2025', 'Several major companies are planning their public debuts in the first quarter...', 'IPO pipeline looks strong for early 2025', 'Market Watch', 'MarketWatch', 'https://images.pexels.com/photos/6801648/pexels-photo-6801648.jpeg?w=400&h=200&fit=crop', now() - interval '5 hours', ARRAY['ipo', 'market', 'investment'], false);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;