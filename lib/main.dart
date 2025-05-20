import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/backend_config.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final serviceProviders = await initializeServiceProviders();
  initalizeFlavorConfig();
  runApp(ProviderScope(overrides: serviceProviders, child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vplus Pro Dev',
      routerConfig: _appRouter.config(),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff19283c), primary: Color(0xff19283c)), useMaterial3: true),
    );
  }
}
