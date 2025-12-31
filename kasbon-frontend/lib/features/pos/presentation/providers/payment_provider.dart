import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di/injection.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/create_transaction.dart';
import 'cart_provider.dart';

/// Payment state for tracking payment processing
class PaymentState {
  /// Whether payment is being processed
  final bool isProcessing;

  /// Error message if payment failed
  final String? errorMessage;

  /// The completed transaction after successful payment
  final Transaction? completedTransaction;

  const PaymentState({
    this.isProcessing = false,
    this.errorMessage,
    this.completedTransaction,
  });

  /// Check if payment was successful
  bool get isSuccess => completedTransaction != null;

  /// Check if there was an error
  bool get hasError => errorMessage != null;

  /// Create a copy with updated fields
  PaymentState copyWith({
    bool? isProcessing,
    String? errorMessage,
    Transaction? completedTransaction,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      completedTransaction: completedTransaction ?? this.completedTransaction,
    );
  }
}

/// Payment state notifier for processing payments
class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref _ref;

  PaymentNotifier(this._ref) : super(const PaymentState());

  /// Process a cash payment
  ///
  /// Takes the cash received amount, creates a transaction,
  /// and clears the cart on success.
  Future<void> processPayment({
    required double cashReceived,
    String? customerName,
    String? notes,
  }) async {
    // Set processing state
    state = const PaymentState(isProcessing: true);

    // Get cart items
    final cart = _ref.read(cartProvider);

    if (cart.isEmpty) {
      state = const PaymentState(
        errorMessage: 'Keranjang tidak boleh kosong',
      );
      return;
    }

    // Get total to validate cash amount
    final total = _ref.read(cartTotalProvider);

    if (cashReceived < total) {
      state = const PaymentState(
        errorMessage: 'Uang yang diterima kurang dari total',
      );
      return;
    }

    // Create transaction
    final useCase = getIt<CreateTransaction>();
    final result = await useCase(CreateTransactionParams(
      cartItems: cart,
      cashReceived: cashReceived,
      customerName: customerName,
      notes: notes,
    ));

    result.fold(
      (failure) {
        // Payment failed
        state = PaymentState(errorMessage: failure.message);
      },
      (transaction) {
        // Payment successful - clear cart
        _ref.read(cartProvider.notifier).clear();
        state = PaymentState(completedTransaction: transaction);
      },
    );
  }

  /// Reset payment state
  void reset() {
    state = const PaymentState();
  }
}

/// Payment provider
final paymentProvider =
    StateNotifierProvider.autoDispose<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref);
});

/// Provider for the last completed transaction
/// Useful for showing on success screen
final lastCompletedTransactionProvider = Provider<Transaction?>((ref) {
  return ref.watch(paymentProvider).completedTransaction;
});
