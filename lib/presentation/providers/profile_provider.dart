import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/profile_remote_datasource.dart';
import 'package:mummymap/data/models/profile_model.dart';
import 'package:mummymap/domain/repositories/profile_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';

final profileDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasource(ref.watch(dioProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileDatasourceProvider));
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  final ProfileRepository _repository;

  bool imageUploadFailed = false;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMyProfile();
  }

  Future<void> loadMyProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getMyProfile();
      state = AsyncValue.data(profile);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ProfileModel> submitSetup({
    required ProfileModel profile,
    String? imagePath,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createProfile(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        await _repository.uploadImage(imagePath);
      } catch (_) {
        imageUploadFailed = true;
      }
    }

    final fresh = await _repository.getMyProfile();
    state = AsyncValue.data(fresh);
    return fresh;
  }

  Future<void> changePhoto(String imagePath) async {
    try {
      await _repository.uploadImage(imagePath);
      final fresh = await _repository.getMyProfile();
      state = AsyncValue.data(fresh);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateFields(ProfileModel updated, {String? imagePath}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProfile(updated);
      if (imagePath != null && imagePath.isNotEmpty) {
        await _repository.uploadImage(imagePath);
      }
      final fresh = await _repository.getMyProfile();
      state = AsyncValue.data(fresh);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>(
  (ref) => ProfileNotifier(ref.watch(profileRepositoryProvider)),
);