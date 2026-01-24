# TASK_014: Backup & Restore

**Priority:** P1 (Core)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** Completed (Jan 24, 2025)

---

## Objective

Enable users to backup their data to a JSON file and restore it later. This provides data safety before cloud sync is available (Phase 2).

---

## Prerequisites

- [x] TASK_002: Database Setup
- [x] TASK_013: Settings

---

## Subtasks

### 1. Backup Functionality

#### Export Service
- [x] Create `lib/core/services/backup_service.dart`
  - exportToJson() - exports all data
  - Returns JSON string

- [x] Export includes:
  - shop_settings
  - categories
  - products
  - transactions
  - transaction_items

- [x] Metadata included:
  - backup_version
  - backup_date
  - app_version
  - device_info

#### File Operations
- [x] Create `lib/core/services/file_service.dart`
  - saveToFile(content, filename)
  - readFromFile(path)
  - getBackupDirectory()

- [x] Filename format: `kasbon_backup_YYYYMMDD_HHmmss.json`

### 2. Restore Functionality

#### Import Service
- [x] Update `backup_service.dart`
  - importFromJson(String json)
  - Validates backup version
  - Clears existing data (with confirmation)
  - Inserts backup data

- [x] Version compatibility check
- [x] Data validation before import

### 3. Presentation Layer

#### Screens
- [x] Create `lib/features/settings/presentation/screens/backup_restore_screen.dart`
  - Backup section
  - Restore section
  - Backup history (optional)

#### Widgets
- [x] Create `lib/features/settings/presentation/widgets/backup_card.dart`
- [x] Create `lib/features/settings/presentation/widgets/restore_dialog.dart`

### 4. Share Functionality

- [x] Share backup file via:
  - System share sheet
  - Google Drive (via share)
  - WhatsApp (via share)

- [x] Use `share_plus` package

---

## Backup JSON Format

```json
{
  "metadata": {
    "backup_version": "1.0",
    "backup_date": "2024-12-15T14:30:00.000Z",
    "app_version": "1.0.0",
    "device": "Android",
    "total_products": 50,
    "total_transactions": 250
  },
  "shop_settings": {
    "name": "Warung Bu Siti",
    "address": "Jl. Raya No. 123",
    "phone": "0812-3456-7890",
    "receipt_header": "Selamat datang!",
    "receipt_footer": "Terima kasih!",
    "currency": "IDR",
    "low_stock_threshold": 5
  },
  "categories": [
    {
      "id": "cat-1",
      "name": "Makanan",
      "color": "#FF6B35",
      "icon": "food",
      "sort_order": 0
    }
  ],
  "products": [
    {
      "id": "prod-uuid-1",
      "category_id": "cat-1",
      "sku": "IND-12345",
      "name": "Indomie Goreng",
      "cost_price": 2500,
      "selling_price": 3500,
      "stock": 50,
      "min_stock": 10,
      "unit": "pcs",
      "is_active": true,
      "created_at": 1702641000000,
      "updated_at": 1702641000000
    }
  ],
  "transactions": [
    {
      "id": "txn-uuid-1",
      "transaction_number": "TRX-20241215-0001",
      "customer_name": null,
      "subtotal": 35000,
      "discount_amount": 0,
      "total": 35000,
      "payment_method": "cash",
      "payment_status": "paid",
      "cash_received": 50000,
      "cash_change": 15000,
      "transaction_date": 1702641000000,
      "created_at": 1702641000000
    }
  ],
  "transaction_items": [
    {
      "id": "item-uuid-1",
      "transaction_id": "txn-uuid-1",
      "product_id": "prod-uuid-1",
      "product_name": "Indomie Goreng",
      "product_sku": "IND-12345",
      "quantity": 10,
      "cost_price": 2500,
      "selling_price": 3500,
      "subtotal": 35000,
      "created_at": 1702641000000
    }
  ]
}
```

---

## UI Specifications

### Backup & Restore Screen
```
┌─────────────────────────────────────┐
│  [<]  Backup & Restore              │
├─────────────────────────────────────┤
│                                      │
│  BACKUP DATA                         │
│  ─────────────────────────────────  │
│                                      │
│  ⓘ Backup semua data Anda ke file   │
│    JSON. Simpan di tempat aman.     │
│                                      │
│  Data yang di-backup:                │
│  • 50 produk                        │
│  • 250 transaksi                    │
│  • Pengaturan toko                   │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      💾 Buat Backup            │ │
│  └────────────────────────────────┘ │
│                                      │
│  Backup terakhir:                    │
│  15 Des 2024, 14:30                  │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  RESTORE DATA                        │
│  ─────────────────────────────────  │
│                                      │
│  ⚠️ Restore akan MENGHAPUS semua    │
│    data saat ini dan menggantinya   │
│    dengan data dari backup.          │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      📂 Pilih File Backup      │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Backup Success Dialog
```
┌─────────────────────────────────────┐
│         ✅ Backup Berhasil          │
├─────────────────────────────────────┤
│                                      │
│  File backup telah dibuat:           │
│                                      │
│  kasbon_backup_20241215_143000.json  │
│                                      │
│  Lokasi:                             │
│  Documents/KASBON/Backups/           │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      📤 Bagikan File           │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │      ✓  Selesai                │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Restore Confirmation Dialog
```
┌─────────────────────────────────────┐
│         ⚠️  Konfirmasi Restore      │
├─────────────────────────────────────┤
│                                      │
│  Anda akan me-restore data dari:     │
│  kasbon_backup_20241210_100000.json  │
│                                      │
│  Data backup:                        │
│  • 45 produk                        │
│  • 200 transaksi                    │
│  • Tanggal: 10 Des 2024             │
│                                      │
│  ⚠️ PERINGATAN:                      │
│  Semua data saat ini akan DIHAPUS    │
│  dan diganti dengan data backup.     │
│                                      │
│  Tindakan ini tidak dapat dibatalkan!│
│                                      │
│  [Batal]              [Ya, Restore] │
│                                      │
└─────────────────────────────────────┘
```

### Restore Progress
```
┌─────────────────────────────────────┐
│         Sedang Restore...           │
├─────────────────────────────────────┤
│                                      │
│        [=====     ] 50%              │
│                                      │
│  Mengimpor produk... (25/45)        │
│                                      │
│  ⓘ Jangan tutup aplikasi            │
│                                      │
└─────────────────────────────────────┘
```

---

## Backup Service Implementation

```dart
class BackupService {
  final DatabaseHelper _db;

  BackupService(this._db);

  Future<String> exportToJson() async {
    final backup = {
      'metadata': {
        'backup_version': '1.0',
        'backup_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
      },
      'shop_settings': await _exportShopSettings(),
      'categories': await _exportCategories(),
      'products': await _exportProducts(),
      'transactions': await _exportTransactions(),
      'transaction_items': await _exportTransactionItems(),
    };

    return jsonEncode(backup);
  }

  Future<void> importFromJson(String json) async {
    final backup = jsonDecode(json) as Map<String, dynamic>;

    // Validate version
    final version = backup['metadata']['backup_version'];
    if (version != '1.0') {
      throw Exception('Unsupported backup version: $version');
    }

    // Clear existing data
    await _clearAllData();

    // Import in order (due to foreign keys)
    await _importShopSettings(backup['shop_settings']);
    await _importCategories(backup['categories']);
    await _importProducts(backup['products']);
    await _importTransactions(backup['transactions']);
    await _importTransactionItems(backup['transaction_items']);
  }

  Future<void> _clearAllData() async {
    final db = await _db.database;
    await db.delete('transaction_items');
    await db.delete('transactions');
    await db.delete('products');
    await db.delete('categories');
    // Keep shop_settings but update
  }
}
```

---

## Acceptance Criteria

- [x] Can create backup of all data
- [x] Backup saves to device storage
- [x] Backup can be shared via system share
- [x] Can select backup file to restore
- [x] Restore shows confirmation dialog
- [x] Restore warns about data replacement
- [x] Progress indicator during restore
- [x] Success/error feedback
- [x] Restored data is functional
- [x] Invalid backup files are rejected

---

## Notes

### Storage Location
Save backups to app documents directory:
- Android: `/data/data/com.kasbon.pos/files/backups/`
- User can share to Drive, WhatsApp, etc.

### File Picker
Use `file_picker` package to select backup file for restore.

### Data Integrity
Before restore:
1. Validate JSON structure
2. Check required fields
3. Verify data types
4. Check foreign key relationships

### Large Backups
For stores with 1000+ transactions, backup may be large (~5-10MB).
Consider compression for v1.1.

### Security
Backup files are not encrypted (MVP).
Encryption can be added later for Pro tier.

---

## Dependencies to Add

```yaml
dependencies:
  file_picker: ^6.1.1
  path_provider: ^2.1.1  # Already added
  share_plus: ^7.2.1     # Already added
```

---

## Estimated Time

**2-3 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_015_TESTING.md](./TASK_015_TESTING.md)
