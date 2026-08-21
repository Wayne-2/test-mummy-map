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

  Future<TopUpInitiation> initiateTopup({
    required int amountKobo,
    required String idempotencyKey,
  }) async {
    final res = await dio.post(
      '/api/v1/wallet/topup',
      data: {
        'amount': amountKobo,
        'provider': 'PAYSTACK',
        'idempotencyKey': idempotencyKey,
      },
    );
    return TopUpInitiation.fromJson(_unwrapData(res.data));
  }

  Future<void> verifyTopup(String reference) async {
    await dio.get(
      '/api/v1/wallet/topup/verify',
      queryParameters: {'reference': reference},
    );
  }

  Future<Map<String, dynamic>> deductWallet({
    required int amountKobo,
    String? orderId,
    String? description,
  }) async {
    final res = await dio.post(
      '/api/v1/wallet/deduct',
      data: {
        'amount': amountKobo,
        if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    return _unwrapData(res.data);
  }

  Map<String, dynamic> _unwrapData(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    return {};
  }
}
