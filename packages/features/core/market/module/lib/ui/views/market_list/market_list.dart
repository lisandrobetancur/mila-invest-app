library com.milainvest.mila_invest.market.ui.views.market_list;

import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empty_state/empty_state.dart';
import 'package:error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instrument_tile/instrument_tile.dart';
import 'package:market_constants/market_constants.dart';
import 'package:market_typing/market_typing.dart';
import 'package:navigator/navigator.dart';
import 'package:typing/typing.dart';

import '../../../core/state/market_list/market_list.dart';
import '../../widgets/market_status_text.dart';

part 'market_list_data.dart';
part 'market_list_empty.dart';
part 'market_list_error.dart';
part 'market_list_header.dart';
part 'market_list_shimmer.dart';
part 'market_list_view.dart';
