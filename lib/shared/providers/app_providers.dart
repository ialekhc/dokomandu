import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/network/dio_client.dart';
import 'package:dokomandu/core/services/connectivity_service.dart';
import 'package:dokomandu/core/storage/hive_storage_service.dart';
import 'package:dokomandu/core/storage/local_cache_service.dart';
import 'package:dokomandu/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(ref.watch(flutterSecureStorageProvider)),
);

final localCacheServiceProvider = Provider<LocalCacheService>(
  (ref) => LocalCacheService(),
);

final hiveStorageServiceProvider = Provider<HiveStorageService>(
  (ref) => HiveStorageService(),
);

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(ref.watch(connectivityProvider)),
);

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(secureStorage: ref.watch(secureStorageServiceProvider)),
);

final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).client);

final baseApiServiceProvider = Provider<BaseApiService>(
  (ref) => BaseApiService(ref.watch(dioProvider)),
);
