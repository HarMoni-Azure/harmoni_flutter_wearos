import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static const _deviceIdKey = 'device_id';

  late final String deviceId;
  late final String model;
  late final String os;
  late final String appVersion;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ 앱 재설치 전까지 유지되는 UUID
    deviceId = prefs.getString(_deviceIdKey) ??
        const Uuid().v4();

    prefs.setString(_deviceIdKey, deviceId);

    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    appVersion = packageInfo.version;

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      model = android.model ?? 'unknown';
      os = 'Android ${android.version.release}';
    } else {
      model = 'unknown';
      os = 'unknown';
    }
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'model': model,
    'os': os,
    'appVersion': appVersion,
  };
}
