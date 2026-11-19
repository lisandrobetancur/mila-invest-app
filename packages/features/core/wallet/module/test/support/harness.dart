import 'package:design_system/design_system.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utilities/utilities.dart';

/// Regex que cumple la parte estática de todo identificador (§11.1).
final RegExp identifierPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

/// Claves hoja de un mapa de traducciones, en notación con puntos.
Set<String> translationKeys(Map<String, Object?> map, [String prefix = '']) =>
    <String>{
      for (final MapEntry<String, Object?> entry in map.entries)
        if (entry.value case final Map<String, Object?> nested)
          ...translationKeys(nested, '$prefix${entry.key}.')
        else
          '$prefix${entry.key}',
    };

/// Carga las traducciones de la feature sin el widget de easy_localization.
final class TestTranslations extends LocalizationsDelegate<Localization> {
  const TestTranslations(this.languages);

  final Map<String, Map<String, Object?>> languages;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Localization> load(Locale locale) {
    Localization.load(
      locale,
      translations: Translations(languages[locale.languageCode]),
    );
    return SynchronousFuture<Localization>(Localization.instance);
  }

  @override
  bool shouldReload(TestTranslations old) => false;
}

final class _AnyLocaleMaterial
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _AnyLocaleMaterial();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(_AnyLocaleMaterial old) => false;
}

final class _AnyLocaleCupertino
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AnyLocaleCupertino();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(_AnyLocaleCupertino old) => false;
}

/// Monta [view] como lo haría la app: tema, traducciones y providers.
Future<void> pumpView(
  WidgetTester tester,
  Widget view, {
  required Map<String, Map<String, Object?>> languages,
  List<Override> overrides = const <Override>[],
  String language = 'es',
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        loggerProvider.overrideWithValue(const SilentAppLogger()),
        durationsProvider.overrideWithValue(const AppDurations.instant()),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: Locale(language),
        supportedLocales: const <Locale>[Locale('es'), Locale('en')],
        localizationsDelegates: <LocalizationsDelegate<Object?>>[
          TestTranslations(languages),
          const _AnyLocaleMaterial(),
          const _AnyLocaleCupertino(),
          DefaultWidgetsLocalizations.delegate,
        ],
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: view,
      ),
    ),
  );
  await tester.pump();
}

/// Aplica un factor de escala de texto al subárbol.
class MediaQueryTextScale extends StatelessWidget {
  const MediaQueryTextScale({
    required this.scale,
    required this.child,
    super.key,
  });

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child,
  );
}

/// Etiqueta semántica del nodo identificado con [id].
String labelOf(WidgetTester tester, String id) =>
    tester.getSemantics(find.bySemanticsIdentifier(id)).label;

/// Todos los identificadores del árbol semántico renderizado.
List<String> renderedIdentifiers(WidgetTester tester) {
  final List<String> identifiers = <String>[];
  void visit(SemanticsNode node) {
    if (node.identifier.isNotEmpty) {
      identifiers.add(node.identifier);
    }
    node.visitChildren((SemanticsNode child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return identifiers;
}

/// Verifica que no haya dos nodos con el mismo identificador en pantalla.
void expectNoDuplicateIdentifiers(WidgetTester tester) {
  final List<String> identifiers = renderedIdentifiers(tester);
  expect(
    identifiers.toSet().length,
    identifiers.length,
    reason: 'Identificadores duplicados: $identifiers',
  );
}
