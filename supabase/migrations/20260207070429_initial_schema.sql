-- =============================================================================
-- KASBON POS - Initial Schema Migration
-- =============================================================================
-- Converts SQLite offline schema to PostgreSQL with multi-tenant RLS.
-- Tables: user_profiles, shop_settings, categories, products,
--         transactions, transaction_items
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. HELPER FUNCTIONS
-- ---------------------------------------------------------------------------

-- Auto-update updated_at on row modification
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Auto-create user_profiles row when a new auth user is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, full_name, phone, tier)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'phone', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'tier', 'free')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 2. TABLES (in FK dependency order)
-- ---------------------------------------------------------------------------

-- 2a. user_profiles (NEW - not in SQLite)
CREATE TABLE public.user_profiles (
  id                       UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name                TEXT NOT NULL DEFAULT '',
  phone                    TEXT DEFAULT '',
  tier                     TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'premium')),
  subscription_expires_at  TIMESTAMPTZ,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2b. shop_settings
CREATE TABLE public.shop_settings (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                  TEXT NOT NULL,
  address               TEXT,
  phone                 TEXT,
  logo_url              TEXT,
  receipt_header         TEXT,
  receipt_footer         TEXT,
  currency              TEXT NOT NULL DEFAULT 'IDR',
  low_stock_threshold   INTEGER NOT NULL DEFAULT 5,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id)
);

-- 2c. categories
CREATE TABLE public.categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  color       TEXT DEFAULT '#FF6B35',
  icon        TEXT DEFAULT 'category',
  sort_order  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, name)
);

-- 2d. products
CREATE TABLE public.products (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id    UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  sku            TEXT NOT NULL,
  name           TEXT NOT NULL,
  description    TEXT,
  barcode        TEXT,
  cost_price     DECIMAL(12,2) NOT NULL DEFAULT 0,
  selling_price  DECIMAL(12,2) NOT NULL,
  stock          INTEGER NOT NULL DEFAULT 0,
  min_stock      INTEGER DEFAULT 5,
  unit           TEXT DEFAULT 'pcs',
  image_url      TEXT,
  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, sku)
);

-- 2e. transactions
CREATE TABLE public.transactions (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_number    TEXT NOT NULL,
  customer_name         TEXT,
  subtotal              DECIMAL(12,2) NOT NULL,
  discount_amount       DECIMAL(12,2) DEFAULT 0,
  discount_percentage   DECIMAL(5,2) DEFAULT 0,
  tax_amount            DECIMAL(12,2) DEFAULT 0,
  total                 DECIMAL(12,2) NOT NULL,
  payment_method        TEXT NOT NULL DEFAULT 'cash'
                          CHECK (payment_method IN ('cash', 'transfer', 'qris', 'debt')),
  payment_status        TEXT NOT NULL DEFAULT 'paid'
                          CHECK (payment_status IN ('paid', 'debt')),
  cash_received         DECIMAL(12,2),
  cash_change           DECIMAL(12,2),
  notes                 TEXT,
  cashier_name          TEXT,
  transaction_date      TIMESTAMPTZ NOT NULL,
  debt_paid_at          TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, transaction_number)
);

-- 2f. transaction_items
CREATE TABLE public.transaction_items (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_id   UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
  product_id       UUID REFERENCES public.products(id) ON DELETE SET NULL,
  product_name     TEXT NOT NULL,
  product_sku      TEXT NOT NULL,
  quantity         INTEGER NOT NULL,
  cost_price       DECIMAL(12,2) NOT NULL,
  selling_price    DECIMAL(12,2) NOT NULL,
  discount_amount  DECIMAL(12,2) DEFAULT 0,
  subtotal         DECIMAL(12,2) NOT NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- 3. INDEXES
-- ---------------------------------------------------------------------------

-- categories
CREATE INDEX idx_categories_user           ON public.categories (user_id);
CREATE INDEX idx_categories_user_sort      ON public.categories (user_id, sort_order);

-- products
CREATE INDEX idx_products_user             ON public.products (user_id);
CREATE INDEX idx_products_user_name        ON public.products (user_id, name);
CREATE INDEX idx_products_user_category    ON public.products (user_id, category_id);
CREATE INDEX idx_products_user_active      ON public.products (user_id, is_active);
CREATE UNIQUE INDEX idx_products_user_barcode
  ON public.products (user_id, barcode) WHERE barcode IS NOT NULL;

-- transactions
CREATE INDEX idx_transactions_user              ON public.transactions (user_id);
CREATE INDEX idx_transactions_user_date         ON public.transactions (user_id, transaction_date);
CREATE INDEX idx_transactions_user_status       ON public.transactions (user_id, payment_status);
CREATE INDEX idx_transactions_user_customer     ON public.transactions (user_id, customer_name);

-- transaction_items
CREATE INDEX idx_txn_items_user            ON public.transaction_items (user_id);
CREATE INDEX idx_txn_items_transaction     ON public.transaction_items (transaction_id);
CREATE INDEX idx_txn_items_product         ON public.transaction_items (product_id);

-- ---------------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY
-- ---------------------------------------------------------------------------

-- Enable RLS on all tables
ALTER TABLE public.user_profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_settings     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_items ENABLE ROW LEVEL SECURITY;

-- 4a. user_profiles: users can only access their own profile
CREATE POLICY "Users can view own profile"
  ON public.user_profiles FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  USING (id = auth.uid());

CREATE POLICY "Users can insert own profile"
  ON public.user_profiles FOR INSERT
  WITH CHECK (id = auth.uid());

-- 4b. shop_settings: users can only access their own shop
CREATE POLICY "Users can view own shop settings"
  ON public.shop_settings FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own shop settings"
  ON public.shop_settings FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own shop settings"
  ON public.shop_settings FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own shop settings"
  ON public.shop_settings FOR DELETE
  USING (user_id = auth.uid());

-- 4c. categories: users can only access their own categories
CREATE POLICY "Users can view own categories"
  ON public.categories FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own categories"
  ON public.categories FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own categories"
  ON public.categories FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own categories"
  ON public.categories FOR DELETE
  USING (user_id = auth.uid());

-- 4d. products: users can only access their own products
CREATE POLICY "Users can view own products"
  ON public.products FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own products"
  ON public.products FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own products"
  ON public.products FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own products"
  ON public.products FOR DELETE
  USING (user_id = auth.uid());

-- 4e. transactions: users can only access their own transactions
CREATE POLICY "Users can view own transactions"
  ON public.transactions FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own transactions"
  ON public.transactions FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own transactions"
  ON public.transactions FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own transactions"
  ON public.transactions FOR DELETE
  USING (user_id = auth.uid());

-- 4f. transaction_items: users can only access their own items
CREATE POLICY "Users can view own transaction items"
  ON public.transaction_items FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own transaction items"
  ON public.transaction_items FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own transaction items"
  ON public.transaction_items FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own transaction items"
  ON public.transaction_items FOR DELETE
  USING (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- 5. TRIGGERS
-- ---------------------------------------------------------------------------

-- updated_at triggers (all tables that have updated_at)
CREATE TRIGGER set_updated_at_user_profiles
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_shop_settings
  BEFORE UPDATE ON public.shop_settings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_categories
  BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_products
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_transactions
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auth trigger: auto-create user_profiles on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
