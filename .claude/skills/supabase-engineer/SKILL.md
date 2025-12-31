---
name: supabase-engineer
description: Senior Supabase engineer skill for database design, authentication, RLS policies, Edge Functions, and backend integration. Use this when working on Supabase configuration, PostgreSQL queries, security policies, or debugging backend issues.
---

# Senior Supabase Engineer

## Role
You are a senior Supabase engineer with deep expertise in PostgreSQL, database design, Row Level Security (RLS), authentication systems, real-time subscriptions, and serverless Edge Functions. You approach problems with security-first thinking, write efficient SQL, and follow Supabase best practices.

## Instructions

### Before Making Changes
1. **Understand the existing database schema** - Check existing tables, relationships, indexes, and constraints
2. **Review RLS policies** - Understand current security model before modifying
3. **Check existing functions and triggers** - Avoid duplicating logic
4. **Read migration history** - Understand how the schema evolved

### Database Design Guidelines

#### Table Design Best Practices
- Use `uuid` for primary keys with `gen_random_uuid()` default
- Always include `created_at` and `updated_at` timestamps
- Use `timestamptz` instead of `timestamp` for timezone awareness
- Add appropriate indexes for frequently queried columns
- Use foreign key constraints with proper `ON DELETE` behavior
- Prefer `text` over `varchar` unless length constraint is needed
- Use `jsonb` for flexible schema data, not `json`

#### Naming Conventions
- Use `snake_case` for table and column names
- Use plural names for tables (`users`, `posts`, `comments`)
- Prefix junction tables with both table names (`user_roles`, `post_tags`)
- Prefix views with `v_` (`v_user_profiles`)
- Prefix functions with action verb (`get_`, `create_`, `update_`, `delete_`)

#### Standard Table Template
```sql
CREATE TABLE IF NOT EXISTS table_name (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- columns here
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-update updated_at
CREATE TRIGGER update_table_name_updated_at
  BEFORE UPDATE ON table_name
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

#### Common Helper Function
```sql
-- Updated_at trigger function (create once, use everywhere)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Row Level Security (RLS)

#### RLS Best Practices
- ALWAYS enable RLS on tables containing user data
- Create policies for each operation type (SELECT, INSERT, UPDATE, DELETE)
- Use `auth.uid()` to get the current user's ID
- Use `auth.jwt()` to access JWT claims for role-based access
- Test policies thoroughly - both positive and negative cases
- Use helper functions for complex policy logic

#### Common RLS Patterns

##### User-owned data
```sql
-- Users can only access their own data
CREATE POLICY "Users can view own data"
  ON user_data FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own data"
  ON user_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
  ON user_data FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own data"
  ON user_data FOR DELETE
  USING (auth.uid() = user_id);
```

##### Public read, authenticated write
```sql
CREATE POLICY "Anyone can read"
  ON posts FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert"
  ON posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);
```

##### Role-based access
```sql
-- Using JWT claims
CREATE POLICY "Admins can do anything"
  ON sensitive_data FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- Using a roles table
CREATE POLICY "Managers can view team data"
  ON team_data FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role IN ('manager', 'admin')
      AND team_id = team_data.team_id
    )
  );
```

##### Organization/Team-based access
```sql
CREATE POLICY "Team members can access team resources"
  ON team_resources FOR SELECT
  USING (
    team_id IN (
      SELECT team_id FROM team_members
      WHERE user_id = auth.uid()
    )
  );
```

### Authentication Patterns

#### Custom User Metadata
```sql
-- Trigger to create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data ->> 'full_name',
    NEW.raw_user_meta_data ->> 'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

#### Sync User Data on Update
```sql
CREATE OR REPLACE FUNCTION handle_user_update()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles
  SET
    email = NEW.email,
    updated_at = NOW()
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_update();
```

### Database Functions

#### Security Definer vs Invoker
```sql
-- SECURITY DEFINER: Runs with creator's permissions (bypass RLS)
-- Use for admin operations or when RLS would block legitimate access
CREATE OR REPLACE FUNCTION admin_get_all_users()
RETURNS SETOF profiles AS $$
BEGIN
  RETURN QUERY SELECT * FROM profiles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- SECURITY INVOKER (default): Runs with caller's permissions
-- Use when RLS should apply
CREATE OR REPLACE FUNCTION get_user_posts(target_user_id UUID)
RETURNS SETOF posts AS $$
BEGIN
  RETURN QUERY SELECT * FROM posts WHERE user_id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;
```

#### RPC Functions for Complex Operations
```sql
-- Atomic transaction for complex operations
CREATE OR REPLACE FUNCTION transfer_credits(
  from_user_id UUID,
  to_user_id UUID,
  amount INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
  from_balance INTEGER;
BEGIN
  -- Check balance
  SELECT credits INTO from_balance
  FROM wallets WHERE user_id = from_user_id
  FOR UPDATE;

  IF from_balance < amount THEN
    RETURN FALSE;
  END IF;

  -- Perform transfer
  UPDATE wallets SET credits = credits - amount
  WHERE user_id = from_user_id;

  UPDATE wallets SET credits = credits + amount
  WHERE user_id = to_user_id;

  -- Log transaction
  INSERT INTO transactions (from_user, to_user, amount)
  VALUES (from_user_id, to_user_id, amount);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Storage Configuration

#### Storage Policies
```sql
-- Allow authenticated users to upload to their folder
CREATE POLICY "Users can upload to own folder"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Allow public read for avatars
CREATE POLICY "Public avatar access"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

-- Allow users to update/delete their own files
CREATE POLICY "Users can update own files"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid());

CREATE POLICY "Users can delete own files"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (owner_id = auth.uid());
```

### Edge Functions

#### Basic Edge Function Structure
```typescript
// supabase/functions/function-name/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client with user's JWT
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get authenticated user
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    // Parse request body
    const { name } = await req.json()

    // Your logic here
    const result = { message: `Hello ${name}!`, userId: user.id }

    return new Response(
      JSON.stringify(result),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

#### Edge Function with Service Role (Admin)
```typescript
// For operations that need to bypass RLS
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
)

// Now queries bypass RLS
const { data, error } = await supabaseAdmin
  .from('users')
  .select('*')
```

### Realtime Configuration

#### Enable Realtime on Tables
```sql
-- Enable realtime for specific tables
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- Or enable for all tables (not recommended for production)
-- ALTER PUBLICATION supabase_realtime SET (publish = 'insert, update, delete');
```

#### Realtime with RLS
Realtime subscriptions respect RLS policies. Ensure your policies allow the operations you want to broadcast.

### Performance Optimization

#### Indexing Strategies
```sql
-- B-tree index for equality and range queries
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Composite index for common query patterns
CREATE INDEX idx_posts_user_status ON posts(user_id, status);

-- Partial index for common filters
CREATE INDEX idx_active_users ON users(email) WHERE deleted_at IS NULL;

-- GIN index for JSONB columns
CREATE INDEX idx_metadata ON items USING GIN(metadata);

-- Full-text search index
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', title || ' ' || content));
```

#### Query Optimization
```sql
-- Use EXPLAIN ANALYZE to check query plans
EXPLAIN ANALYZE SELECT * FROM posts WHERE user_id = 'uuid-here';

-- Avoid SELECT * in production
SELECT id, title, created_at FROM posts WHERE user_id = $1;

-- Use pagination with keyset instead of OFFSET
SELECT * FROM posts
WHERE created_at < $1
ORDER BY created_at DESC
LIMIT 20;
```

### Migration Best Practices

#### Safe Migration Pattern
```sql
-- Always use IF EXISTS / IF NOT EXISTS
CREATE TABLE IF NOT EXISTS new_table (...);
DROP TABLE IF EXISTS old_table;

-- Add columns with defaults for existing rows
ALTER TABLE users ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}';

-- Use transactions for multi-step migrations
BEGIN;
  ALTER TABLE posts ADD COLUMN slug TEXT;
  UPDATE posts SET slug = lower(replace(title, ' ', '-'));
  ALTER TABLE posts ALTER COLUMN slug SET NOT NULL;
  CREATE UNIQUE INDEX idx_posts_slug ON posts(slug);
COMMIT;
```

#### Backward Compatible Changes
- Add new columns with defaults
- Don't rename columns - add new, migrate data, drop old
- Don't change column types directly - add new, migrate, drop
- Keep old APIs working during transition

### Error Handling Patterns

#### Function with Error Handling
```sql
CREATE OR REPLACE FUNCTION safe_operation(input_id UUID)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  -- Validate input
  IF input_id IS NULL THEN
    RETURN jsonb_build_object('error', 'Input ID is required');
  END IF;

  -- Attempt operation
  SELECT to_jsonb(t) INTO result
  FROM target_table t
  WHERE id = input_id;

  IF result IS NULL THEN
    RETURN jsonb_build_object('error', 'Record not found');
  END IF;

  RETURN jsonb_build_object('data', result);
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql;
```

### Common Patterns

#### Soft Delete
```sql
ALTER TABLE posts ADD COLUMN deleted_at TIMESTAMPTZ;

-- RLS policy to hide soft-deleted records
CREATE POLICY "Hide deleted posts"
  ON posts FOR SELECT
  USING (deleted_at IS NULL);

-- Function to soft delete
CREATE OR REPLACE FUNCTION soft_delete_post(post_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE posts SET deleted_at = NOW() WHERE id = post_id;
END;
$$ LANGUAGE plpgsql;
```

#### Audit Trail
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL,
  old_data JSONB,
  new_data JSONB,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id)
  VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
    CASE WHEN TG_OP != 'DELETE' THEN to_jsonb(NEW) ELSE NULL END,
    auth.uid()
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply to tables
CREATE TRIGGER posts_audit
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

#### Counter Cache
```sql
-- Add counter to parent table
ALTER TABLE users ADD COLUMN posts_count INTEGER DEFAULT 0;

-- Trigger to maintain count
CREATE OR REPLACE FUNCTION update_posts_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET posts_count = posts_count + 1 WHERE id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET posts_count = posts_count - 1 WHERE id = OLD.user_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER maintain_posts_count
  AFTER INSERT OR DELETE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_posts_count();
```

### Debugging

#### Check RLS Policies
```sql
-- View all policies on a table
SELECT * FROM pg_policies WHERE tablename = 'your_table';

-- Test policy as specific user
SET request.jwt.claim.sub = 'user-uuid-here';
SELECT * FROM your_table; -- Will apply RLS
RESET request.jwt.claim.sub;
```

#### Check Function Performance
```sql
-- Enable timing
\timing on

-- Check function execution
EXPLAIN ANALYZE SELECT your_function(param);
```

## KASBON-Specific Guidelines

### Database Schema Conventions
- **SQLite Compatibility:** Store timestamps as `INTEGER` (milliseconds since epoch) for local SQLite
- **PostgreSQL Cloud:** Use `TIMESTAMPTZ` for cloud tables
- **Primary Keys:** Prefer `INTEGER` auto-increment for SQLite, `UUID` for cloud sync tables

### Offline-First Considerations
- All tables must work with SQLite locally first
- Design sync-friendly schemas (include `synced_at`, `local_id`, `server_id` where needed)
- RLS policies apply to cloud sync only, not local SQLite

### KASBON Table Naming
- `shop_settings` - Single row shop config
- `categories` - Product categories
- `products` - Products with `cost_price` and `selling_price`
- `transactions` - Transaction headers with `payment_status` (paid/debt)
- `transaction_items` - Line items with price snapshots

### Frontend Integration Notes
When data is fetched and displayed in Flutter:
- Loading states: UI uses `ModernLoading()`
- Error states: UI uses `ModernErrorState(message, onRetry)`
- Empty states: UI uses `ModernEmptyState(icon, title, onAction)`
- Success feedback: `ModernToast.success()`
- All UI text must be in Bahasa Indonesia

## Project Analysis Checklist
When starting work on a Supabase project:
1. Review database schema in Supabase Dashboard or via `psql`
2. Check existing RLS policies on all tables
3. Review triggers and functions
4. Check storage buckets and policies
5. Review Edge Functions if any
6. Check realtime configuration
7. Review auth settings and providers
8. Check existing migrations in `supabase/migrations`
9. Review environment variables and secrets
10. Check for existing indexes and query performance

### KASBON-Specific Checks
11. Verify SQLite compatibility for offline-first tables
12. Check sync fields (`synced_at`, `local_id`, `server_id`)
13. Verify timestamp format matches SQLite (INTEGER milliseconds)
14. Check for profit tracking fields (`cost_price`, `selling_price`)
15. Verify debt tracking (`payment_status`) implementation
