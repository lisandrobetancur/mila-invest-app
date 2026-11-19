/// Traducciones de app_cross, por idioma.
///
/// Viven en código, no en assets: el shell las mergea con las de las demás
/// features en su `AssetLoader`.
const Map<String, Map<String, Object?>>
appCrossLanguages = <String, Map<String, Object?>>{
  'es': <String, Object?>{
    'app_cross': <String, Object?>{
      'common': <String, Object?>{
        'simulated': 'Simulado',
        'disclaimer':
            'Simulación con fines educativos. No es asesoría financiera.',
        'retry': 'Reintentar',
        'back': 'Volver',
      },
      'error': <String, Object?>{
        'network':
            'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
        'storage': 'No pudimos guardar tus preferencias en este dispositivo.',
        'unknown': 'Algo salió mal al iniciar. Inténtalo de nuevo.',
      },
      'splash': <String, Object?>{
        'title': 'MILA Invest',
        'loading': 'Preparando tu simulador',
      },
      'onboarding': <String, Object?>{
        'skip': 'Saltar',
        'next': 'Siguiente',
        'start': 'Empezar',
        'progress': 'Paso {current} de {total}',
        'step1_title': 'Aprende a invertir sin arriesgar',
        'step1_body':
            'MILA Invest es un simulador de inversiones para Colombia, '
            'México y Perú.',
        'step2_title': 'Todo es dinero virtual',
        'step2_body':
            'Recibes saldo de práctica y operas con precios simulados. '
            'Nunca se mueve dinero real.',
        'step3_title': 'Acciones y ETFs de tres mercados',
        'step3_body':
            'Compra y vende, sigue tu portafolio y revisa cada '
            'movimiento. Pronto: CDTs, fondos y cambio de divisas.',
      },
      'settings': <String, Object?>{
        'title': 'Ajustes',
        'theme_title': 'Tema',
        'theme_system': 'Sistema',
        'theme_light': 'Claro',
        'theme_dark': 'Oscuro',
        'language_title': 'Idioma',
        'account_title': 'Tu cuenta',
        'account_name': 'Nombre',
        'account_email': 'Correo',
        'account_country': 'País',
        'account_document': 'Documento',
        'logout': 'Cerrar sesión',
        'logout_title': '¿Cerrar sesión?',
        'logout_message':
            'Tendrás que iniciar sesión de nuevo para ver tu portafolio.',
        'logout_confirm': 'Cerrar sesión',
        'logout_cancel': 'Seguir aquí',
        'about_title': 'Acerca de',
        'version': 'Versión {version}',
        'api_mode': 'Modo de API: {mode}',
      },
      'country': <String, Object?>{
        'co': 'Colombia',
        'mx': 'México',
        'pe': 'Perú',
      },
    },
  },
  'en': <String, Object?>{
    'app_cross': <String, Object?>{
      'common': <String, Object?>{
        'simulated': 'Simulated',
        'disclaimer':
            'Simulation for educational purposes. Not financial advice.',
        'retry': 'Try again',
        'back': 'Back',
      },
      'error': <String, Object?>{
        'network': 'We could not connect. Check your connection and try again.',
        'storage': 'We could not save your preferences on this device.',
        'unknown': 'Something went wrong while starting. Try again.',
      },
      'splash': <String, Object?>{
        'title': 'MILA Invest',
        'loading': 'Getting your simulator ready',
      },
      'onboarding': <String, Object?>{
        'skip': 'Skip',
        'next': 'Next',
        'start': 'Get started',
        'progress': 'Step {current} of {total}',
        'step1_title': 'Learn to invest without the risk',
        'step1_body':
            'MILA Invest is an investment simulator for Colombia, '
            'Mexico and Peru.',
        'step2_title': 'It is all virtual money',
        'step2_body':
            'You get practice funds and trade at simulated prices. No '
            'real money ever moves.',
        'step3_title': 'Stocks and ETFs from three markets',
        'step3_body':
            'Buy and sell, track your portfolio and review every '
            'transaction. Coming soon: term deposits, funds and FX.',
      },
      'settings': <String, Object?>{
        'title': 'Settings',
        'theme_title': 'Theme',
        'theme_system': 'System',
        'theme_light': 'Light',
        'theme_dark': 'Dark',
        'language_title': 'Language',
        'account_title': 'Your account',
        'account_name': 'Name',
        'account_email': 'Email',
        'account_country': 'Country',
        'account_document': 'ID document',
        'logout': 'Log out',
        'logout_title': 'Log out?',
        'logout_message':
            'You will need to log in again to see your portfolio.',
        'logout_confirm': 'Log out',
        'logout_cancel': 'Stay here',
        'about_title': 'About',
        'version': 'Version {version}',
        'api_mode': 'API mode: {mode}',
      },
      'country': <String, Object?>{
        'co': 'Colombia',
        'mx': 'Mexico',
        'pe': 'Peru',
      },
    },
  },
};
