# TASK_020: QRIS Payment Integration

**Priority:** P2 (Phase 2)
**Complexity:** HIGH
**Phase:** Cloud Sync
**Status:** Not Started

---

## Objective

Integrate QRIS (Quick Response Code Indonesian Standard) payment via Xendit payment gateway, allowing customers to pay using e-wallets (GoPay, Dana, OVO, ShopeePay, etc.).

---

## Prerequisites

- [x] TASK_017: Authentication (for API key management)
- [x] TASK_018: Cloud Sync (for webhook handling)
- [ ] Business entity registration (CV/PT for Xendit)
- [ ] Xendit account approval

---

## Subtasks

### 1. Xendit Setup

- [ ] Register Xendit account
- [ ] Complete business verification
- [ ] Get API keys (development & production)
- [ ] Configure webhook URL
- [ ] Test sandbox transactions

### 2. Backend Integration (Supabase Edge Function)

- [ ] Create Edge Function: `create-qris-payment`
- [ ] Create Edge Function: `handle-payment-webhook`
- [ ] Secure API key storage
- [ ] Implement idempotency

### 3. Flutter Integration

- [ ] Add HTTP client (dio)
- [ ] Create `lib/features/payment/data/datasources/payment_remote_datasource.dart`
- [ ] Create payment repository

### 4. QR Code Display

- [ ] Create `lib/features/payment/presentation/screens/qris_payment_screen.dart`
- [ ] Display QR code
- [ ] Show payment amount
- [ ] Handle timeout
- [ ] Poll for payment status

### 5. Payment Verification

- [ ] Listen for webhook
- [ ] Update transaction status
- [ ] Handle success/failure

### 6. POS Integration

- [ ] Add QRIS option to payment methods
- [ ] Update payment flow
- [ ] Handle async payment completion

---

## Xendit Configuration

### API Endpoints
```
Sandbox: https://api.xendit.co/qr_codes
Production: https://api.xendit.co/qr_codes

Create QR Code: POST /qr_codes
Get QR Code: GET /qr_codes/{qr_code_id}
```

### Request Format
```json
POST /qr_codes
{
  "external_id": "kasbon-txn-20241215-0001",
  "type": "DYNAMIC",
  "callback_url": "https://your-webhook-url.com/xendit-callback",
  "amount": 45000,
  "currency": "IDR",
  "channel_code": "QRIS"
}
```

### Response Format
```json
{
  "id": "qr_xxx",
  "external_id": "kasbon-txn-20241215-0001",
  "qr_string": "00020101021126580014ID.LINKAJA...",
  "type": "DYNAMIC",
  "status": "ACTIVE",
  "amount": 45000,
  "created": "2024-12-15T14:30:00.000Z",
  "updated": "2024-12-15T14:30:00.000Z"
}
```

### Webhook Payload
```json
{
  "event": "qr.payment",
  "business_id": "xxx",
  "data": {
    "id": "qr_xxx",
    "external_id": "kasbon-txn-20241215-0001",
    "amount": 45000,
    "status": "COMPLETED",
    "payment_detail": {
      "source": "GOPAY",
      "name": "John Doe"
    }
  }
}
```

---

## Supabase Edge Function

### create-qris-payment
```typescript
// supabase/functions/create-qris-payment/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const XENDIT_API_KEY = Deno.env.get('XENDIT_API_KEY')

serve(async (req) => {
  const { external_id, amount } = await req.json()

  const response = await fetch('https://api.xendit.co/qr_codes', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${btoa(XENDIT_API_KEY + ':')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      external_id,
      type: 'DYNAMIC',
      amount,
      currency: 'IDR',
      callback_url: `${Deno.env.get('SUPABASE_URL')}/functions/v1/xendit-webhook`,
    }),
  })

  const data = await response.json()
  return new Response(JSON.stringify(data), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### xendit-webhook
```typescript
// supabase/functions/xendit-webhook/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from '@supabase/supabase-js'

serve(async (req) => {
  // Verify webhook signature
  const webhookToken = req.headers.get('x-callback-token')
  if (webhookToken !== Deno.env.get('XENDIT_WEBHOOK_TOKEN')) {
    return new Response('Unauthorized', { status: 401 })
  }

  const payload = await req.json()

  if (payload.event === 'qr.payment' && payload.data.status === 'COMPLETED') {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_KEY')!
    )

    // Update transaction status
    await supabase
      .from('transactions')
      .update({
        payment_status: 'paid',
        updated_at: new Date().toISOString(),
      })
      .eq('transaction_number', payload.data.external_id)
  }

  return new Response('OK', { status: 200 })
})
```

---

## UI Specifications

### QRIS Payment Screen
```
┌─────────────────────────────────────┐
│  [<]  Pembayaran QRIS               │
├─────────────────────────────────────┤
│                                      │
│        Total: Rp 45.000              │
│                                      │
│  ┌────────────────────────────────┐ │
│  │                                │ │
│  │      ┌────────────────┐        │ │
│  │      │                │        │ │
│  │      │    QR CODE     │        │ │
│  │      │                │        │ │
│  │      └────────────────┘        │ │
│  │                                │ │
│  │  Scan dengan aplikasi e-wallet │ │
│  │  GoPay, Dana, OVO, ShopeePay   │ │
│  │                                │ │
│  └────────────────────────────────┘ │
│                                      │
│  ⏱️  Berlaku hingga: 10:25:30       │
│                                      │
│  Menunggu pembayaran...             │
│  [○○○○○]                            │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      Batalkan & Bayar Cash     │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Payment Success
```
┌─────────────────────────────────────┐
│                                      │
│              ✅                      │
│                                      │
│      Pembayaran Berhasil!           │
│                                      │
│      Rp 45.000                       │
│      via GoPay                       │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  TRX-20241215-0001                   │
│  15 Des 2024, 14:30                  │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      Lihat Struk               │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │      Transaksi Baru            │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

---

## Payment Flow

```
User selects QRIS
       │
       ▼
Create pending transaction (local)
       │
       ▼
Call Edge Function: create-qris-payment
       │
       ▼
Xendit returns QR code
       │
       ▼
Display QR code to user
       │
       ▼
Customer scans & pays
       │
       ▼
Xendit sends webhook
       │
       ▼
Edge Function updates transaction
       │
       ▼
App polls for status change
       │
       ▼
Show success screen
       │
       ▼
Reduce stock
       │
       ▼
Generate receipt
```

---

## Acceptance Criteria

- [ ] Can select QRIS as payment method
- [ ] QR code displays correctly
- [ ] Timer shows remaining time
- [ ] Payment updates transaction status
- [ ] Stock reduces after successful payment
- [ ] Can cancel and switch to cash
- [ ] Handles timeout gracefully
- [ ] Works with major e-wallets (GoPay, Dana, OVO)
- [ ] Webhook handles payment correctly

---

## Notes

### Business Requirements
Xendit requires:
- Legal business entity (CV/PT)
- NPWP
- Bank account
- Business verification

This may take 1-2 weeks to set up.

### Transaction Fees
- QRIS: 0.7% per transaction
- Minimum fee: Rp 0
- Settled: T+1 (next business day)

### Testing
Use Xendit sandbox for testing.
Sandbox allows simulating success/failure.

### Timeout
QR codes expire after 15 minutes.
Show countdown timer.
Handle expiry gracefully.

### Offline Handling
QRIS requires internet.
If offline, show message and offer cash payment.

---

## Dependencies

```yaml
dependencies:
  dio: ^5.4.0
  qr_flutter: ^4.1.0  # For displaying QR code
```

---

## Estimated Time

**2 weeks** (including Xendit setup)

---

## Next Task

After completing this task, proceed to:
- [TASK_021_DEPLOYMENT.md](./TASK_021_DEPLOYMENT.md)
