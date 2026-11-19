import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:orders_typing/orders_typing.dart';

/// Badge del estado de una orden.
class OrderStatusBadge extends StatelessWidget {
  /// Crea el badge de [status].
  const OrderStatusBadge({required this.id, required this.status, super.key});

  /// Identificador semántico y `Key` del badge.
  final String id;

  /// Estado.
  final OrderStatus status;

  @override
  Widget build(BuildContext context) => AppBadge(
    id: id,
    label: context.tr('orders.status.${status.name}'),
    tone: switch (status) {
      OrderStatus.filled => AppBadgeTone.positive,
      OrderStatus.rejected => AppBadgeTone.negative,
      OrderStatus.pending => AppBadgeTone.warning,
      OrderStatus.cancelled => AppBadgeTone.neutral,
    },
  );
}
