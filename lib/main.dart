// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:rsmss/core/di/service_locator.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:rsmss/l10n/app_localizations.dart';

// // Pastikan path import ini sesuai dengan struktur folder Anda
// import 'package:rsmss/views/main_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   const storage = FlutterSecureStorage();
//   await initializeDateFormatting('id_ID', null);  
  
//   Map<String, dynamic> config;
  
//   try {
//     String? localConfig = await storage.read(key: 'rsmss_config');
    
//     if (localConfig != null) {
//       config = jsonDecode(localConfig);
//     } else {
//       final String response = await rootBundle.loadString('assets/config/rsmss.config');
//       config = jsonDecode(response);
//       await storage.write(key: 'rsmss_config', value: response);
//     }

//     await Supabase.initialize(
//       url: config['supabase_url'],
//       anonKey: config['supabase_anon_key'],
//     );
//     await setupServiceLocator();
    
//   } catch (e) {
//     debugPrint("Error Initializing Configuration: $e");
//   }

//   runApp(
//     const ProviderScope(
//       child: RSMSSApp(),
//     ),
//   );
// }

// class RSMSSApp extends StatelessWidget {
//   const RSMSSApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'RSMSS IoT',
//       theme: ThemeData(
//         useMaterial3: true, 
//         colorSchemeSeed: Colors.blue,
//         brightness: Brightness.light,
//       ),
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('en'),
//         Locale('id'),
//       ],
//       home: const MainScreen(),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rsmss/core/di/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rsmss/l10n/app_localizations.dart';
import 'package:rsmss/providers/locale_provider.dart';

// Pastikan path import ini sesuai dengan struktur folder Anda
import 'package:rsmss/views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const storage = FlutterSecureStorage();
  await initializeDateFormatting('id_ID', null);  
  
  Map<String, dynamic> config;
  
  try {
    String? localConfig = await storage.read(key: 'rsmss_config');
    
    if (localConfig != null) {
      config = jsonDecode(localConfig);
    } else {
      final String response = await rootBundle.loadString('assets/config/rsmss.config');
      config = jsonDecode(response);
      await storage.write(key: 'rsmss_config', value: response);
    }

    await Supabase.initialize(
      url: config['supabase_url'],
      anonKey: config['supabase_anon_key'],
    );
    await setupServiceLocator();
    
  } catch (e) {
    debugPrint("Error Initializing Configuration: $e");
  }

  runApp(
    const ProviderScope(
      child: RSMSSApp(),
    ),
  );
}

class RSMSSApp extends ConsumerWidget {
  const RSMSSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RSMSS IoT',
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
      home: const MainScreen(),
    );
  }
}