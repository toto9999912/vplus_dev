import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/upload_service.dart';

// 使用簡單的 Provider 替代 @riverpod 註解
final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService();
});
