import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/settings_service.dart';
import 'core/utils/elevenlabs_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.init();
  await ElevenLabsService.init();

  // Debug: Print ElevenLabs status
  debugPrint('ElevenLabs enabled: ${SettingsService.elevenLabsEnabled}');
  debugPrint('ElevenLabs API key present: ${SettingsService.elevenLabsApiKey.isNotEmpty}');
  debugPrint('ElevenLabs available: ${ElevenLabsService.isAvailable}');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const KidsEduApp());
}

class KidsEduApp extends StatelessWidget {
  const KidsEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Learning Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
