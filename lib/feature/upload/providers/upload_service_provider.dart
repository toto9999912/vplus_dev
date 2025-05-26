import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/upload_service.dart';

part 'upload_service_provider.g.dart';

@riverpod
UploadService uploadService(Ref ref) {
  return UploadService();
}
