import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static final Uuid _uuid = Uuid();

  // Retorna o ID único do dispositivo
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

  // Gera um ID único para o dispositivo
  static Future<String> _generateUniqueId() async {
    String uniqueId;

    try {
      if (await _isAndroid()) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        uniqueId = androidInfo.id ?? _uuid.v4(); // ID do Android
      } else if (await _isiOS()) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        uniqueId = iosInfo.identifierForVendor ?? _uuid.v4(); // ID do iOS
      } else {
        uniqueId = _uuid.v4(); // Fallback se a plataforma não for reconhecida
      }
    } catch (e) {
      uniqueId = _uuid.v4(); // Fallback em caso de erro
    }

    return uniqueId;
  }

  // Verifica se o dispositivo é Android
  static Future<bool> _isAndroid() async {
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    return deviceInfo is AndroidDeviceInfo;
  }

  // Verifica se o dispositivo é iOS
  static Future<bool> _isiOS() async {
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    return deviceInfo is IosDeviceInfo;
  }
}
