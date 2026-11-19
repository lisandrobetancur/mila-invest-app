import 'package:typing/typing.dart';

/// Instrumento sembrado en el backend falso (§7.5).
///
/// Nombres reales con **precios simulados**. Los precios se guardan en
/// centavos enteros: ningún `double` toca un precio.
class FakeInstrument {
  /// Declara un instrumento sembrado.
  const FakeInstrument({
    required this.ticker,
    required this.name,
    required this.country,
    required this.type,
    required this.lastCents,
    required this.prevCloseCents,
    required this.volume,
    required this.description,
  });

  /// Ticker.
  final String ticker;

  /// Nombre del emisor.
  final String name;

  /// País del mercado.
  final Country country;

  /// `STOCK` o `ETF`.
  final String type;

  /// Último precio del seed, en centavos.
  final int lastCents;

  /// Cierre anterior, en centavos.
  final int prevCloseCents;

  /// Volumen del día.
  final int volume;

  /// Descripción corta.
  final String description;

  /// Id del instrumento: `<TICKER>-<PAÍS>`.
  String get id => '$ticker-${country.code}';

  /// Moneda en la que cotiza.
  Currency get currency => country.currency;
}

/// Instrumentos del seed, en orden estable.
const List<FakeInstrument> fakeInstruments = <FakeInstrument>[
  FakeInstrument(
    ticker: 'ECOPETROL',
    name: 'Ecopetrol S.A.',
    country: Country.co,
    type: 'STOCK',
    lastCents: 238500,
    prevCloseCents: 235000,
    volume: 12450300,
    description: 'Petrolera integrada, la mayor empresa de Colombia.',
  ),
  FakeInstrument(
    ticker: 'PFBCOLOM',
    name: 'Bancolombia S.A. (preferencial)',
    country: Country.co,
    type: 'STOCK',
    lastCents: 3450000,
    prevCloseCents: 3478000,
    volume: 845200,
    description: 'Grupo financiero con operación en Colombia y Centroamérica.',
  ),
  FakeInstrument(
    ticker: 'ISA',
    name: 'Interconexión Eléctrica S.A.',
    country: Country.co,
    type: 'STOCK',
    lastCents: 1780000,
    prevCloseCents: 1762000,
    volume: 412800,
    description: 'Transmisión de energía, vías y telecomunicaciones.',
  ),
  FakeInstrument(
    ticker: 'GEB',
    name: 'Grupo Energía Bogotá',
    country: Country.co,
    type: 'STOCK',
    lastCents: 248000,
    prevCloseCents: 248000,
    volume: 1930400,
    description: 'Transporte y distribución de energía eléctrica y gas.',
  ),
  FakeInstrument(
    ticker: 'ICOLCAP',
    name: 'iShares MSCI COLCAP',
    country: Country.co,
    type: 'ETF',
    lastCents: 1395000,
    prevCloseCents: 1388500,
    volume: 268900,
    description: 'ETF que replica el índice MSCI COLCAP.',
  ),
  FakeInstrument(
    ticker: 'WALMEX',
    name: 'Wal-Mart de México',
    country: Country.mx,
    type: 'STOCK',
    lastCents: 5892,
    prevCloseCents: 5840,
    volume: 18340500,
    description: 'Cadena de autoservicio en México y Centroamérica.',
  ),
  FakeInstrument(
    ticker: 'AMXB',
    name: 'América Móvil',
    country: Country.mx,
    type: 'STOCK',
    lastCents: 1534,
    prevCloseCents: 1551,
    volume: 42118700,
    description: 'Telecomunicaciones en América Latina y Europa.',
  ),
  FakeInstrument(
    ticker: 'GFNORTEO',
    name: 'Grupo Financiero Banorte',
    country: Country.mx,
    type: 'STOCK',
    lastCents: 15280,
    prevCloseCents: 15105,
    volume: 6254100,
    description: 'Grupo financiero mexicano de banca múltiple.',
  ),
  FakeInstrument(
    ticker: 'CEMEXCPO',
    name: 'Cemex',
    country: Country.mx,
    type: 'STOCK',
    lastCents: 1247,
    prevCloseCents: 1262,
    volume: 29877300,
    description: 'Cemento, concreto y agregados a escala global.',
  ),
  FakeInstrument(
    ticker: 'BAP',
    name: 'Credicorp',
    country: Country.pe,
    type: 'STOCK',
    lastCents: 19250,
    prevCloseCents: 18990,
    volume: 184300,
    description: 'Holding financiero líder en Perú.',
  ),
  FakeInstrument(
    ticker: 'SCCO',
    name: 'Southern Copper',
    country: Country.pe,
    type: 'STOCK',
    lastCents: 11020,
    prevCloseCents: 11145,
    volume: 96500,
    description: 'Productora de cobre con minas en Perú y México.',
  ),
  FakeInstrument(
    ticker: 'BVN',
    name: 'Compañía de Minas Buenaventura',
    country: Country.pe,
    type: 'STOCK',
    lastCents: 1485,
    prevCloseCents: 1470,
    volume: 311200,
    description: 'Minera peruana de metales preciosos.',
  ),
  FakeInstrument(
    ticker: 'FERREYC1',
    name: 'Ferreycorp',
    country: Country.pe,
    type: 'STOCK',
    lastCents: 294,
    prevCloseCents: 292,
    volume: 1204800,
    description: 'Bienes de capital y servicios para minería y construcción.',
  ),
];
