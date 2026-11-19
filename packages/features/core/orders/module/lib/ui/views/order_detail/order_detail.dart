library com.milainvest.mila_invest.orders.ui.views.order_detail;

import 'package:authentication_typing/authentication_typing.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empty_state/empty_state.dart';
import 'package:error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_summary/order_summary.dart';
import 'package:orders_constants/orders_constants.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import '../../../core/state/order_detail/order_detail.dart';
import '../../widgets/order_status_badge.dart';

part 'order_detail_data.dart';
part 'order_detail_empty.dart';
part 'order_detail_error.dart';
part 'order_detail_shimmer.dart';
part 'order_detail_view.dart';
