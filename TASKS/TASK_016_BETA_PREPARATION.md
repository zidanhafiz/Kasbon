# TASK_016: Beta Preparation

**Priority:** P1 (Core)
**Complexity:** MEDIUM
**Phase:** MVP - Quality
**Status:** Not Started

---

## Objective

Prepare the app for beta release including bug fixes, performance optimization, Play Store assets, and internal testing setup.

---

## Prerequisites

- [x] All MVP features completed (001-014)
- [x] TASK_015: Testing

---

## Subtasks

### 1. Bug Fixes & Polish

- [ ] Fix all P0/P1 bugs from testing
- [ ] Review and fix UI inconsistencies
- [ ] Ensure all strings are in Indonesian
- [ ] Check all error messages are user-friendly
- [ ] Verify empty states on all screens
- [ ] Test all form validations

### 2. Performance Optimization

- [ ] Profile app with Flutter DevTools
- [ ] Optimize list rendering (lazy loading)
- [ ] Minimize rebuilds (check Riverpod usage)
- [ ] Optimize database queries (check indexes)
- [ ] Reduce app startup time (< 3 seconds)
- [ ] Check memory usage (< 250MB active)

### 3. App Branding

- [ ] Create app icon (1024x1024 master)
- [ ] Generate all icon sizes for Android
- [ ] Create splash screen
- [ ] Update app name in Android manifest
- [ ] Add app version info to About screen

### 4. Play Store Assets

#### Screenshots (8 required)
- [ ] Dashboard screenshot
- [ ] POS screen screenshot
- [ ] Product list screenshot
- [ ] Transaction history screenshot
- [ ] Receipt screenshot
- [ ] Reports screenshot
- [ ] Settings screenshot
- [ ] Feature highlight screenshot

#### Graphics
- [ ] Feature graphic (1024x500)
- [ ] Promo graphic (optional)

#### Store Listing Content
- [ ] App title (30 chars max)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Keywords
- [ ] Privacy policy URL
- [ ] Support email

### 5. Play Console Setup

- [ ] Create app in Play Console
- [ ] Fill store listing
- [ ] Upload screenshots and graphics
- [ ] Set content rating (questionnaire)
- [ ] Set pricing (Free)
- [ ] Configure data safety form
- [ ] Setup internal testing track

### 6. Build Configuration

- [ ] Configure release signing (keystore)
- [ ] Update version number (1.0.0+1)
- [ ] Enable Proguard/R8 optimization
- [ ] Build release APK/AAB
- [ ] Test release build on device

### 7. Analytics & Crash Reporting

- [ ] Setup Firebase Analytics (basic)
- [ ] Setup Sentry for crash reporting
- [ ] Add key event tracking:
  - App open
  - First transaction
  - Product created
  - Transaction completed
  - Report viewed

---

## App Icon Design

### Requirements
- 1024x1024 pixels (master)
- Simple, recognizable design
- Works at small sizes (16x16)
- No text (may be unreadable)

### Suggested Design
```
Background: Orange (#FF6B35)
Icon: Stylized "K" or cash register
Style: Flat, modern, minimal
```

### Icon Sizes (Android)
```
mipmap-mdpi:    48x48
mipmap-hdpi:    72x72
mipmap-xhdpi:   96x96
mipmap-xxhdpi:  144x144
mipmap-xxxhdpi: 192x192
```

---

## Play Store Listing

### Title
```
KASBON - Kasir Digital UMKM
```

### Short Description (80 chars)
```
Aplikasi kasir gratis untuk warung, toko & UMKM. Offline, mudah & tanpa ribet!
```

### Full Description (4000 chars)
See DOCS/PROJECT_BRIEF.md for full description template.

Key points to highlight:
- Free forever (Free tier)
- Offline-first (works without internet)
- Simple (designed for non-tech users)
- Profit tracking (unique feature)
- Debt tracking (Indonesian-specific)
- Indonesian support

---

## Release Build Checklist

### Before Build
- [ ] All tests passing
- [ ] No debug logs in production code
- [ ] API keys secured (if any)
- [ ] Correct version number
- [ ] Release notes prepared

### Build Commands
```bash
# Generate release AAB (for Play Store)
flutter build appbundle --release

# Generate release APK (for direct install)
flutter build apk --release

# Output locations:
# AAB: build/app/outputs/bundle/release/app-release.aab
# APK: build/app/outputs/apk/release/app-release.apk
```

### After Build
- [ ] Install release APK on test device
- [ ] Test all features work
- [ ] Check app size (target < 50MB)
- [ ] Verify no crashes

---

## Beta Testing Plan

### Internal Testing (5-10 users)
**Duration:** 1-2 weeks
**Testers:** Friends, family, close contacts with small businesses

**Goals:**
- Find critical bugs
- Validate core flows
- Test on various devices

**Feedback Collection:**
- Google Form survey
- WhatsApp group
- In-app feedback

### Closed Beta (50-100 users)
**Duration:** 2-4 weeks
**Testers:** UMKM community members, early adopters

**Setup:**
1. Create tester list in Play Console
2. Distribute invite link
3. Monitor feedback and crashes

**Incentive:**
- Early access
- Lifetime Pro discount (50%)
- Recognition in app

---

## Analytics Events

### Key Events to Track
```dart
// Event names
const kEventAppOpen = 'app_open';
const kEventFirstTransaction = 'first_transaction';
const kEventProductCreated = 'product_created';
const kEventTransactionCompleted = 'transaction_completed';
const kEventReportViewed = 'report_viewed';
const kEventBackupCreated = 'backup_created';
const kEventDebtCreated = 'debt_created';
const kEventDebtPaid = 'debt_paid';

// Implementation example
FirebaseAnalytics.instance.logEvent(
  name: kEventTransactionCompleted,
  parameters: {
    'total': total,
    'item_count': itemCount,
    'payment_method': paymentMethod,
  },
);
```

---

## Acceptance Criteria

### Quality
- [ ] App launches in < 3 seconds
- [ ] No crashes during normal use
- [ ] All features work as expected
- [ ] UI is consistent across screens
- [ ] All text is in Indonesian

### Play Store
- [ ] Store listing complete
- [ ] All screenshots uploaded
- [ ] Privacy policy published
- [ ] Content rating completed
- [ ] App passes Play Store review

### Beta
- [ ] Internal testing track live
- [ ] First 5 testers invited
- [ ] Feedback mechanism in place

---

## Notes

### Privacy Policy
Create simple privacy policy covering:
- Data collected (local only for Free tier)
- How data is used
- Third-party services (Firebase Analytics)
- Contact information

Host on Google Docs or simple webpage.

### Testing Devices
Test on at least:
- Low-end: 2GB RAM, Android 8
- Mid-range: 4GB RAM, Android 11
- High-end: 8GB RAM, Android 14

### Beta Feedback Template
```
1. Nama Toko:
2. Jenis Usaha:
3. Fitur yang paling berguna:
4. Masalah yang ditemukan:
5. Saran perbaikan:
6. Bintang 1-5:
```

---

## Estimated Time

**1 week**

---

## Next Task

After beta release is stable, proceed to Phase 2:
- [TASK_017_AUTHENTICATION.md](./TASK_017_AUTHENTICATION.md)
