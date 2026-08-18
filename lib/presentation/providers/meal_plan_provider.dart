import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/track_models.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';

final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, AsyncValue<List<MealItem>>>((ref) {
  return MealPlanNotifier(ref);
});

class MealPlanNotifier extends StateNotifier<AsyncValue<List<MealItem>>> {
  final Ref ref;

  MealPlanNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchMeals();
  }

  Future<void> fetchMeals() async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/meal-plans', queryParameters: {
        'status': 'APPROVED',
        'isActive': true,
      });
      final data = response.data['data'] as List? ?? response.data as List;
      final meals = data.map((e) => MealItem.fromJson(e as Map<String, dynamic>)).toList();
      state = AsyncValue.data(meals);
    } catch (e, st) {
      
      state = AsyncValue.error(e, st);
    }
  }
}
