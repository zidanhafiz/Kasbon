# TASK_013: Settings

**Priority:** P1 (Core)
**Complexity:** LOW
**Phase:** MVP
**Status:** Completed (Jan 24, 2025)

---

## Objective

Build settings screen for shop profile configuration, receipt customization, and app preferences.

---

## Prerequisites

- [x] TASK_002: Database Setup (shop_settings table)
- [x] TASK_003: Core Infrastructure

---

## Subtasks

### 1. Data Layer

#### Model
- [ ] Create `lib/features/settings/data/models/shop_settings_model.dart`
  - ShopSettingsModel class
  - fromMap() and toMap() for SQLite

#### Data Source
- [ ] Create `lib/features/settings/data/datasources/settings_local_datasource.dart`
  - getShopSettings()
  - updateShopSettings()

#### Repository
- [ ] Create `lib/features/settings/data/repositories/settings_repository_impl.dart`

### 2. Domain Layer

#### Entity
- [ ] Create `lib/features/settings/domain/entities/shop_settings.dart`

#### Repository Interface
- [ ] Create `lib/features/settings/domain/repositories/settings_repository.dart`

#### Use Cases
- [ ] Create `lib/features/settings/domain/usecases/get_shop_settings.dart`
- [ ] Create `lib/features/settings/domain/usecases/update_shop_settings.dart`

### 3. Presentation Layer

#### Providers
- [ ] Create `lib/features/settings/presentation/providers/settings_provider.dart`
  - shopSettingsProvider
  - updateShopSettings()

#### Screens
- [ ] Create `lib/features/settings/presentation/screens/settings_screen.dart`
  - Main settings menu

- [ ] Create `lib/features/settings/presentation/screens/shop_profile_screen.dart`
  - Edit shop name, address, phone

- [ ] Create `lib/features/settings/presentation/screens/receipt_settings_screen.dart`
  - Header and footer customization

- [ ] Create `lib/features/settings/presentation/screens/app_settings_screen.dart`
  - Low stock threshold
  - Theme (if implemented)

- [ ] Create `lib/features/settings/presentation/screens/about_screen.dart`
  - App version
  - Developer info
  - Links

#### Widgets
- [ ] Create `lib/features/settings/presentation/widgets/settings_tile.dart`
  - Icon, title, subtitle, action

- [ ] Create `lib/features/settings/presentation/widgets/settings_section.dart`
  - Section header with tiles

### 4. Navigation

- [ ] Add settings routes to GoRouter
  - /settings (main)
  - /settings/shop-profile
  - /settings/receipt
  - /settings/app
  - /settings/about

- [ ] Connect to "Lainnya" bottom navigation

---

## Shop Settings Entity

```dart
class ShopSettings extends Equatable {
  final String name;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final String? receiptHeader;
  final String? receiptFooter;
  final String currency;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShopSettings({
    required this.name,
    this.address,
    this.phone,
    this.logoUrl,
    this.receiptHeader,
    this.receiptFooter,
    this.currency = 'IDR',
    this.lowStockThreshold = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [name, address, phone];
}
```

---

## UI Specifications

### Main Settings Screen
```
┌─────────────────────────────────────┐
│  [<]  Pengaturan                    │
├─────────────────────────────────────┤
│                                      │
│  PROFIL TOKO                         │
│  ─────────────────────────────────  │
│  ┌────────────────────────────────┐ │
│  │ 🏪 Profil Toko              →  │ │
│  │    Warung Bu Siti               │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 🧾 Pengaturan Struk         →  │ │
│  │    Header & footer struk        │ │
│  └────────────────────────────────┘ │
│                                      │
│  APLIKASI                            │
│  ─────────────────────────────────  │
│  ┌────────────────────────────────┐ │
│  │ 📦 Batas Stok Rendah        →  │ │
│  │    5 pcs                        │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 🎨 Tampilan                 →  │ │
│  │    Tema terang                  │ │
│  └────────────────────────────────┘ │
│                                      │
│  DATA                                │
│  ─────────────────────────────────  │
│  ┌────────────────────────────────┐ │
│  │ 💾 Backup & Restore         →  │ │
│  │    Cadangkan data Anda          │ │
│  └────────────────────────────────┘ │
│                                      │
│  LAINNYA                             │
│  ─────────────────────────────────  │
│  ┌────────────────────────────────┐ │
│  │ ℹ️  Tentang KASBON          →  │ │
│  │    Versi 1.0.0                  │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ ⭐ Beri Rating               →  │ │
│  │    Bantu kami berkembang        │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 💬 Bantuan & Feedback       →  │ │
│  │    WhatsApp support             │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Shop Profile Screen
```
┌─────────────────────────────────────┐
│  [<]  Profil Toko          [Simpan] │
├─────────────────────────────────────┤
│                                      │
│  Nama Toko *                         │
│  ┌────────────────────────────────┐ │
│  │ Warung Bu Siti                 │ │
│  └────────────────────────────────┘ │
│                                      │
│  Alamat                              │
│  ┌────────────────────────────────┐ │
│  │ Jl. Raya No. 123               │ │
│  │ Kelurahan, Kecamatan           │ │
│  │ Jakarta Timur 13000            │ │
│  └────────────────────────────────┘ │
│                                      │
│  Nomor Telepon                       │
│  ┌────────────────────────────────┐ │
│  │ 0812-3456-7890                 │ │
│  └────────────────────────────────┘ │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  ⓘ Informasi ini akan muncul di    │
│    struk transaksi Anda.            │
│                                      │
└─────────────────────────────────────┘
```

### Receipt Settings Screen
```
┌─────────────────────────────────────┐
│  [<]  Pengaturan Struk     [Simpan] │
├─────────────────────────────────────┤
│                                      │
│  Header Struk                        │
│  ┌────────────────────────────────┐ │
│  │ Selamat datang di toko kami!   │ │
│  └────────────────────────────────┘ │
│  ⓘ Muncul di bagian atas struk     │
│                                      │
│  Footer Struk                        │
│  ┌────────────────────────────────┐ │
│  │ Terima kasih atas kunjungannya!│ │
│  │ Barang yang sudah dibeli tidak │ │
│  │ dapat dikembalikan.            │ │
│  └────────────────────────────────┘ │
│  ⓘ Muncul di bagian bawah struk    │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  PREVIEW STRUK                       │
│  ┌────────────────────────────────┐ │
│  │ ════════════════════════       │ │
│  │      WARUNG BU SITI            │ │
│  │  Jl. Raya No. 123              │ │
│  │ ════════════════════════       │ │
│  │ Selamat datang di toko kami!   │ │
│  │ ────────────────────────       │ │
│  │ [item list]                    │ │
│  │ ────────────────────────       │ │
│  │ Terima kasih atas              │ │
│  │ kunjungannya!                  │ │
│  │ ════════════════════════       │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### About Screen
```
┌─────────────────────────────────────┐
│  [<]  Tentang KASBON                │
├─────────────────────────────────────┤
│                                      │
│         ┌────────────┐              │
│         │    LOGO    │              │
│         └────────────┘              │
│                                      │
│           KASBON                     │
│     Kasir Digital untuk Semua       │
│                                      │
│         Versi 1.0.0                  │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  KASBON adalah aplikasi kasir       │
│  digital gratis untuk UMKM          │
│  Indonesia. Dibuat dengan ❤️         │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 🌐 Website                     │ │
│  │    kasbon.id                    │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 📱 Instagram                   │ │
│  │    @kasbon.id                   │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 💬 WhatsApp Support            │ │
│  │    0812-XXXX-XXXX               │ │
│  └────────────────────────────────┘ │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  © 2024 KASBON. All rights reserved.│
│                                      │
└─────────────────────────────────────┘
```

---

## Acceptance Criteria

- [x] Can view and edit shop profile (name, address, phone)
- [x] Can customize receipt header and footer
- [x] Can set low stock threshold
- [x] Settings save successfully
- [x] Settings persist after app restart
- [x] About screen shows app version
- [x] Can open external links (website, WhatsApp)
- [x] Form validation for required fields
- [x] Success feedback on save

---

## Notes

### First Launch
On first launch, prompt user to set shop name.
Default values:
- name: "Toko Saya"
- lowStockThreshold: 5

### Theme (Optional for MVP)
Light theme only for MVP.
Dark theme can be added later.

### Rate App
Open Play Store listing for rating.
Use `url_launcher` package.

### WhatsApp Support
Open WhatsApp with pre-filled message:
"Halo, saya pengguna KASBON dan butuh bantuan..."

---

## Estimated Time

**2-3 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_014_BACKUP_RESTORE.md](./TASK_014_BACKUP_RESTORE.md)
