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

  Future<TopUpInitiation> initiateTopup({
    required int amountKobo,
    required String idempotencyKey,
  }) {
    return remoteDatasource.initiateTopup(
      amountKobo: amountKobo,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<void> verifyTopup(String reference) {
    return remoteDatasource.verifyTopup(reference);
  }

  Future<Map<String, dynamic>> deductWallet({
    required int amountKobo,
    String? orderId,
    String? description,
  }) {
    return remoteDatasource.deductWallet(
      amountKobo: amountKobo,
      orderId: orderId,
      description: description,
    );
  }
}
