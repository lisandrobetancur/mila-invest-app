import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/i_orders_service.dart';

/// Servicio de orders. Lo implementa el módulo por override.
final Provider<IOrdersService> ordersServiceProvider = Provider<IOrdersService>(
  (Ref ref) => throw UnimplementedError('ordersServiceProvider'),
);
