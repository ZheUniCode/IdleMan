import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'idleman_native_method_channel.dart';

abstract class IdlemanNativePlatform extends PlatformInterface {
  /// Constructs a IdlemanNativePlatform.
  IdlemanNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static IdlemanNativePlatform _instance = MethodChannelIdlemanNative();

  /// The default instance of [IdlemanNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelIdlemanNative].
  static IdlemanNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IdlemanNativePlatform] when
  /// they register themselves.
  static set instance(IdlemanNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
