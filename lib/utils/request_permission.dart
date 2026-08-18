import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCallPermissions() async {
  final statuses = await [
    Permission.camera,
    Permission.microphone,
  ].request();

  return statuses.values.every((status) => status.isGranted);
}