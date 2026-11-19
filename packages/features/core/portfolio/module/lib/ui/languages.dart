/// Traducciones de portfolio, por idioma.
const Map<String, Map<String, Object?>> portfolioLanguages =
    <String, Map<String, Object?>>{
      'es': <String, Object?>{
        'portfolio': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulado',
            'retry': 'Reintentar',
          },
          'overview': <String, Object?>{
            'title': 'Portafolio',
            'total': 'Valor total',
            'day_change': 'Variación de hoy',
            'cash': 'Efectivo',
            'invested': 'Invertido',
            'allocation_title': 'Distribución',
            'allocation_summary': 'Distribución del portafolio: {slices}',
            'positions_title': 'Tus posiciones',
            'quantity': '{quantity} unidades',
            'avg_cost': 'Costo promedio',
            'market_value': 'Valor de mercado',
            'pnl': 'P&L no realizado',
            'pnl_help': 'Ganancia o pérdida si vendieras hoy',
            'fx_note':
                'Totalizado en {currency} con tipos de cambio simulados: '
                '{rates}.',
            'empty_title': 'Aún no tienes inversiones',
            'empty_body': 'Explora el mercado y haz tu primera compra.',
            'explore': 'Explorar mercado',
          },
          'allocation': <String, Object?>{
            'stock': 'Acciones',
            'etf': 'ETFs',
            'cash': 'Efectivo',
            'other': 'Otros',
          },
          'error': <String, Object?>{
            'rate_limited':
                'Hiciste muchas consultas seguidas. Espera un momento.',
            'network':
                'No pudimos cargar tu portafolio. Revisa tu conexión e '
                'inténtalo de nuevo.',
            'unexpected':
                'Recibimos una respuesta inesperada. Inténtalo más tarde.',
            'unknown': 'Algo salió mal al cargar tu portafolio.',
          },
        },
      },
      'en': <String, Object?>{
        'portfolio': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulated',
            'retry': 'Try again',
          },
          'overview': <String, Object?>{
            'title': 'Portfolio',
            'total': 'Total value',
            'day_change': 'Today',
            'cash': 'Cash',
            'invested': 'Invested',
            'allocation_title': 'Allocation',
            'allocation_summary': 'Portfolio allocation: {slices}',
            'positions_title': 'Your positions',
            'quantity': '{quantity} units',
            'avg_cost': 'Average cost',
            'market_value': 'Market value',
            'pnl': 'Unrealized P&L',
            'pnl_help': 'Gain or loss if you sold today',
            'fx_note':
                'Totaled in {currency} with simulated exchange rates: {rates}.',
            'empty_title': 'No investments yet',
            'empty_body': 'Explore the market and make your first purchase.',
            'explore': 'Explore market',
          },
          'allocation': <String, Object?>{
            'stock': 'Stocks',
            'etf': 'ETFs',
            'cash': 'Cash',
            'other': 'Other',
          },
          'error': <String, Object?>{
            'rate_limited': 'Too many requests in a row. Wait a moment.',
            'network':
                'We could not load your portfolio. Check your connection and '
                'try again.',
            'unexpected': 'We got an unexpected response. Try again later.',
            'unknown': 'Something went wrong while loading your portfolio.',
          },
        },
      },
    };
