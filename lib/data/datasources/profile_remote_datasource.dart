import 'package:dio/dio.dart';
import 'package:mummymap/data/models/profile_model.dart';

class ProfileRemoteDatasource {
  final Dio dio;

  ProfileRemoteDatasource(this.dio);

 
  Future<ProfileModel> createProfile(Map<String, dynamic> body) async {
    final res = await dio.post('/api/v1/profile', data: body);
    return ProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  
  Future<ProfileModel> updateProfile(Map<String, dynamic> body) async {
    final res = await dio.put('/api/v1/profile', data: body);
    return ProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  
  Future<ProfileModel> getMyProfile() async {
    final res = await dio.get('/api/v1/profile/me');
    return ProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  
  Future<void> uploadImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    await dio.post('/api/v1/profile/upload-image', data: form);
  }

  
  Future<void> deleteImage() async {
    await dio.delete('/api/v1/profile/delete-image');
  }

  
  Future<void> updatePrivacy({
    bool? showEmail,
    bool? showPhone,
    bool? showLocation,
    String? profileVisibility, 
  }) async {
    final body = <String, dynamic>{
      'showEmail': showEmail,
      'showPhone': showPhone,
      'showLocation': showLocation,
      'profileVisibility': profileVisibility,
    }..removeWhere((_, v) => v == null);
    await dio.patch('/api/v1/profile/privacy', data: body);
  }
}