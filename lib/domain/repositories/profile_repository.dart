import 'package:mummymap/data/datasources/profile_remote_datasource.dart';
import 'package:mummymap/data/models/profile_model.dart';

class ProfileRepository {
  final ProfileRemoteDatasource datasource;

  ProfileRepository(this.datasource);

  Future<ProfileModel> createProfile(ProfileModel profile) {
    return datasource.createProfile(profile.toCreateJson());
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) {
    return datasource.updateProfile(profile.toUpdateJson());
  }

  Future<ProfileModel> getMyProfile() {
    return datasource.getMyProfile();
  }

  Future<void> uploadImage(String filePath) {
    return datasource.uploadImage(filePath);
  }

  Future<void> deleteImage() {
    return datasource.deleteImage();
  }

  Future<void> updatePrivacy({
    bool? showEmail,
    bool? showPhone,
    bool? showLocation,
    String? profileVisibility,
  }) {
    return datasource.updatePrivacy(
      showEmail: showEmail,
      showPhone: showPhone,
      showLocation: showLocation,
      profileVisibility: profileVisibility,
    );
  }
}