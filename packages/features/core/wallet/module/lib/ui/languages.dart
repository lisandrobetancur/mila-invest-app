/// Traducciones de wallet, por idioma.
const Map<String, Map<String, Object?>>
walletLanguages = <String, Map<String, Object?>>{
  'es': <String, Object?>{
    'wallet': <String, Object?>{
      'common': <String, Object?>{
        'simulated': 'Simulado',
        'disclaimer':
            'Simulación con fines educativos. No es asesoría financiera.',
        'retry': 'Reintentar',
        'back': 'Volver',
        'close': 'Cerrar',
      },
      'accounts': <String, Object?>{
        'title': 'Billetera',
        'available': 'Disponible',
        'reserved': 'Reservado',
        'deposit': 'Depositar',
        'account_cop': 'Pesos colombianos',
        'account_mxn': 'Pesos mexicanos',
        'account_pen': 'Soles peruanos',
        'account_usd': 'Dólares',
        'empty_title': 'Aún no tienes saldo',
        'empty_body':
            'Haz un depósito virtual para empezar a practicar. No se usa '
            'dinero real.',
        'empty_deposit': 'Hacer un depósito',
      },
      'deposit': <String, Object?>{
        'title': 'Depositar dinero virtual',
        'currency': 'Moneda',
        'amount': 'Monto',
        'available': 'Disponible: {amount}',
        'submit': 'Depositar',
        'success': 'Depositamos {amount} en tu billetera.',
        'amount_invalid': 'Escribe un monto válido.',
        'amount_min': 'El monto tiene que ser mayor que cero.',
        'amount_max': 'El monto es demasiado alto para un depósito.',
      },
      'error': <String, Object?>{
        'validation': 'Revisa el monto del depósito.',
        'idempotency':
            'Este depósito ya se hizo con otro monto. Revisa tu billetera.',
        'rate_limited': 'Hiciste muchos depósitos seguidos. Espera un momento.',
        'network':
            'No pudimos conectar. Revisa tu conexión y vuelve a intentarlo.',
        'unexpected':
            'Recibimos una respuesta inesperada. Revisa tu billetera antes '
            'de reintentar.',
        'unknown': 'Algo salió mal con la billetera. Inténtalo de nuevo.',
      },
    },
  },
  'en': <String, Object?>{
    'wallet': <String, Object?>{
      'common': <String, Object?>{
        'simulated': 'Simulated',
        'disclaimer':
            'Simulation for educational purposes. Not financial advice.',
        'retry': 'Try again',
        'back': 'Back',
        'close': 'Close',
      },
      'accounts': <String, Object?>{
        'title': 'Wallet',
        'available': 'Available',
        'reserved': 'Reserved',
        'deposit': 'Deposit',
        'account_cop': 'Colombian pesos',
        'account_mxn': 'Mexican pesos',
        'account_pen': 'Peruvian soles',
        'account_usd': 'US dollars',
        'empty_title': 'No balance yet',
        'empty_body':
            'Make a virtual deposit to start practicing. No real money is '
            'used.',
        'empty_deposit': 'Make a deposit',
      },
      'deposit': <String, Object?>{
        'title': 'Deposit virtual money',
        'currency': 'Currency',
        'amount': 'Amount',
        'available': 'Available: {amount}',
        'submit': 'Deposit',
        'success': 'We deposited {amount} into your wallet.',
        'amount_invalid': 'Enter a valid amount.',
        'amount_min': 'The amount must be greater than zero.',
        'amount_max': 'The amount is too high for a deposit.',
      },
      'error': <String, Object?>{
        'validation': 'Check the deposit amount.',
        'idempotency':
            'This deposit was already made with another amount. Check your '
            'wallet.',
        'rate_limited': 'Too many deposits in a row. Wait a moment.',
        'network': 'We could not connect. Check your connection and retry.',
        'unexpected':
            'We got an unexpected response. Check your wallet before '
            'retrying.',
        'unknown': 'Something went wrong with the wallet. Try again.',
      },
    },
  },
};
