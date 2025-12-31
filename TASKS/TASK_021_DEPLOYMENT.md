# TASK_021: Deployment

**Priority:** P2 (Phase 2)
**Complexity:** MEDIUM
**Phase:** Launch
**Status:** Not Started

---

## Objective

Prepare and execute the public launch of KASBON on Google Play Store, including final optimization, marketing materials, and launch execution.

---

## Prerequisites

- [x] All Phase 1 features (001-016)
- [x] Beta testing successful
- [ ] Phase 2 features (017-020) - optional for launch

---

## Subtasks

### 1. Pre-Launch Checklist

#### Technical
- [ ] All critical bugs fixed
- [ ] Performance optimized (< 3s cold start)
- [ ] App size optimized (< 50MB)
- [ ] Crash-free rate > 99%
- [ ] All features tested on multiple devices
- [ ] Release build tested thoroughly

#### Legal
- [ ] Privacy Policy published
- [ ] Terms of Service published
- [ ] NPWP registered (for tax)
- [ ] Business entity (optional for initial launch)

#### Content
- [ ] App store listing finalized
- [ ] All screenshots updated
- [ ] Feature graphic finalized
- [ ] App description in Indonesian
- [ ] Support contact info ready

### 2. Play Store Submission

- [ ] Bump version to 1.0.0
- [ ] Generate signed release AAB
- [ ] Upload AAB to Play Console
- [ ] Complete all store listing sections
- [ ] Set content rating
- [ ] Complete data safety form
- [ ] Set pricing (Free)
- [ ] Set target countries (Indonesia first)
- [ ] Submit for review

### 3. Marketing Preparation

#### Content
- [ ] Create launch announcement (social media)
- [ ] Prepare 10 Instagram posts
- [ ] Create short demo video (TikTok/Reels)
- [ ] Write press release (for tech media)
- [ ] Prepare email for waiting list

#### Channels
- [ ] Instagram (@kasbon.id) ready
- [ ] TikTok (@kasbon.app) ready
- [ ] WhatsApp Business ready
- [ ] Email support ready

### 4. Launch Day Execution

- [ ] Monitor Play Console for review status
- [ ] Post launch announcement
- [ ] Send email to waiting list
- [ ] Post in UMKM communities
- [ ] Engage with early users
- [ ] Monitor crashes (Sentry)

### 5. Post-Launch Monitoring

- [ ] Monitor downloads daily
- [ ] Respond to all reviews
- [ ] Track DAU/MAU
- [ ] Collect user feedback
- [ ] Fix critical bugs quickly
- [ ] Iterate based on feedback

---

## Play Store Submission Checklist

### Required Information

| Item | Status | Notes |
|------|--------|-------|
| App title | | KASBON - Kasir Digital UMKM |
| Short description | | 80 chars |
| Full description | | 4000 chars max |
| App icon | | 512x512 PNG |
| Feature graphic | | 1024x500 PNG |
| Screenshots | | Min 2, max 8 per device type |
| Category | | Business / Finance |
| Content rating | | Complete questionnaire |
| Privacy policy | | URL required |
| Target audience | | 18+ (financial app) |

### Data Safety Form

Answer these questions:
1. Does your app collect or share user data? → Yes (local only for Free)
2. What data types? → Financial info, App activity
3. Is data encrypted? → Yes (secure storage)
4. Can users request data deletion? → Yes (uninstall deletes local data)

### Content Rating

Complete IARC questionnaire:
- Violence: None
- Sexual content: None
- Profanity: None
- Gambling: None
- User interaction: Limited
- Ads: None (for now)

Expected rating: **Everyone (E)**

---

## Release Build Process

### 1. Version Update
```yaml
# pubspec.yaml
version: 1.0.0+1
# Format: MAJOR.MINOR.PATCH+BUILD
```

### 2. Generate Keystore (first time only)
```bash
keytool -genkey -v -keystore kasbon-release.keystore \
  -alias kasbon -keyalg RSA -keysize 2048 -validity 10000
```

### 3. Configure Signing
```properties
# android/key.properties (DO NOT COMMIT)
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=kasbon
storeFile=../kasbon-release.keystore
```

### 4. Build Release AAB
```bash
flutter build appbundle --release
```

### 5. Test Release Build
```bash
# Generate APK from AAB for testing
bundletool build-apks --bundle=app-release.aab \
  --output=app-release.apks \
  --ks=kasbon-release.keystore \
  --ks-key-alias=kasbon

# Install and test
bundletool install-apks --apks=app-release.apks
```

---

## Launch Timeline

### Week Before Launch (W-1)

| Day | Task |
|-----|------|
| Mon | Final testing, fix last bugs |
| Tue | Prepare marketing content |
| Wed | Generate release build, test |
| Thu | Submit to Play Store |
| Fri | Prepare launch posts |
| Sat | Wait for review |
| Sun | Wait for review |

### Launch Week

| Day | Task |
|-----|------|
| Mon | App approved → **LAUNCH!** |
| Tue | Monitor metrics, respond to users |
| Wed | First iteration (quick bug fixes) |
| Thu | Analyze first week data |
| Fri | Plan improvements |

---

## Marketing Launch Plan

### Launch Day Schedule

```
06:00 - App goes live (if approved overnight)
07:00 - Instagram post #1 (Launch announcement)
08:00 - Email blast to waiting list
09:00 - Post in 5 FB Groups UMKM
10:00 - TikTok video post
11:00 - WhatsApp status update
12:00 - LinkedIn post (B2B angle)
14:00 - Instagram Story (behind the scenes)
16:00 - Engage with comments
18:00 - Instagram post #2 (Feature highlight)
20:00 - Review first metrics
22:00 - Plan Day 2
```

### Social Media Content

#### Instagram Post #1 (Launch)
```
🎉 KASBON Sudah Tersedia di Play Store! 🎉

Aplikasi kasir digital GRATIS untuk semua UMKM Indonesia!

✅ Offline-first (tanpa internet)
✅ Mudah digunakan
✅ Lacak untung, bukan cuma omzet
✅ Catat hutang pelanggan
✅ Laporan lengkap

Download GRATIS sekarang!
🔗 Link di bio

#UMKMIndonesia #AplikasiKasir #KasirDigital #Warung #KASBON
```

#### WhatsApp Broadcast
```
Halo! 👋

KASBON sudah bisa didownload di Play Store!

Aplikasi kasir digital GRATIS untuk warung, toko, dan UMKM.

Fitur unggulan:
✅ Bisa dipakai offline
✅ Lacak untung (bukan cuma omzet)
✅ Catat hutang pelanggan
✅ Laporan penjualan lengkap

Download gratis: [LINK]

Terima kasih sudah menunggu! 🙏
```

---

## Success Metrics

### Day 1
- [ ] 50+ downloads
- [ ] No critical crashes
- [ ] First review submitted

### Week 1
- [ ] 200+ downloads
- [ ] 100+ active users
- [ ] 4.0+ star rating
- [ ] 5+ reviews

### Month 1
- [ ] 1,000+ downloads
- [ ] 500+ active users
- [ ] 4.2+ star rating
- [ ] First paying customers (if Pro launched)

---

## Acceptance Criteria

- [ ] App published on Play Store
- [ ] App discoverable by search
- [ ] Download and install works
- [ ] All features work in production
- [ ] No critical bugs in first week
- [ ] User feedback mechanism working
- [ ] Support responding within 24h

---

## Notes

### Play Store Review Time
- First submission: 1-7 days
- Updates: Usually 1-3 days
- Rejections may require resubmission

### Common Rejection Reasons
- Misleading metadata
- Broken functionality
- Policy violations
- Missing privacy policy

### Emergency Hotfix Process
1. Fix bug in code
2. Bump build number (1.0.0+2)
3. Build and test release
4. Upload to Play Console
5. Request expedited review (if critical)

### Monitoring Tools
- Play Console: Downloads, ratings, crashes
- Firebase Analytics: User behavior
- Sentry: Crash reports
- WhatsApp: User feedback

---

## Estimated Time

**1 week** (including review wait)

---

## Congratulations!

After completing this task, you've successfully launched KASBON! 🎉

### What's Next?
1. Monitor and iterate based on feedback
2. Grow user base organically
3. Add Phase 2 features for Pro tier
4. Scale marketing efforts
5. Build community

**Good luck with KASBON!** 🚀
