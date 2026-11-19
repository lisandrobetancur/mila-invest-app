/// Traducciones de transactions, por idioma.
const Map<String, Map<String, Object?>> transactionsLanguages =
    <String, Map<String, Object?>>{
      'es': <String, Object?>{
        'transactions': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulado',
            'retry': 'Reintentar',
          },
          'list': <String, Object?>{
            'title': 'Actividad',
            'movements': 'Movimientos',
            'orders': 'Órdenes',
            'type_all': 'Todos',
            'type_deposit': 'Depósitos',
            'type_buy': 'Compras',
            'type_sell': 'Ventas',
            'type_fee': 'Comisiones',
            'range_all': 'Todo',
            'range_7d': '7 días',
            'range_30d': '30 días',
            'range_90d': '90 días',
            'loading_more': 'Cargando más movimientos',
            'empty_title': 'Aún no tienes movimientos',
            'empty_body': 'Haz tu primer depósito virtual para empezar.',
            'empty_deposit': 'Depositar',
            'empty_filtered_title': 'No hay movimientos con esos filtros',
            'clear_filters': 'Limpiar filtros',
          },
          'type': <String, Object?>{
            'deposit': 'Depósito',
            'buy': 'Compra',
            'sell': 'Venta',
            'fee': 'Comisión',
            'other': 'Movimiento',
          },
          'error': <String, Object?>{
            'rate_limited':
                'Hiciste muchas consultas seguidas. Espera un momento.',
            'network':
                'No pudimos cargar tus movimientos. Revisa tu conexión e '
                'inténtalo de nuevo.',
            'unexpected':
                'Recibimos una respuesta inesperada. Inténtalo más tarde.',
            'unknown': 'Algo salió mal al cargar tus movimientos.',
          },
        },
      },
      'en': <String, Object?>{
        'transactions': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulated',
            'retry': 'Try again',
          },
          'list': <String, Object?>{
            'title': 'Activity',
            'movements': 'Transactions',
            'orders': 'Orders',
            'type_all': 'All',
            'type_deposit': 'Deposits',
            'type_buy': 'Buys',
            'type_sell': 'Sells',
            'type_fee': 'Fees',
            'range_all': 'All time',
            'range_7d': '7 days',
            'range_30d': '30 days',
            'range_90d': '90 days',
            'loading_more': 'Loading more transactions',
            'empty_title': 'No transactions yet',
            'empty_body': 'Make your first virtual deposit to get started.',
            'empty_deposit': 'Deposit',
            'empty_filtered_title': 'No transactions match those filters',
            'clear_filters': 'Clear filters',
          },
          'type': <String, Object?>{
            'deposit': 'Deposit',
            'buy': 'Buy',
            'sell': 'Sell',
            'fee': 'Fee',
            'other': 'Transaction',
          },
          'error': <String, Object?>{
            'rate_limited': 'Too many requests in a row. Wait a moment.',
            'network':
                'We could not load your transactions. Check your connection '
                'and try again.',
            'unexpected': 'We got an unexpected response. Try again later.',
            'unknown': 'Something went wrong while loading your transactions.',
          },
        },
      },
    };
