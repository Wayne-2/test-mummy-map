import 'package:mummymap/data/datasources/wallet_remote_datasource.dart';
import 'package:mummymap/data/models/wallet_model.dart';

class WalletRepository {
  final WalletRemoteDatasource remoteDatasource;

  WalletRepository({required this.remoteDatasource});

  Future<double> getWalletBalance() {
    return remoteDatasource.getWalletBalance();
  }

  Future<List<WalletTransaction>> getTransactions() {
    return remoteDatasource.getTransactions();
  }

  Future<Map<String, dynamic>> initiateTopup({
    required double amount,
    required String reference,
    required String idempotencyKey,
  }) {
    return remoteDatasource.initiateTopup(
      amount: amount,
      reference: reference,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<void> verifyTopup(String reference) {
    return remoteDatasource.verifyTopup(reference);
  }

  Future<void> deductWallet(double amount) {
    return remoteDatasource.deductWallet(amount);
  }
}
