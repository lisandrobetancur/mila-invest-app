library com.milainvest.mila_invest.market.ui.views.instrument_detail;

import 'dart:async';

import 'package:authentication_typing/authentication_typing.dart';
import 'package:country_chip/country_chip.dart';
import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empty_state/empty_state.dart';
import 'package:error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_constants/market_constants.dart';
import 'package:market_typing/market_typing.dart';
import 'package:money_text/money_text.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:price_change/price_change.dart';
import 'package:price_chart/price_chart.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import '../../../core/state/instrument_detail/instrument_detail.dart';
import '../../widgets/market_status_text.dart';

part 'instrument_detail_data.dart';
part 'instrument_detail_empty.dart';
part 'instrument_detail_error.dart';
part 'instrument_detail_parts.dart';
part 'instrument_detail_shimmer.dart';
part 'instrument_detail_view.dart';
