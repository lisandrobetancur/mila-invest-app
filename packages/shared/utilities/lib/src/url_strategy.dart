/// Estrategia de URL de la app.
///
/// En web usa URLs con path real (sin `#`), para que los deep links y un F5
/// en una ruta profunda funcionen. En el resto de las plataformas no hace
/// nada.
export 'url_strategy_io.dart'
    if (dart.library.js_interop) 'url_strategy_web.dart';
