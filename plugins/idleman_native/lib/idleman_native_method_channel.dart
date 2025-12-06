import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'idleman_native_platform_interface.dart';

/// An implementation of [IdlemanNativePlatform] that uses method channels.
class MethodChannelIdlemanNative extends IdlemanNativePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('idleman_native');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
