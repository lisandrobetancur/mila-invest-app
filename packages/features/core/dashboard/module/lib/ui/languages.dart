/// Traducciones de dashboard, por idioma.
const Map<String, Map<String, Object?>> dashboardLanguages =
    <String, Map<String, Object?>>{
      'es': <String, Object?>{
        'dashboard': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulado',
            'retry': 'Reintentar',
            'wallet': 'Billetera',
            'settings': 'Ajustes',
          },
          'home': <String, Object?>{
            'greeting': 'Hola, {name}',
            'greeting_anonymous': 'Hola',
            'total': 'Valor total',
            'allocation_title': 'Distribución',
            'allocation_summary': 'Distribución del portafolio: {slices}',
            'gainers': 'Los que más suben hoy',
            'losers': 'Los que más bajan hoy',
            'recent': 'Últimos movimientos',
            'see_all': 'Ver todo',
            'empty_title': 'Haz tu primer depósito',
            'empty_body':
                'Recibe dinero virtual para empezar a practicar con acciones '
                'y ETFs de Colombia, México y Perú.',
            'empty_deposit': 'Depositar',
          },
          'allocation': <String, Object?>{
            'stock': 'Acciones',
            'etf': 'ETFs',
            'cash': 'Efectivo',
            'other': 'Otros',
          },
          'country': <String, Object?>{
            'co': 'Colombia',
            'mx': 'México',
            'pe': 'Perú',
          },
          'error': <String, Object?>{
            'rate_limited':
                'Hiciste muchas consultas seguidas. Espera un momento.',
            'network':
                'No pudimos cargar tu resumen. Revisa tu conexión e inténtalo '
                'de nuevo.',
            'unexpected':
                'Recibimos una respuesta inesperada. Inténtalo más tarde.',
            'unknown': 'Algo salió mal al cargar tu resumen.',
          },
        },
      },
      'en': <String, Object?>{
        'dashboard': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulated',
            'retry': 'Try again',
            'wallet': 'Wallet',
            'settings': 'Settings',
          },
          'home': <String, Object?>{
            'greeting': 'Hi, {name}',
            'greeting_anonymous': 'Hi',
            'total': 'Total value',
            'allocation_title': 'Allocation',
            'allocation_summary': 'Portfolio allocation: {slices}',
            'gainers': 'Top gainers today',
            'losers': 'Top losers today',
            'recent': 'Latest transactions',
            'see_all': 'See all',
            'empty_title': 'Make your first deposit',
            'empty_body':
                'Get virtual money to start practicing with stocks and ETFs '
                'from Colombia, Mexico and Peru.',
            'empty_deposit': 'Deposit',
          },
          'allocation': <String, Object?>{
            'stock': 'Stocks',
            'etf': 'ETFs',
            'cash': 'Cash',
            'other': 'Other',
          },
          'country': <String, Object?>{
            'co': 'Colombia',
            'mx': 'Mexico',
            'pe': 'Peru',
          },
          'error': <String, Object?>{
            'rate_limited': 'Too many requests in a row. Wait a moment.',
            'network':
                'We could not load your summary. Check your connection and try '
                'again.',
            'unexpected': 'We got an unexpected response. Try again later.',
            'unknown': 'Something went wrong while loading your summary.',
          },
        },
      },
    };
