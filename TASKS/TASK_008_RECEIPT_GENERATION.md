# TASK_008: Receipt Generation

**Priority:** P0 (Critical)
**Complexity:** LOW
**Phase:** MVP
**Status:** Not Started

---

## Objective

Generate digital receipts that can be copied to clipboard or shared via WhatsApp and other apps.

---

## Prerequisites

- [x] TASK_005: POS System
- [x] TASK_006: Transaction Management
- [x] TASK_013: Settings (shop profile) - partial, need shop name/address

---

## Subtasks

### 1. Receipt Generator

- [ ] Create `lib/features/transactions/domain/usecases/generate_receipt.dart`
  - Takes Transaction entity
  - Returns formatted string

- [ ] Create `lib/core/utils/receipt_generator.dart`
  - formatReceipt(Transaction, ShopSettings)
  - Text-based receipt format
  - Supports Indonesian number format

### 2. Sharing Functionality

- [ ] Create `lib/shared/utils/share_helper.dart`
  - shareText(String text)
  - copyToClipboard(String text)
  - shareViaWhatsApp(String text, String? phoneNumber)

### 3. UI Components

- [ ] Create `lib/features/transactions/presentation/widgets/receipt_preview.dart`
  - Scrollable text view
  - Monospace font
  - Receipt border styling

- [ ] Create `lib/features/transactions/presentation/screens/receipt_screen.dart`
  - Receipt preview
  - Copy button
  - Share button
  - WhatsApp share button

### 4. Integration

- [ ] Add receipt button to Transaction Detail screen
- [ ] Add receipt view after successful transaction
- [ ] Store receipt preferences in settings

---

## Receipt Format

```
========================================
        WARUNG BU SITI
    Jl. Raya No. 123, Jakarta
        0812-3456-7890
========================================
No: TRX-20241215-0003
Tanggal: 15 Des 2024, 14:30
Kasir: Admin
----------------------------------------
Item                    Qty     Subtotal
----------------------------------------
Indomie Goreng           2     Rp  7.000
Aqua 600ml               3     Rp 12.000
Teh Botol Sosro          5     Rp 25.000
----------------------------------------
                 Subtotal: Rp    44.000
                  Diskon:  Rp         0
                   TOTAL:  Rp    44.000
----------------------------------------
            Uang Diterima: Rp    50.000
              Kembalian:   Rp     6.000
========================================
   Terima kasih atas kunjungannya!
       Powered by KASBON
========================================
```

---

## Receipt Generator Code

```dart
class ReceiptGenerator {
  static const int lineWidth = 42;
  static const String divider = '─' * lineWidth;
  static const String doubleLine = '═' * lineWidth;

  static String generate({
    required Transaction transaction,
    required ShopSettings shop,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(doubleLine);
    buffer.writeln(_centerText(shop.name.toUpperCase()));
    if (shop.address != null && shop.address!.isNotEmpty) {
      buffer.writeln(_centerText(shop.address!));
    }
    if (shop.phone != null && shop.phone!.isNotEmpty) {
      buffer.writeln(_centerText(shop.phone!));
    }
    buffer.writeln(doubleLine);

    // Transaction Info
    buffer.writeln('No: ${transaction.transactionNumber}');
    buffer.writeln('Tanggal: ${_formatDate(transaction.transactionDate)}');
    if (transaction.cashierName != null) {
      buffer.writeln('Kasir: ${transaction.cashierName}');
    }
    buffer.writeln(divider);

    // Column Headers
    buffer.writeln(_formatItemHeader());
    buffer.writeln(divider);

    // Items
    for (final item in transaction.items) {
      buffer.writeln(_formatItem(item));
    }
    buffer.writeln(divider);

    // Totals
    buffer.writeln(_formatTotal('Subtotal', transaction.subtotal));
    if (transaction.discountAmount > 0) {
      buffer.writeln(_formatTotal('Diskon', transaction.discountAmount));
    }
    buffer.writeln(_formatTotal('TOTAL', transaction.total, bold: true));
    buffer.writeln(divider);

    // Payment Info
    if (transaction.cashReceived != null) {
      buffer.writeln(_formatTotal('Uang Diterima', transaction.cashReceived!));
      buffer.writeln(_formatTotal('Kembalian', transaction.cashChange ?? 0));
    }

    // Footer
    buffer.writeln(doubleLine);
    buffer.writeln(_centerText('Terima kasih atas kunjungannya!'));
    buffer.writeln(_centerText('Powered by KASBON'));
    buffer.writeln(doubleLine);

    return buffer.toString();
  }

  static String _centerText(String text) {
    if (text.length >= lineWidth) return text;
    final padding = (lineWidth - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  static String _formatDate(DateTime date) {
    return DateFormatter.full(date);
  }

  static String _formatItemHeader() {
    return 'Item                    Qty     Subtotal';
  }

  static String _formatItem(TransactionItem item) {
    final name = item.productName.length > 20
        ? item.productName.substring(0, 20)
        : item.productName.padRight(20);
    final qty = item.quantity.toString().padLeft(5);
    final subtotal = _formatCurrency(item.subtotal).padLeft(12);
    return '$name $qty $subtotal';
  }

  static String _formatTotal(String label, double amount, {bool bold = false}) {
    final formattedLabel = label.padLeft(25);
    final formattedAmount = _formatCurrency(amount).padLeft(lineWidth - 27);
    return '$formattedLabel: $formattedAmount';
  }

  static String _formatCurrency(double amount) {
    return CurrencyFormatter.format(amount);
  }
}
```

---

## Share Helper

```dart
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareHelper {
  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Share via system share sheet
  static Future<void> share(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Share specifically via WhatsApp
  static Future<bool> shareViaWhatsApp(String text, {String? phoneNumber}) async {
    final encodedText = Uri.encodeComponent(text);
    final Uri whatsappUri;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Direct message to specific number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      whatsappUri = Uri.parse('https://wa.me/$cleanNumber?text=$encodedText');
    } else {
      // Open WhatsApp with text, user picks contact
      whatsappUri = Uri.parse('whatsapp://send?text=$encodedText');
    }

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
```

---

## UI Specifications

### Receipt Screen
```
┌─────────────────────────────────────┐
│  [<]  Struk Transaksi               │
├─────────────────────────────────────┤
│  ┌────────────────────────────────┐ │
│  │ ════════════════════════════   │ │
│  │        WARUNG BU SITI          │ │
│  │    Jl. Raya No. 123            │ │
│  │        0812-3456-7890          │ │
│  │ ════════════════════════════   │ │
│  │ No: TRX-20241215-0003          │ │
│  │ Tanggal: 15 Des 2024, 14:30    │ │
│  │ ────────────────────────────   │ │
│  │ Item           Qty    Subtotal │ │
│  │ ────────────────────────────   │ │
│  │ Indomie Goreng   2    Rp 7.000 │ │
│  │ Aqua 600ml       3   Rp 12.000 │ │
│  │ Teh Botol        5   Rp 25.000 │ │
│  │ ────────────────────────────   │ │
│  │          TOTAL: Rp 44.000      │ │
│  │ ════════════════════════════   │ │
│  │    Terima kasih!               │ │
│  │    Powered by KASBON           │ │
│  │ ════════════════════════════   │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      📋 Salin Struk            │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │      📤 Bagikan                │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │      💬 Kirim ke WhatsApp      │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

---

## Acceptance Criteria

- [ ] Receipt generates correctly with all transaction data
- [ ] Shop name, address, phone shown in header
- [ ] All items listed with quantity and subtotal
- [ ] Totals calculated correctly
- [ ] Payment info shown (cash received, change)
- [ ] "Copy to clipboard" works with feedback
- [ ] "Share" opens system share sheet
- [ ] "WhatsApp" opens WhatsApp with receipt text
- [ ] Receipt uses monospace-like formatting
- [ ] Works with Indonesian currency format

---

## Dependencies to Add

```yaml
dependencies:
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
```

---

## Notes

### Monospace Display
For receipt preview, use monospace font:
```dart
Text(
  receiptText,
  style: TextStyle(
    fontFamily: 'monospace', // or 'RobotoMono'
    fontSize: 12,
  ),
)
```

### Character Width
Receipt is designed for 42 characters width.
Fits nicely on most thermal printers (58mm paper).

### Future: PDF Receipt
PDF generation will be added in v1.1.
Current MVP uses text-based receipt.

### Future: Thermal Print
Bluetooth thermal printing will be added in v1.2.
Requires significant testing with different printer models.

---

## Estimated Time

**2 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_009_STOCK_TRACKING.md](./TASK_009_STOCK_TRACKING.md)
