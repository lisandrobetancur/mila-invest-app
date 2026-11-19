part of 'register.dart';

String _countryChipId(Country country) => switch (country) {
  Country.co => AuthIds.registerCountryCoChip,
  Country.mx => AuthIds.registerCountryMxChip,
  Country.pe => AuthIds.registerCountryPeChip,
};

String _documentChipId(DocumentType type) => switch (type) {
  DocumentType.cc => AuthIds.registerDocumentCcChip,
  DocumentType.ce => AuthIds.registerDocumentCeChip,
  DocumentType.curp => AuthIds.registerDocumentCurpChip,
  DocumentType.dni => AuthIds.registerDocumentDniChip,
};

String _documentLabelKey(DocumentType type, Country country) => switch (type) {
  DocumentType.ce => 'auth.register.document_ce_${country.code.toLowerCase()}',
  DocumentType.cc ||
  DocumentType.curp ||
  DocumentType.dni => 'auth.register.document_${type.code.toLowerCase()}',
};

class _Requirement extends StatelessWidget {
  const _Requirement({
    required this.id,
    required this.labelKey,
    required this.met,
  });

  final String id;
  final String labelKey;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = met
        ? theme.market.gain
        : theme.colorScheme.onSurfaceVariant;
    final String label = context.tr(labelKey);
    final String status = context.tr(
      met
          ? 'auth.register.requirement_met'
          : 'auth.register.requirement_pending',
    );
    return Identified(
      id: id,
      label: '$label, $status',
      value: met ? 'met' : 'pending',
      replaceChildSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: <Widget>[
            Icon(
              met ? AppIcons.check : AppIcons.pending,
              size: 16,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldMessage extends StatelessWidget {
  const _FieldMessage({required this.id, required this.message});

  final String id;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    if (text == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Identified(
        id: id,
        liveRegion: true,
        child: Text(
          text,
          style: Theme.of(context).inputDecorationTheme.errorStyle,
        ),
      ),
    );
  }
}
