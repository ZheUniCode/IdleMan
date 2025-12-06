import 'package:flutter_test/flutter_test.dart';
import 'package:idleman_native/idleman_native.dart';
import 'package:idleman_native/idleman_native_platform_interface.dart';
import 'package:idleman_native/idleman_native_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIdlemanNativePlatform
    with MockPlatformInterfaceMixin
    implements IdlemanNativePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IdlemanNativePlatform initialPlatform = IdlemanNativePlatform.instance;

  test('$MethodChannelIdlemanNative is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIdlemanNative>());
  });

  test('getPlatformVersion', () async {
    IdlemanNative idlemanNativePlugin = IdlemanNative();
    MockIdlemanNativePlatform fakePlatform = MockIdlemanNativePlatform();
    IdlemanNativePlatform.instance = fakePlatform;

    expect(await idlemanNativePlugin.getPlatformVersion(), '42');
  });
}
