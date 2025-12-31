# TASK_017: Authentication

**Priority:** P2 (Phase 2)
**Complexity:** MEDIUM
**Phase:** Cloud Sync
**Status:** Not Started

---

## Objective

Implement user authentication using Supabase Auth to enable cloud features. Users can register, login, and manage their accounts.

---

## Prerequisites

- [x] MVP features completed
- [x] Beta testing successful

---

## Subtasks

### 1. Supabase Setup

- [ ] Create Supabase project
- [ ] Configure authentication settings
- [ ] Enable email/password auth
- [ ] Enable Google OAuth (optional)
- [ ] Configure email templates (Indonesian)
- [ ] Set up PostgreSQL schema (cloud mirror)

### 2. Flutter Integration

- [ ] Add `supabase_flutter` package
- [ ] Create Supabase client configuration
- [ ] Store Supabase URL and anon key securely
- [ ] Initialize Supabase in main.dart

### 3. Auth Data Layer

- [ ] Create `lib/features/auth/data/datasources/auth_remote_datasource.dart`
  - signUp(email, password)
  - signIn(email, password)
  - signOut()
  - getCurrentUser()
  - resetPassword(email)

- [ ] Create `lib/features/auth/data/repositories/auth_repository_impl.dart`

### 4. Auth Domain Layer

- [ ] Create `lib/features/auth/domain/entities/user.dart`
- [ ] Create `lib/features/auth/domain/repositories/auth_repository.dart`
- [ ] Create use cases:
  - SignUp
  - SignIn
  - SignOut
  - GetCurrentUser
  - ResetPassword

### 5. Auth Presentation

- [ ] Create `lib/features/auth/presentation/providers/auth_provider.dart`
  - authStateProvider
  - currentUserProvider

- [ ] Create screens:
  - `login_screen.dart`
  - `register_screen.dart`
  - `forgot_password_screen.dart`
  - `profile_screen.dart`

### 6. Session Management

- [ ] Handle auth state changes
- [ ] Persist session across app restarts
- [ ] Auto-refresh tokens
- [ ] Handle session expiry

### 7. Navigation

- [ ] Add auth routes
- [ ] Implement auth guard (redirect if not logged in)
- [ ] Handle deep links for email verification

---

## Supabase Configuration

### Project Setup
```
Project Name: kasbon-prod
Region: Southeast Asia (Singapore)
Database: PostgreSQL 15+
```

### Environment Variables
```dart
// lib/config/supabase/supabase_config.dart
class SupabaseConfig {
  static const String url = 'https://xxxxx.supabase.co';
  static const String anonKey = 'your-anon-key';
}
```

### Email Templates (Indonesian)
- Confirmation email
- Password reset email
- Magic link email (if used)

---

## User Entity

```dart
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String tier; // 'free', 'pro', 'business'
  final DateTime? subscriptionExpiresAt;
  final DateTime createdAt;

  bool get isPro => tier == 'pro' || tier == 'business';
  bool get isSubscriptionActive =>
      subscriptionExpiresAt != null &&
      subscriptionExpiresAt!.isAfter(DateTime.now());

  const AppUser({...});
}
```

---

## UI Specifications

### Login Screen
```
┌─────────────────────────────────────┐
│                                      │
│         ┌────────────┐              │
│         │    LOGO    │              │
│         └────────────┘              │
│                                      │
│           Masuk ke KASBON           │
│                                      │
│  Email                               │
│  ┌────────────────────────────────┐ │
│  │ email@example.com              │ │
│  └────────────────────────────────┘ │
│                                      │
│  Password                            │
│  ┌────────────────────────────────┐ │
│  │ ••••••••                   👁   │ │
│  └────────────────────────────────┘ │
│                                      │
│  [Lupa password?]                    │
│                                      │
│  ┌────────────────────────────────┐ │
│  │            MASUK               │ │
│  └────────────────────────────────┘ │
│                                      │
│  ─────────── atau ───────────       │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 🔵 Masuk dengan Google         │ │
│  └────────────────────────────────┘ │
│                                      │
│  Belum punya akun? [Daftar]         │
│                                      │
└─────────────────────────────────────┘
```

### Register Screen
```
┌─────────────────────────────────────┐
│  [<]                                 │
│                                      │
│           Buat Akun Baru            │
│                                      │
│  Nama Lengkap                        │
│  ┌────────────────────────────────┐ │
│  │                                │ │
│  └────────────────────────────────┘ │
│                                      │
│  Email                               │
│  ┌────────────────────────────────┐ │
│  │                                │ │
│  └────────────────────────────────┘ │
│                                      │
│  Password                            │
│  ┌────────────────────────────────┐ │
│  │                            👁   │ │
│  └────────────────────────────────┘ │
│  Min. 8 karakter                     │
│                                      │
│  Konfirmasi Password                 │
│  ┌────────────────────────────────┐ │
│  │                            👁   │ │
│  └────────────────────────────────┘ │
│                                      │
│  ☑ Saya setuju dengan Syarat &      │
│    Ketentuan dan Kebijakan Privasi  │
│                                      │
│  ┌────────────────────────────────┐ │
│  │            DAFTAR              │ │
│  └────────────────────────────────┘ │
│                                      │
│  Sudah punya akun? [Masuk]          │
│                                      │
└─────────────────────────────────────┘
```

---

## Auth Flow

```
App Launch
    │
    ▼
Check Auth State
    │
    ├─── Logged In ────► Home Screen
    │
    └─── Not Logged In ─► Continue as Guest
                             │
                             ├─► Use Free Tier (local only)
                             │
                             └─► Login/Register (for cloud features)
```

### Registration Flow
```
User taps "Daftar"
    │
    ▼
Fill registration form
    │
    ▼
Submit to Supabase
    │
    ▼
Supabase creates user
    │
    ▼
Confirmation email sent
    │
    ▼
User confirms email
    │
    ▼
User can login
```

---

## Acceptance Criteria

- [ ] Can register with email/password
- [ ] Can login with email/password
- [ ] Can logout
- [ ] Can reset password
- [ ] Session persists after app restart
- [ ] Auth state updates across app
- [ ] Error messages are clear (Indonesian)
- [ ] Loading states shown during auth
- [ ] Google Sign-In works (optional)

---

## Notes

### Free Tier Users
Auth is optional for Free tier. Users can continue using the app without an account (local data only).

Auth becomes required when:
- Enabling cloud sync
- Upgrading to Pro tier

### Security
- Never store password locally
- Use Supabase JWT tokens
- Tokens stored in flutter_secure_storage
- Handle token refresh automatically

### Email Verification
Optional for MVP. Can be enforced later.
Supabase handles verification flow.

---

## Dependencies

```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

---

## Estimated Time

**1 week**

---

## Next Task

After completing this task, proceed to:
- [TASK_018_CLOUD_SYNC.md](./TASK_018_CLOUD_SYNC.md)
