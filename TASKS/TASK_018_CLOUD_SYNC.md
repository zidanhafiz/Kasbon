# TASK_018: Cloud Sync

**Priority:** P2 (Phase 2)
**Complexity:** HIGH
**Phase:** Cloud Sync
**Status:** Not Started

---

## Objective

Implement bidirectional sync between local SQLite database and Supabase PostgreSQL, enabling data backup and multi-device access for Pro users.

---

## Prerequisites

- [x] TASK_017: Authentication

---

## Subtasks

### 1. Cloud Database Schema

- [ ] Create PostgreSQL tables in Supabase (mirror local schema)
- [ ] Add `user_id` column to all tables
- [ ] Configure Row Level Security (RLS)
- [ ] Create indexes for performance

### 2. Sync Architecture

- [ ] Create `lib/core/services/sync_service.dart`
- [ ] Define sync strategy (last-write-wins)
- [ ] Handle sync states (synced, pending, conflict)
- [ ] Create sync queue for offline changes

### 3. Sync Operations

- [ ] Initial sync (first time after login)
  - Upload local data to cloud
  - Download cloud data to local

- [ ] Incremental sync
  - Sync only changed records
  - Use timestamps for change detection

- [ ] Conflict resolution
  - Last-write-wins (by updated_at)
  - Preserve both versions for critical data (optional)

### 4. Sync Log Table

- [ ] Create local sync_log table
  - Track pending changes
  - Record sync attempts
  - Handle failures

### 5. Background Sync

- [ ] Implement background sync worker
- [ ] Sync on app foreground
- [ ] Sync after data changes
- [ ] Respect battery/network conditions

### 6. Sync Status UI

- [ ] Create sync status indicator
- [ ] Show last sync time
- [ ] Manual sync button
- [ ] Sync progress indicator

---

## Sync Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         MOBILE APP                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐ │
│  │   Features   │────►│ Repositories │────►│   SQLite     │ │
│  └──────────────┘     └──────────────┘     └──────────────┘ │
│                              │                     │         │
│                              │                     │         │
│                              ▼                     │         │
│                       ┌──────────────┐             │         │
│                       │  Sync Queue  │◄────────────┘         │
│                       └──────────────┘                       │
│                              │                               │
│                              ▼                               │
│                       ┌──────────────┐                       │
│                       │ Sync Service │                       │
│                       └──────────────┘                       │
│                              │                               │
└──────────────────────────────┼───────────────────────────────┘
                               │
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                         SUPABASE                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐ │
│  │    Auth      │     │     RLS      │     │  PostgreSQL  │ │
│  └──────────────┘     └──────────────┘     └──────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Cloud Database Schema

```sql
-- Users (managed by Supabase Auth)
-- Access via auth.users()

-- User profiles
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT,
  phone TEXT,
  tier TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Shop settings (one per user)
CREATE TABLE shop_settings (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  logo_url TEXT,
  receipt_header TEXT,
  receipt_footer TEXT,
  currency TEXT DEFAULT 'IDR',
  low_stock_threshold INTEGER DEFAULT 5,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Products
CREATE TABLE products (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  category_id UUID,
  sku TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  barcode TEXT,
  cost_price DECIMAL(12,2) NOT NULL,
  selling_price DECIMAL(12,2) NOT NULL,
  stock INTEGER DEFAULT 0,
  min_stock INTEGER DEFAULT 5,
  unit TEXT DEFAULT 'pcs',
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, sku)
);

-- Transactions
CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  transaction_number TEXT NOT NULL,
  customer_name TEXT,
  subtotal DECIMAL(12,2) NOT NULL,
  discount_amount DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) NOT NULL,
  payment_method TEXT DEFAULT 'cash',
  payment_status TEXT DEFAULT 'paid',
  cash_received DECIMAL(12,2),
  cash_change DECIMAL(12,2),
  notes TEXT,
  cashier_name TEXT,
  transaction_date TIMESTAMPTZ NOT NULL,
  debt_paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, transaction_number)
);

-- Transaction items
CREATE TABLE transaction_items (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,
  product_sku TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  cost_price DECIMAL(12,2) NOT NULL,
  selling_price DECIMAL(12,2) NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only access their own data
CREATE POLICY "Users can access own data"
  ON products FOR ALL
  USING (user_id = auth.uid());

-- (Similar policies for other tables)
```

---

## Sync Service Implementation

```dart
class SyncService {
  final SupabaseClient _supabase;
  final DatabaseHelper _localDb;

  SyncService(this._supabase, this._localDb);

  /// Initial sync after login
  Future<void> initialSync() async {
    // 1. Get cloud data counts
    final cloudCounts = await _getCloudDataCounts();

    // 2. Get local data counts
    final localCounts = await _getLocalDataCounts();

    // 3. Determine sync direction
    if (localCounts.total > 0 && cloudCounts.total == 0) {
      // Local has data, cloud is empty → Upload
      await _uploadLocalToCloud();
    } else if (cloudCounts.total > 0 && localCounts.total == 0) {
      // Cloud has data, local is empty → Download
      await _downloadCloudToLocal();
    } else if (cloudCounts.total > 0 && localCounts.total > 0) {
      // Both have data → Merge (complex, show dialog)
      await _handleMergeConflict();
    }
    // Else: Both empty, nothing to sync
  }

  /// Sync pending changes
  Future<void> syncPendingChanges() async {
    final pendingChanges = await _getPendingChanges();

    for (final change in pendingChanges) {
      try {
        await _syncChange(change);
        await _markAsSynced(change);
      } catch (e) {
        await _markSyncFailed(change, e.toString());
      }
    }
  }

  /// Watch for local changes
  void watchLocalChanges() {
    // Listen to database changes
    // Add to sync queue
    // Trigger sync after debounce
  }
}
```

---

## Sync States

```dart
enum SyncStatus {
  synced,      // Data is up-to-date
  pending,     // Changes waiting to sync
  syncing,     // Sync in progress
  conflict,    // Conflict detected
  error,       // Sync failed
}

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final int pendingCount;
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatus.synced,
    this.lastSyncAt,
    this.pendingCount = 0,
    this.errorMessage,
  });
}
```

---

## UI Specifications

### Sync Status Indicator
```
┌─────────────────────────────────────┐
│  ● Tersinkronisasi                  │  (Green dot)
│  Terakhir: 5 menit lalu             │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  ○ Menyinkronkan...                 │  (Spinning)
│  Mengupload 5 transaksi...          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  ● 3 perubahan menunggu             │  (Yellow dot)
│  [Sinkronkan Sekarang]              │
└─────────────────────────────────────┘
```

### Sync Settings Screen
```
┌─────────────────────────────────────┐
│  [<]  Sinkronisasi                  │
├─────────────────────────────────────┤
│                                      │
│  STATUS                              │
│  ─────────────────────────────────  │
│  ● Tersinkronisasi                  │
│  Terakhir: 15 Des 2024, 14:30       │
│                                      │
│  Data di cloud:                      │
│  • 50 produk                        │
│  • 250 transaksi                    │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  AKSI                                │
│  ─────────────────────────────────  │
│  ┌────────────────────────────────┐ │
│  │      🔄 Sinkronkan Sekarang    │ │
│  └────────────────────────────────┘ │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  PENGATURAN                          │
│  ─────────────────────────────────  │
│  Sinkronisasi Otomatis      [✓]     │
│  Sinkronisasi via WiFi saja [✓]     │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  PERANGKAT                           │
│  ─────────────────────────────────  │
│  • Xiaomi Redmi Note 10 (ini)       │
│  • Samsung Galaxy A52 (aktif)       │
│                                      │
│  (Maks 2 perangkat untuk Pro)       │
│                                      │
└─────────────────────────────────────┘
```

---

## Acceptance Criteria

- [ ] Initial sync uploads local data to cloud
- [ ] Initial sync downloads cloud data to local
- [ ] Changes sync automatically in background
- [ ] Sync works offline (queues changes)
- [ ] Sync status indicator shows current state
- [ ] Manual sync button works
- [ ] Multi-device sync works (2 devices for Pro)
- [ ] Conflict resolution handles edge cases
- [ ] Data integrity maintained (no duplicates, no loss)
- [ ] Sync respects network conditions

---

## Notes

### Sync Trigger Points
- App comes to foreground
- After creating/updating/deleting data
- Manual sync button
- Periodic background sync (every 5 min when online)

### Offline Handling
All changes are saved locally first. Sync happens when online.
Use connectivity_plus package to detect network.

### Device Limit
Pro tier: Max 2 devices
Business tier: Unlimited devices

Track devices using unique device ID.

### Data Priority
When conflicts occur:
1. Transactions: Last-write-wins (most recent timestamp)
2. Products: Last-write-wins
3. Settings: Last-write-wins

### Performance
- Batch sync operations (max 100 records per request)
- Use pagination for large datasets
- Compress data if needed

---

## Estimated Time

**2-3 weeks** (most complex task)

---

## Next Task

After completing this task, proceed to:
- [TASK_019_ADVANCED_REPORTS.md](./TASK_019_ADVANCED_REPORTS.md)
