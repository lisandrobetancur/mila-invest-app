import 'package:flutter_web_plugins/url_strategy.dart';

/// En web usa URLs con path real, sin `#`.
void configureUrlStrategy() => usePathUrlStrategy();
