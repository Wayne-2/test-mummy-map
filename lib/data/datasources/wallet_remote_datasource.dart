import 'package:dio/dio.dart';
import 'package:mummymap/data/models/wallet_model.dart';

class WalletRemoteDatasource {
  final Dio dio;

  WalletRemoteDatasource(this.dio);

  Future<double> getWalletBalance() async {
    final res = await dio.get('/api/v1/wallet');
    final data = res.data;
    if (data is Map<String, dynamic> && data['balance'] != null) {
      return double.tryParse(data['balance'].toString()) ?? 0.0;
    } else if (data is Map<String, dynamic> && data['data'] != null && data['data']['balance'] != null) {
      return double.tryParse(data['data']['balance'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  Future<List<WalletTransaction>> getTransactions() async {
    final res = await dio.get('/api/v1/wallet/transactions');
    final data = res.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).map((e) => WalletTransaction.fromJson(e)).toList();
    } else if (data is List) {
      return data.map((e) => WalletTransaction.fromJson(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> initiateTopup({
    required double amount,
    required String reference,
    required String idempotencyKey,
  }) async {
    final res = await dio.post(
      '/api/v1/wallet/topup',
      data: {
        'amount': amount,
        'reference': reference,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    
    // Unpack data object if it exists
    if (res.data is Map<String, dynamic>) {
      if (res.data['data'] != null && res.data['data'] is Map<String, dynamic>) {
        return res.data['data'] as Map<String, dynamic>;
      }
      return res.data as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> verifyTopup(String reference) async {
    await dio.get(
      '/api/v1/wallet/topup/verify',
      queryParameters: {'reference': reference},
    );
  }

  Future<void> deductWallet(double amount) async {
    await dio.post('/api/v1/wallet/deduct', data: {'amount': amount});
  }
}
