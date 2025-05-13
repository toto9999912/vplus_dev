// API Client 提供者
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vplus_dev/core/network/api_client.dart';
import 'package:vplus_dev/shared/enum/backend_type.dart';

import 'service_providers.dart';

part 'api_client_providers.g.dart';

@riverpod
ApiClient coreApiClient(Ref ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  return ApiClient(BackendType.core, tokenService: tokenService);
}

@riverpod
ApiClient nestjsApiClient(Ref ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  return ApiClient(BackendType.nestjs, tokenService: tokenService);
}

@riverpod
ApiClient csharpApiClient(Ref ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  return ApiClient(BackendType.csharp, tokenService: tokenService);
}
