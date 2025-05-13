import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/koos_api_service.dart';

final koosApiServiceProvider = Provider<KoosApiService>((ref) {
  return KoosApiService();
}); 