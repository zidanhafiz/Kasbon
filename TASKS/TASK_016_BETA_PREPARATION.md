# TASK_016: Open Source Release Preparation

**Priority:** P1 (Core)
**Complexity:** MEDIUM
**Phase:** MVP - Quality
**Status:** Not Started

---

## Objective

Prepare the app for open source release on GitHub. This includes bug fixes, performance optimization, comprehensive documentation, and setting up the repository for community contributions.

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

### 4. Open Source Documentation

#### README.md (Root)
- [ ] Project title and description
- [ ] Feature highlights with screenshots
- [ ] Tech stack overview
- [ ] Quick start / installation guide
- [ ] Building from source instructions
- [ ] Project structure overview
- [ ] Link to CONTRIBUTING.md
- [ ] License badge and info
- [ ] Credits and acknowledgments

#### CONTRIBUTING.md
- [ ] How to contribute (fork, branch, PR)
- [ ] Code style guidelines
- [ ] Commit message format
- [ ] Pull request template
- [ ] Issue reporting guidelines
- [ ] Development setup instructions
- [ ] Testing requirements before PR

#### LICENSE
- [ ] Choose appropriate license (MIT, Apache 2.0, or GPL)
- [ ] Add LICENSE file to root

#### Other Documentation
- [ ] CODE_OF_CONDUCT.md
- [ ] SECURITY.md (for reporting vulnerabilities)
- [ ] CHANGELOG.md (version history)

### 5. GitHub Repository Setup

- [ ] Create public repository on GitHub
- [ ] Add repository description and topics
- [ ] Configure issue templates (bug report, feature request)
- [ ] Configure pull request template
- [ ] Setup branch protection for main branch
- [ ] Add GitHub Actions for CI (build, test, lint)
- [ ] Create initial GitHub release with APK

### 6. Code Cleanup for Open Source

- [ ] Remove any hardcoded credentials/secrets
- [ ] Add .env.example for environment variables
- [ ] Ensure .gitignore is comprehensive
- [ ] Remove any proprietary/confidential code
- [ ] Add inline code comments for complex logic
- [ ] Verify all dependencies are open source compatible

### 7. Build Configuration

- [ ] Update version number (1.0.0+1)
- [ ] Enable Proguard/R8 optimization
- [ ] Build release APK
- [ ] Test release build on device
- [ ] Document signing process for contributors

---

## App Icon Design

### Requirements
- 1024x1024 pixels (master)
- Simple, recognizable design
- Works at small sizes (16x16)
- No text (may be unreadable)

### Suggested Design
```
Background: Blue (#2563EB - AppColors.primary)
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

## README Template

```markdown
# KASBON - Kasir Digital UMKM 🇮🇩

Aplikasi kasir gratis untuk warung, toko & UMKM Indonesia. Offline-first, mudah digunakan!

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android-green.svg)

## ✨ Features

- 📦 **Product Management** - Kelola produk dengan mudah
- 🛒 **Point of Sale** - Kasir cepat dan simpel
- 📊 **Dashboard** - Lihat ringkasan penjualan
- 💰 **Profit Tracking** - Lacak keuntungan, bukan hanya omzet
- 📝 **Debt Tracking** - Catat hutang pelanggan
- 📱 **Offline First** - Bekerja tanpa internet
- 🔄 **Backup/Restore** - Amankan data Anda

## 📱 Screenshots

[Add screenshots here]

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x
- Android SDK

### Installation
\`\`\`bash
git clone https://github.com/yourusername/kasbon.git
cd kasbon/kasbon-frontend
flutter pub get
flutter run
\`\`\`

### Building APK
\`\`\`bash
flutter build apk --release
\`\`\`

## 🏗️ Architecture

Clean Architecture with feature-based modules. See [CLAUDE.md](CLAUDE.md) for details.

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- Built with Flutter & Riverpod
- Designed for Indonesian UMKM
```

---

## CONTRIBUTING Template

```markdown
# Contributing to KASBON

Terima kasih atas minat Anda untuk berkontribusi! 🎉

## How to Contribute

1. Fork repository ini
2. Buat branch baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

## Development Setup

1. Install Flutter 3.x
2. Clone repo dan jalankan `flutter pub get`
3. Jalankan `dart run build_runner build` untuk code generation
4. Run `flutter test` untuk memastikan semua test passing

## Code Style

- Gunakan `dart format` sebelum commit
- Ikuti arsitektur Clean Architecture yang ada
- Gunakan Modern Widget Library untuk UI
- Tulis test untuk fitur baru

## Commit Messages

Format: `type: description`

Types:
- `feat`: Fitur baru
- `fix`: Bug fix
- `docs`: Dokumentasi
- `style`: Formatting
- `refactor`: Refactoring
- `test`: Testing
- `chore`: Maintenance

## Pull Request

- Pastikan semua test passing
- Update dokumentasi jika diperlukan
- Sertakan screenshot untuk perubahan UI
```

---

## GitHub Actions CI

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: kasbon-frontend

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test

      - name: Build APK
        run: flutter build apk --release
```

---

## Release Build Checklist

### Before Build
- [ ] All tests passing
- [ ] No debug logs in production code
- [ ] Correct version number
- [ ] CHANGELOG.md updated
- [ ] README screenshots updated

### Build Commands
```bash
# Generate release APK (for direct install/GitHub release)
flutter build apk --release

# Output location:
# APK: build/app/outputs/apk/release/app-release.apk
```

### After Build
- [ ] Install release APK on test device
- [ ] Test all features work
- [ ] Check app size (target < 50MB)
- [ ] Verify no crashes

### GitHub Release
- [ ] Create git tag (v1.0.0)
- [ ] Create GitHub release
- [ ] Upload APK as release asset
- [ ] Write release notes

---

## Community & Feedback

### Feedback Channels
- GitHub Issues (bugs, feature requests)
- GitHub Discussions (questions, ideas)
- README contact info

### Issue Templates

**Bug Report:**
```markdown
**Describe the bug**
A clear description of the bug.

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable.

**Device Info:**
- Device: [e.g. Samsung A51]
- Android Version: [e.g. 11]
- App Version: [e.g. 1.0.0]
```

**Feature Request:**
```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
What you want to happen.

**Additional context**
Any other context or screenshots.
```

---

## Acceptance Criteria

### Quality
- [ ] App launches in < 3 seconds
- [ ] No crashes during normal use
- [ ] All features work as expected
- [ ] UI is consistent across screens
- [ ] All text is in Indonesian

### Documentation
- [ ] README.md complete with screenshots
- [ ] CONTRIBUTING.md with clear guidelines
- [ ] LICENSE file added
- [ ] CODE_OF_CONDUCT.md added
- [ ] CHANGELOG.md started

### GitHub Repository
- [ ] Repository is public
- [ ] Issue templates configured
- [ ] PR template configured
- [ ] CI/CD workflow working
- [ ] First release published with APK

### Code Quality
- [ ] No secrets/credentials in code
- [ ] .gitignore comprehensive
- [ ] All dependencies open source compatible
- [ ] Code comments for complex logic

---

## Notes

### Recommended License

**MIT License** - Most permissive, allows commercial use, modification, distribution. Good for maximum adoption.

Alternatively:
- **Apache 2.0** - Similar to MIT but with patent protection
- **GPL v3** - Copyleft, requires derivatives to be open source

### Testing Devices
Test on at least:
- Low-end: 2GB RAM, Android 8
- Mid-range: 4GB RAM, Android 11
- High-end: 8GB RAM, Android 14

### Repository Topics
Add these topics for discoverability:
- `flutter`
- `pos`
- `point-of-sale`
- `indonesia`
- `umkm`
- `offline-first`
- `small-business`
- `kasir`

---

## Estimated Time

**1 week**

---

## Next Task

After open source release is ready, proceed to Phase 2:
- [TASK_017_AUTHENTICATION.md](./TASK_017_AUTHENTICATION.md)
