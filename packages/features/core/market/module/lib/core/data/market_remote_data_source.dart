import 'package:network/network.dart';
import 'package:typing/typing.dart';

import 'dto/country_market_dto.dart';
import 'dto/instrument_detail_dto.dart';
import 'dto/instrument_dto.dart';
import 'dto/price_series_dto.dart';

/// Habla con `/instruments` y `/meta/countries`. Devuelve DTOs.
class MarketRemoteDataSource {
  /// Crea el data source.
  const MarketRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /meta/countries`.
  Future<List<CountryMarketDto>> countries() async {
    final ApiResponse response = await _client.get('/meta/countries');
    return JsonReader.listOf(response.body)
        .map((JsonReader item) => CountryMarketDto.fromJson(item.raw))
        .toList(growable: false);
  }

  /// `GET /instruments/{id}`.
  Future<InstrumentDetailDto> instrument(String id) async {
    final ApiResponse response = await _client.get(
      '/instruments/${Uri.encodeComponent(id)}',
    );
    return InstrumentDetailDto.fromJson(response.json);
  }

  /// `GET /instruments`.
  Future<Paginated<InstrumentDto>> instruments({
    String? country,
    String? type,
    String? query,
    String? cursor,
    int? limit,
  }) async {
    final ApiResponse response = await _client.get(
      '/instruments',
      query: <String, Object?>{
        'country': country,
        'type': type,
        'q': query,
        'cursor': cursor,
        'limit': limit,
      },
    );
    return JsonReader(response.json).paginated<InstrumentDto>(
      (JsonReader item) => InstrumentDto.fromJson(item.raw),
    );
  }

  /// `GET /instruments/{id}/prices`.
  Future<PriceSeriesDto> prices(String id, String range) async {
    final ApiResponse response = await _client.get(
      '/instruments/${Uri.encodeComponent(id)}/prices',
      query: <String, Object?>{'range': range},
    );
    return PriceSeriesDto.fromJson(response.json);
  }
}
