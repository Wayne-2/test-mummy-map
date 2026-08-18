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

  WalletNotifier(this._ref, this._repo) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> initiateTopup({
    required double amount,
    required String reference,
    required String idempotencyKey,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repo.initiateTopup(
        amount: amount,
        reference: reference,
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
}

final walletNotifierProvider = StateNotifierProvider<WalletNotifier, AsyncValue<void>>((ref) {
  return WalletNotifier(ref, ref.watch(walletRepositoryProvider));
});
