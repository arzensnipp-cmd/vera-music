import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> requestStorageAndNotifications() async {
    final statuses = await [
      Permission.storage,
      Permission.notification,
    ].request();

    final granted = statuses.values.every((status) => status.isGranted || status.isLimited);
    return granted;
  }

  Future<bool> requestAllPermissions() async {
    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }
    return await requestStorageAndNotifications();
  }
}
