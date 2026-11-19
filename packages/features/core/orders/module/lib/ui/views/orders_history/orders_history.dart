library com.milainvest.mila_invest.orders.ui.views.orders_history;

import 'package:authentication_typing/authentication_typing.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empty_state/empty_state.dart';
import 'package:error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_text/money_text.dart';
import 'package:navigator/navigator.dart';
import 'package:orders_constants/orders_constants.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import '../../../core/state/orders_history/orders_history.dart';
import '../../widgets/order_status_badge.dart';

part 'orders_history_data.dart';
part 'orders_history_empty.dart';
part 'orders_history_error.dart';
part 'orders_history_shimmer.dart';
part 'orders_history_view.dart';
