library com.milainvest.mila_invest.portfolio.ui.views.overview;

import 'package:allocation_donut/allocation_donut.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empty_state/empty_state.dart';
import 'package:error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_text/money_text.dart';
import 'package:portfolio_constants/portfolio_constants.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:price_change/price_change.dart';
import 'package:stat_tile/stat_tile.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import '../../../core/state/overview/overview.dart';

part 'overview_data.dart';
part 'overview_empty.dart';
part 'overview_error.dart';
part 'overview_shimmer.dart';
part 'overview_view.dart';
