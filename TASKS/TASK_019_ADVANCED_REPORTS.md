# TASK_019: Advanced Reports

**Priority:** P2 (Phase 2)
**Complexity:** MEDIUM
**Phase:** Cloud Sync
**Status:** Not Started

---

## Objective

Enhance reporting features with advanced analytics, interactive charts, and export capabilities (Excel/PDF) for Pro tier users.

---

## Prerequisites

- [x] TASK_012: Basic Reports
- [x] TASK_018: Cloud Sync (optional, for cross-device reports)

---

## Subtasks

### 1. Enhanced Charts

- [ ] Sales trend line chart (daily/weekly/monthly)
- [ ] Profit trend line chart
- [ ] Category distribution pie chart
- [ ] Payment method distribution pie chart
- [ ] Hourly sales heatmap

### 2. Advanced Analytics

- [ ] Customer analytics (top customers, customer lifetime value)
- [ ] Inventory turnover analysis
- [ ] Slow-moving products report
- [ ] Peak hours analysis
- [ ] Day-of-week comparison

### 3. Export Features

- [ ] Export to Excel (.xlsx)
  - Transaction history
  - Product list
  - Sales summary
  - Custom date range

- [ ] Export to PDF
  - Sales report
  - Product report
  - Receipt compilation

### 4. Report Customization

- [ ] Custom date range picker
- [ ] Filter by category
- [ ] Filter by payment method
- [ ] Compare periods (this month vs last month)

### 5. Pro-Only Features

- [ ] Feature gate for Free vs Pro
- [ ] Upgrade prompt when accessing Pro features
- [ ] Show preview with blur for Free users

---

## Chart Types

### Sales Trend (Line Chart)
```
Revenue over time with profit overlay

     Revenue ───  Profit ─ ─ ─
     │
 2jt │           ●
     │          /│\
 1.5jt│        /  │ \
     │    ●──/   │  \──●
 1jt │   /       │
     │  /        │
 500k│ ●         │
     │           │
     └─────────────────────────
      Mon Tue Wed Thu Fri Sat Sun
```

### Category Distribution (Pie Chart)
```
Sales by category

       ┌────────────────┐
       │   Makanan 45%  │
       │ ╱─────────╲    │
       │╱ Minuman   ╲   │
       │   30%       ╲  │
       │              ╲ │
       │ Lainnya 25%   ╲│
       └────────────────┘
```

### Hourly Heatmap
```
Sales intensity by hour and day

       00 06 12 18 24
    Mon ░░ ░░ ▓▓ ▓▓ ░░
    Tue ░░ ░░ ▓▓ ██ ░░
    Wed ░░ ░░ ██ ▓▓ ░░
    Thu ░░ ░░ ▓▓ ▓▓ ░░
    Fri ░░ ░░ ██ ██ ░░
    Sat ░░ ▓▓ ██ ██ ░░
    Sun ░░ ▓▓ ▓▓ ░░ ░░

    ░ Low  ▓ Medium  █ High
```

---

## Export Implementation

### Excel Export
```dart
import 'package:excel/excel.dart';

class ExcelExporter {
  Future<File> exportTransactions(
    List<Transaction> transactions,
    DateTimeRange range,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    // Header row
    sheet.appendRow([
      'No',
      'Transaction Number',
      'Date',
      'Customer',
      'Items',
      'Subtotal',
      'Discount',
      'Total',
      'Payment Method',
      'Status',
    ]);

    // Data rows
    for (var i = 0; i < transactions.length; i++) {
      final txn = transactions[i];
      sheet.appendRow([
        i + 1,
        txn.transactionNumber,
        DateFormatter.shortDate(txn.transactionDate),
        txn.customerName ?? '-',
        txn.itemCount,
        txn.subtotal,
        txn.discountAmount,
        txn.total,
        txn.paymentMethod,
        txn.paymentStatus,
      ]);
    }

    // Summary row
    final totalRevenue = transactions.fold(0.0, (sum, t) => sum + t.total);
    sheet.appendRow([]);
    sheet.appendRow(['', '', '', '', '', 'Total:', '', totalRevenue, '', '']);

    // Save file
    final bytes = excel.encode()!;
    final filename = 'kasbon_transactions_${_formatDateRange(range)}.xlsx';
    final file = File('${await _getExportPath()}/$filename');
    await file.writeAsBytes(bytes);

    return file;
  }
}
```

### PDF Export
```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExporter {
  Future<File> exportSalesReport(
    SalesSummary summary,
    List<DailySales> dailySales,
    DateTimeRange range,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Laporan Penjualan',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Periode: ${_formatDateRange(range)}'),
              pw.Divider(),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryBox('Total Penjualan', summary.totalRevenue),
                  _buildSummaryBox('Total Laba', summary.totalProfit),
                  _buildSummaryBox('Transaksi', summary.transactionCount),
                ],
              ),

              // Daily breakdown table
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Tanggal', 'Penjualan', 'Laba', 'Transaksi'],
                data: dailySales.map((d) => [
                  DateFormatter.shortDate(d.date),
                  CurrencyFormatter.format(d.revenue),
                  CurrencyFormatter.format(d.profit),
                  d.transactionCount.toString(),
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Save file
    final bytes = await pdf.save();
    final filename = 'kasbon_sales_${_formatDateRange(range)}.pdf';
    final file = File('${await _getExportPath()}/$filename');
    await file.writeAsBytes(bytes);

    return file;
  }
}
```

---

## UI Specifications

### Advanced Reports Screen
```
┌─────────────────────────────────────┐
│  [<]  Laporan Lanjutan       [PRO]  │
├─────────────────────────────────────┤
│                                      │
│  📅 Desember 2024 [▼]               │
│                                      │
│  TREND PENJUALAN                     │
│  ┌────────────────────────────────┐ │
│  │      LINE CHART                │ │
│  │   Revenue vs Profit            │ │
│  │                                │ │
│  └────────────────────────────────┘ │
│                                      │
│  DISTRIBUSI                          │
│  ┌──────────────┐ ┌──────────────┐  │
│  │  PIE CHART   │ │  PIE CHART   │  │
│  │  Kategori    │ │  Payment     │  │
│  └──────────────┘ └──────────────┘  │
│                                      │
│  JAM RAMAI                           │
│  ┌────────────────────────────────┐ │
│  │     HEATMAP                    │ │
│  │  Penjualan per Jam             │ │
│  └────────────────────────────────┘ │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  EXPORT                              │
│  ┌────────────────┐ ┌────────────┐  │
│  │ 📊 Excel      │ │ 📄 PDF     │  │
│  └────────────────┘ └────────────┘  │
│                                      │
└─────────────────────────────────────┘
```

### Export Options Dialog
```
┌─────────────────────────────────────┐
│         Export Laporan              │
├─────────────────────────────────────┤
│                                      │
│  Pilih data untuk di-export:         │
│                                      │
│  ☑ Riwayat Transaksi                │
│  ☑ Ringkasan Penjualan              │
│  ☐ Daftar Produk                    │
│  ☐ Stok Produk                      │
│                                      │
│  Periode:                            │
│  ┌────────────────────────────────┐ │
│  │ Bulan Ini (Des 2024)         ▼ │ │
│  └────────────────────────────────┘ │
│                                      │
│  Format:                             │
│  ● Excel (.xlsx)                     │
│  ○ PDF (.pdf)                        │
│                                      │
│  ┌────────────────────────────────┐ │
│  │         EXPORT                 │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

---

## Acceptance Criteria

- [ ] Line chart shows sales/profit trend
- [ ] Pie charts show category and payment distribution
- [ ] Heatmap shows hourly sales pattern
- [ ] Can export transactions to Excel
- [ ] Can export sales report to PDF
- [ ] Export files can be shared
- [ ] Custom date range works
- [ ] Filters work correctly
- [ ] Pro-only features are gated
- [ ] Free users see upgrade prompt

---

## Dependencies

```yaml
dependencies:
  excel: ^3.0.0
  pdf: ^3.10.7
  printing: ^5.11.1
```

---

## Notes

### Pro-Only Gating
```dart
Widget build(BuildContext context) {
  final isPro = ref.watch(isProUserProvider);

  if (!isPro) {
    return ProFeaturePrompt(
      feature: 'Laporan Lanjutan',
      previewWidget: BlurredReportPreview(),
    );
  }

  return AdvancedReportsContent();
}
```

### Chart Library
Continue using `fl_chart` for consistency.
Add more chart types as needed.

### Performance
For large datasets:
- Aggregate data on server (if using cloud)
- Cache computed reports
- Paginate transaction lists

---

## Estimated Time

**1 week**

---

## Next Task

After completing this task, proceed to:
- [TASK_020_QRIS_PAYMENT.md](./TASK_020_QRIS_PAYMENT.md)
