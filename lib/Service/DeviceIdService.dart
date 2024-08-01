import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static final Uuid _uuid = Uuid();

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId != null) {
      return deviceId;
    } else {
      deviceId = await _generateUniqueId();
      await prefs.setString('device_id', deviceId);
      return deviceId;
    }
  }

  static Future<String> _generateUniqueId() async {
    String uniqueId;

    try {
      if (await _isAndroid()) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        uniqueId = androidInfo.id ?? _uuid.v4();
      } else if (await _isiOS()) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        uniqueId = iosInfo.identifierForVendor ?? _uuid.v4();
      } else {
        uniqueId = _uuid.v4();
      }
    } catch (e) {
      uniqueId = _uuid.v4();
    }

    return uniqueId;
  }

  static Future<bool> _isAndroid() async {
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    return deviceInfo is AndroidDeviceInfo;
  }

  static Future<bool> _isiOS() async {
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    return deviceInfo is IosDeviceInfo;
  }
}
