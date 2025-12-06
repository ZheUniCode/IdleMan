
import 'idleman_native_platform_interface.dart';

class IdlemanNative {
  Future<String?> getPlatformVersion() {
    return IdlemanNativePlatform.instance.getPlatformVersion();
  }
}
