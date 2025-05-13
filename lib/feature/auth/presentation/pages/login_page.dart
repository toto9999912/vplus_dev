import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/feature/auth/presentation/providers/auth_providers.dart';

import '../../domain/enum/auth_status.dart';

@RoutePage()
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 顯示錯誤訊息
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('登入失敗'),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('確定'))],
          ),
    );
  }

  // 登入方法
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).login(_usernameController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 監聽Auth狀態
    ref.listen(authNotifierProvider, (previous, current) {
      if (current.status == AuthStatus.authenticated) {
        // 登入成功，導航到首頁
        context.router.replacePath('/home');
      } else if (current.status == AuthStatus.error) {
        // 顯示錯誤訊息
        _showErrorDialog(current.errorMessage ?? '登入失敗，請稍後再試');
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('登入')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 帳號輸入框
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '帳號',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入帳號';
                  }
                  return null;
                },
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // 密碼輸入框
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: '密碼',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入密碼';
                  }
                  return null;
                },
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),

              // 登入按鈕
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading ? const CircularProgressIndicator() : const Text('登入'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
