library com.milainvest.mila_invest.dashboard.ui.views.home;

import 'package:allocation_donut/allocation_donut.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:dashboard_constants/dashboard_constants.dart';
import 'package:dashboard_typing/dashboard_typing.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instrument_tile/instrument_tile.dart';
import 'package:market_typing/market_typing.dart';
import 'package:money_text/money_text.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:price_change/price_change.dart';
import 'package:stat_tile/stat_tile.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import '../../../core/state/home/home.dart';

part 'home_data.dart';
part 'home_empty.dart';
part 'home_error.dart';
part 'home_shimmer.dart';
part 'home_view.dart';
