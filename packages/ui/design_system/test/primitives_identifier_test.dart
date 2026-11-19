import 'dart:ui' show CheckedState, Tristate;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

SemanticsData _data(WidgetTester tester, String id) =>
    tester.getSemantics(find.bySemanticsIdentifier(id)).getSemanticsData();

void main() {
  group('identificadores de las primitivas', () {
    testWidgets('AppButton: id en el nodo con isButton y tap, y como Key', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int taps = 0;
      await _pump(
        tester,
        AppButton(
          id: 'test_buy_button',
          label: 'Comprar',
          onPressed: () {
            taps++;
          },
        ),
      );

      final SemanticsData data = _data(tester, 'test_buy_button');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.label, 'Comprar');
      expect(
        find.byKey(const ValueKey<String>('test_buy_button')),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsIdentifier('test_buy_button'));
      expect(taps, 1);
      handle.dispose();
    });

    for (final AppButtonVariant variant in AppButtonVariant.values) {
      testWidgets('AppButton ${variant.name}: conserva id y botón', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await _pump(
          tester,
          AppButton(
            id: 'test_variant_button',
            label: 'Acción',
            variant: variant,
            onPressed: () {},
          ),
        );

        final SemanticsData data = _data(tester, 'test_variant_button');
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        handle.dispose();
      });
    }

    testWidgets('AppButton en loading no acepta toques', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int taps = 0;
      await _pump(
        tester,
        AppButton(
          id: 'test_submit_button',
          label: 'Confirmar compra',
          loading: true,
          onPressed: () => taps++,
        ),
      );

      final SemanticsData data = _data(tester, 'test_submit_button');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      await tester.tap(
        find.bySemanticsIdentifier('test_submit_button'),
        warnIfMissed: false,
      );
      expect(taps, 0);
      handle.dispose();
    });

    testWidgets('AppIconButton: id en el nodo con isButton y tooltip', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        AppIconButton(
          id: 'test_close_icon_button',
          icon: AppIcons.close,
          tooltip: 'Cerrar',
          onPressed: () {},
        ),
      );

      final SemanticsData data = _data(tester, 'test_close_icon_button');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.tooltip, 'Cerrar');
      handle.dispose();
    });

    testWidgets('AppTextField: id en el nodo con isTextField', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        AppTextField(
          id: 'test_email_field',
          label: 'Correo',
          suffix: AppIconButton(
            id: 'test_email_clear_icon_button',
            icon: AppIcons.clear,
            tooltip: 'Limpiar',
            onPressed: () {},
          ),
        ),
      );

      final SemanticsData data = _data(tester, 'test_email_field');
      expect(data.flagsCollection.isTextField, isTrue);
      expect(
        find.byKey(const ValueKey<String>('test_email_field')),
        findsOneWidget,
      );
      expect(
        _data(tester, 'test_email_clear_icon_button').flagsCollection.isButton,
        isTrue,
      );

      await tester.enterText(
        find.bySemanticsIdentifier('test_email_field'),
        'demo@milainvest.app',
      );
      expect(find.text('demo@milainvest.app'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AppTextField: el error lleva <id>_error_text', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        const AppTextField(
          id: 'test_document_field',
          label: 'Documento',
          errorText: 'Revisa el número de documento.',
        ),
      );

      expect(
        AppTextField.errorIdOf('test_document_field'),
        'test_document_field_error_text',
      );
      final SemanticsData error = _data(
        tester,
        'test_document_field_error_text',
      );
      expect(error.label, 'Revisa el número de documento.');
      expect(
        _data(tester, 'test_document_field').flagsCollection.isTextField,
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('AppTextField: el error conserva su id con el campo enfocado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, const _ErrorAfterTyping());

      await tester.enterText(
        find.bySemanticsIdentifier('test_email_field'),
        'no-es-email',
      );
      await tester.pump();

      expect(
        _data(tester, 'test_email_field_error_text').label,
        'Escribe un correo válido.',
      );
      expect(
        _data(tester, 'test_email_field').flagsCollection.isTextField,
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('AppTextField.numeric solo acepta dígitos en modo entero', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        AppTextField.numeric(
          id: 'test_quantity_field',
          label: 'Cantidad',
          controller: controller,
          allowDecimal: false,
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey<String>('test_quantity_field')),
        '1a2.5',
      );
      expect(controller.text, '125');
    });

    testWidgets('AppChip: id en el nodo con isButton y selected', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool? selected;
      await _pump(
        tester,
        AppChip(
          id: 'test_country_co_chip',
          label: 'CO',
          selected: true,
          onSelected: (bool value) => selected = value,
        ),
      );

      final SemanticsData data = _data(tester, 'test_country_co_chip');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isSelected, Tristate.isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await tester.tap(find.bySemanticsIdentifier('test_country_co_chip'));
      expect(selected, isFalse);
      handle.dispose();
    });

    testWidgets('AppCheckbox: id en el nodo con isChecked y tap', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool? next;
      await _pump(
        tester,
        AppCheckbox(
          id: 'test_accept_checkbox',
          label: 'Acepto el aviso de simulación',
          value: false,
          onChanged: (bool value) => next = value,
        ),
      );

      final SemanticsData data = _data(tester, 'test_accept_checkbox');
      expect(data.flagsCollection.isChecked, CheckedState.isFalse);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.label, contains('Acepto'));

      await tester.tap(find.bySemanticsIdentifier('test_accept_checkbox'));
      expect(next, isTrue);
      handle.dispose();
    });

    testWidgets('AppSegmentedControl: id en la raíz y en cada segmento', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      String? changed;
      await _pump(
        tester,
        AppSegmentedControl<String>(
          id: 'test_side_segmented',
          selected: 'buy',
          onChanged: (String value) => changed = value,
          segments: const <AppSegment<String>>[
            AppSegment<String>(
              id: 'test_side_buy_segment',
              value: 'buy',
              label: 'Comprar',
            ),
            AppSegment<String>(
              id: 'test_side_sell_segment',
              value: 'sell',
              label: 'Vender',
            ),
          ],
        ),
      );

      expect(find.bySemanticsIdentifier('test_side_segmented'), findsOneWidget);
      final SemanticsData buy = _data(tester, 'test_side_buy_segment');
      final SemanticsData sell = _data(tester, 'test_side_sell_segment');
      expect(buy.flagsCollection.isButton, isTrue);
      expect(buy.flagsCollection.isSelected, Tristate.isTrue);
      expect(sell.flagsCollection.isSelected, Tristate.isFalse);
      expect(sell.hasAction(SemanticsAction.tap), isTrue);

      await tester.tap(find.bySemanticsIdentifier('test_side_sell_segment'));
      expect(changed, 'sell');
      handle.dispose();
    });

    testWidgets('AppBadge y AppBanner exponen su valor con el id', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppBadge(
              id: 'test_simulated_badge',
              label: 'Simulado',
              tone: AppBadgeTone.accent,
            ),
            AppBanner(
              id: 'test_error_banner',
              message: 'No tienes saldo suficiente en COP.',
              tone: AppBannerTone.error,
            ),
          ],
        ),
      );

      expect(_data(tester, 'test_simulated_badge').label, 'Simulado');
      expect(
        _data(tester, 'test_error_banner').label,
        'No tienes saldo suficiente en COP.',
      );
      handle.dispose();
    });

    testWidgets('AppTappable: la raíz es botón y las partes conservan su id', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int taps = 0;
      await _pump(
        tester,
        AppTappable(
          id: 'test_position_item_BAP-PE',
          onTap: () => taps++,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('BAP'),
              Identified(
                id: 'test_position_item_BAP-PE_pnl_text',
                child: Text('+7,89 %'),
              ),
            ],
          ),
        ),
      );

      final SemanticsData root = _data(tester, 'test_position_item_BAP-PE');
      expect(root.flagsCollection.isButton, isTrue);
      expect(root.hasAction(SemanticsAction.tap), isTrue);
      expect(
        _data(tester, 'test_position_item_BAP-PE_pnl_text').label,
        '+7,89 %',
      );

      await tester.tap(find.bySemanticsIdentifier('test_position_item_BAP-PE'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('AppDialog: id en la raíz y en cada acción', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool? result;
      await _pump(
        tester,
        Builder(
          builder: (BuildContext context) => AppButton(
            id: 'test_open_button',
            label: 'Abrir',
            onPressed: () async {
              result = await AppDialog.show(
                context,
                id: 'test_logout_dialog',
                title: 'Cerrar sesión',
                message: '¿Quieres cerrar sesión?',
                confirmId: 'test_logout_confirm_button',
                confirmLabel: 'Cerrar sesión',
                cancelId: 'test_logout_cancel_button',
                cancelLabel: 'Seguir aquí',
                destructive: true,
              );
            },
          ),
        ),
      );

      await tester.tap(find.bySemanticsIdentifier('test_open_button'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsIdentifier('test_logout_dialog'), findsOneWidget);
      expect(
        _data(tester, 'test_logout_cancel_button').flagsCollection.isButton,
        isTrue,
      );
      await tester.tap(
        find.bySemanticsIdentifier('test_logout_confirm_button'),
      );
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.bySemanticsIdentifier('test_logout_dialog'), findsNothing);
      handle.dispose();
    });

    testWidgets('AppBottomSheet: mismo id como sheet y como diálogo', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      for (final Size size in <Size>[
        const Size(360, 800),
        const Size(1440, 900),
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await _pump(
          tester,
          Builder(
            builder: (BuildContext context) => AppButton(
              id: 'test_open_button',
              label: 'Abrir',
              onPressed: () => AppBottomSheet.show<void>(
                context: context,
                id: 'test_ticket_sheet',
                builder: (BuildContext context) => const Text('Ticket'),
              ),
            ),
          ),
        );
        await tester.tap(find.bySemanticsIdentifier('test_open_button'));
        await tester.pumpAndSettle();

        expect(find.bySemanticsIdentifier('test_ticket_sheet'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      }
      addTearDown(tester.view.reset);
      handle.dispose();
    });

    testWidgets('AppSnackbar: el mensaje lleva el id', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        Builder(
          builder: (BuildContext context) => AppButton(
            id: 'test_open_button',
            label: 'Abrir',
            onPressed: () => AppSnackbar.show(
              context,
              id: 'test_deposit_snackbar',
              message: 'Depósito realizado.',
              tone: AppSnackbarTone.success,
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsIdentifier('test_open_button'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        _data(tester, 'test_deposit_snackbar').label,
        'Depósito realizado.',
      );
      handle.dispose();
    });

    testWidgets('AppScaffold: id de vista, badge y acciones', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AppScaffold(
            id: 'test_detail_view',
            title: 'Ecopetrol',
            leading: AppIconButton(
              id: 'test_detail_back_icon_button',
              icon: AppIcons.back,
              tooltip: 'Volver',
              onPressed: () {},
            ),
            badge: const AppBadge(
              id: 'test_simulated_badge',
              label: 'Simulado',
              tone: AppBadgeTone.accent,
            ),
            bottomBar: AppButton(
              id: 'test_detail_buy_button',
              label: 'Comprar',
              variant: AppButtonVariant.buy,
              onPressed: () {},
            ),
            body: const Identified(
              id: 'test_detail_state_data',
              child: Text('contenido'),
            ),
          ),
        ),
      );

      for (final String id in <String>[
        'test_detail_view',
        'test_detail_back_icon_button',
        'test_simulated_badge',
        'test_detail_buy_button',
        'test_detail_state_data',
      ]) {
        expect(find.bySemanticsIdentifier(id), findsOneWidget, reason: id);
      }
      handle.dispose();
    });

    testWidgets('AppShimmer no anima si el sistema pide no animar', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const AppShimmer(child: AppShimmerBox(width: 120, height: 20)),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AppShimmerBox), findsOneWidget);
    });
  });
}

class _ErrorAfterTyping extends StatefulWidget {
  const _ErrorAfterTyping();

  @override
  State<_ErrorAfterTyping> createState() => _ErrorAfterTypingState();
}

class _ErrorAfterTypingState extends State<_ErrorAfterTyping> {
  String? _error;

  @override
  Widget build(BuildContext context) => AppTextField(
    id: 'test_email_field',
    label: 'Correo',
    errorText: _error,
    onChanged: (String value) =>
        setState(() => _error = 'Escribe un correo válido.'),
  );
}
