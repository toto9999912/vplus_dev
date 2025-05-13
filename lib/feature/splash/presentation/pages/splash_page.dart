import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/feature/splash/presentation/providers/timer_provider.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 啟動計時器
    Future.microtask(() => ref.read(splashTimerProvider.notifier).startCountdown());
  }

  void _navigateToLogin() {
    context.router.replace(LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    // 監聽計時器狀態
    final remainingSeconds = ref.watch(splashTimerProvider);

    // 當計時器結束時自動跳轉
    ref.listen(splashTimerProvider, (previous, current) {
      if (current <= 0) {
        _navigateToLogin();
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 應用程式 Logo
              const Expanded(flex: 3, child: Center(child: FlutterLogo(size: 120))),

              // 應用程式名稱
              Expanded(
                flex: 1,
                child: Text('VPlus', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),

              // 倒數計時和跳過按鈕
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('自動跳轉倒數: $remainingSeconds 秒', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(splashTimerProvider.notifier).skipCountdown();
                        _navigateToLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('跳過'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
