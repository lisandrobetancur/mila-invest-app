part of 'settings.dart';

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    ),
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: <Widget>[
        _InfoRow(
          id: AppCrossIds.settingsAccountNameText,
          label: context.tr('app_cross.settings.account_name'),
          value: user.fullName,
        ),
        _InfoRow(
          id: AppCrossIds.settingsAccountEmailText,
          label: context.tr('app_cross.settings.account_email'),
          value: user.email,
        ),
        _InfoRow(
          id: AppCrossIds.settingsAccountCountryText,
          label: context.tr('app_cross.settings.account_country'),
          value: context.tr(
            'app_cross.country.${user.country.code.toLowerCase()}',
          ),
        ),
        _InfoRow(
          id: AppCrossIds.settingsAccountDocumentText,
          label: context.tr('app_cross.settings.account_document'),
          value:
              '${user.documentType.code} '
              '${Formatters.maskDocumentTail(user.documentLast4)}',
        ),
      ],
    ),
  );
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.info});

  final AppInfo info;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Identified(
            id: AppCrossIds.settingsVersionText,
            child: Text(
              context.tr(
                'app_cross.settings.version',
                namedArgs: <String, String>{'version': info.version},
              ),
              style: style,
            ),
          ),
          if (info.showApiMode) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            Identified(
              id: AppCrossIds.settingsApiModeText,
              child: Text(
                context.tr(
                  'app_cross.settings.api_mode',
                  namedArgs: <String, String>{'mode': info.apiMode},
                ),
                style: style,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.id, required this.label, required this.value});

  final String id;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSpacing.sm,
        children: <Widget>[
          Text(label, style: textTheme.bodyMedium),
          Identified(
            id: id,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.titleMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
