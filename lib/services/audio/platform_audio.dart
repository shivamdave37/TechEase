import 'platform_audio_interface.dart';
import 'platform_audio_stub.dart'
    if (dart.library.js_interop) 'platform_audio_web.dart';

export 'platform_audio_interface.dart';

PlatformAudio getPlatformAudio() => createPlatformAudio();
