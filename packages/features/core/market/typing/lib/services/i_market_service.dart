import 'package:typing/typing.dart';

import '../enums/price_range.dart';
import '../models/country_market.dart';
import '../models/instrument.dart';
import '../models/instrument_detail.dart';
import '../models/instrument_filter.dart';
import '../models/price_series.dart';

/// Servicio de market. Sus métodos lanzan `MarketException`.
abstract interface class IMarketService {
  /// Una página de instrumentos con [filter].
  Future<Paginated<Instrument>> instruments(
    InstrumentFilter filter, {
    String? cursor,
    int? limit,
  });

  /// Detalle del instrumento [id].
  Future<InstrumentDetail> instrument(String id);

  /// Serie de precios de [id] en [range].
  Future<PriceSeries> prices(String id, PriceRange range);

  /// Estado del mercado de cada país.
  Future<List<CountryMarket>> countryMarkets();
}
