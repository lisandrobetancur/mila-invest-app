import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

import '../data/dto/country_market_dto.dart';
import '../data/dto/instrument_dto.dart';
import '../data/market_remote_data_source.dart';

/// Implementación de [IMarketService].
class MarketService implements IMarketService {
  /// Crea el service.
  const MarketService({required MarketRemoteDataSource dataSource})
    : _dataSource = dataSource;

  final MarketRemoteDataSource _dataSource;

  @override
  Future<List<CountryMarket>> countryMarkets() => _guard(() async {
    final List<CountryMarketDto> countries = await _dataSource.countries();
    return countries
        .map((CountryMarketDto dto) => dto.toDomain())
        .toList(growable: false);
  });

  @override
  Future<InstrumentDetail> instrument(String id) =>
      _guard(() async => (await _dataSource.instrument(id)).toDomain());

  @override
  Future<Paginated<Instrument>> instruments(
    InstrumentFilter filter, {
    String? cursor,
    int? limit,
  }) => _guard(() async {
    final String query = filter.query.trim();
    final Paginated<InstrumentDto> page = await _dataSource.instruments(
      country: filter.country?.code,
      type: filter.type?.apiCode,
      query: query.isEmpty ? null : query,
      cursor: cursor,
      limit: limit,
    );
    return Paginated<Instrument>(
      items: page.items
          .map((InstrumentDto dto) => dto.toDomain())
          .toList(growable: false),
      nextCursor: page.nextCursor,
    );
  });

  @override
  Future<PriceSeries> prices(String id, PriceRange range) => _guard(
    () async => (await _dataSource.prices(id, range.apiCode)).toDomain(),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw MarketException(MarketErrorCode.fromApiCode(error.code));
    } on FormatException {
      throw const MarketException(MarketErrorCode.unexpectedResponse);
    }
  }
}
