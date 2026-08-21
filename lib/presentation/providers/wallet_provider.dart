import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/wallet_remote_datasource.dart';
import 'package:mummymap/data/models/wallet_model.dart';
import 'package:mummymap/domain/repositories/wallet_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';

final walletRemoteDatasourceProvider = Provider<WalletRemoteDatasource>((ref) {
  return WalletRemoteDatasource(ref.watch(dioProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(
    remoteDatasource: ref.watch(walletRemoteDatasourceProvider),
  );
});

final walletBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getWalletBalance();
});

final walletTransactionsProvider = FutureProvider.autoDispose<List<WalletTransaction>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getTransactions();
});

class WalletNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final WalletRepository _repo;

  static const int _minTopupKobo = 10000;

  WalletNotifier(this._ref, this._repo) : super(const AsyncData(null));

  Future<TopUpInitiation?> initiateTopup({
    required double amountNgn,
    required String idempotencyKey,
  }) async {
    final amountKobo = (amountNgn * 100).round();
    if (amountKobo < _minTopupKobo) {
      state = AsyncError(
        'Minimum top-up is ₦100.',
        StackTrace.current,
      );
      return null;
    }
    state = const AsyncLoading();
    try {
      final result = await _repo.initiateTopup(
        amountKobo: amountKobo,
        idempotencyKey: idempotencyKey,
      );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> verifyTopup(String reference) async {
    state = const AsyncLoading();
    try {
      await _repo.verifyTopup(reference);
      // Refresh the balance and transactions
      _ref.invalidate(walletBalanceProvider);
      _ref.invalidate(walletTransactionsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<Map<String, dynamic>?> deductWallet({
    required double amountNgn,
    String? orderId,
    String? description,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repo.deductWallet(
        amountKobo: (amountNgn * 100).round(),
        orderId: orderId,
        description: description,
      );
      _ref.invalidate(walletBalanceProvider);
      _ref.invalidate(walletTransactionsProvider);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final walletNotifierProvider = StateNotifierProvider<WalletNotifier, AsyncValue<void>>((ref) {
  return WalletNotifier(ref, ref.watch(walletRepositoryProvider));
});
