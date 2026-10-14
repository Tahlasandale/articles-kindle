import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mail/kindle_mailer.dart';
import '../../data/secret_store.dart';
import '../../state/providers.dart';
import '../theme/tokens.dart';
import 'to_read_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context)!;
    final settings = ref.watch(currentSettingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSettings),
        actions: const [
          ThemeButton(),
          SizedBox(width: Eink.space2),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Eink.space3,
          Eink.space3,
          Eink.space3,
          Eink.space8,
        ),
        children: [
          _Section(title: l10n.settingsKindleSection),
          _Field(
            label: l10n.settingsKindleAddress,
            hint: l10n.settingsKindleAddressHint,
            value: settings.kindleAddress,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) =>
                controller.edit((s) => s.copyWith(kindleAddress: v)),
          ),
          _HelperLink(
            label: l10n.settingsKindleLink,
            url: 'https://www.amazon.fr/hz/mycd/myx#/home/settings/payment',
          ),
          _Field(
            label: l10n.settingsBookTitle,
            hint: l10n.settingsBookTitleHint,
            value: settings.bookTitle,
            onChanged: (v) => controller.edit((s) => s.copyWith(bookTitle: v)),
          ),
          _Section(title: l10n.settingsSmtpSection),
          _Field(
            label: l10n.settingsSmtpHost,
            value: settings.smtpHost,
            onChanged: (v) => controller.edit((s) => s.copyWith(smtpHost: v)),
          ),
          _Field(
            label: l10n.settingsSmtpPort,
            value: '${settings.smtpPort}',
            keyboardType: TextInputType.number,
            onChanged: (v) => controller.edit(
              (s) => s.copyWith(smtpPort: int.tryParse(v) ?? s.smtpPort),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Eink.space2),
            child: Wrap(
              spacing: Eink.space2,
              children: [
                ActionChip(
                  label: const Text('Port 465 (SSL / 4G-5G)'),
                  avatar: settings.smtpPort == 465
                      ? const Icon(Icons.check, size: 16)
                      : null,
                  onPressed: () =>
                      controller.edit((s) => s.copyWith(smtpPort: 465)),
                ),
                ActionChip(
                  label: const Text('Port 587 (STARTTLS)'),
                  avatar: settings.smtpPort == 587
                      ? const Icon(Icons.check, size: 16)
                      : null,
                  onPressed: () =>
                      controller.edit((s) => s.copyWith(smtpPort: 587)),
                ),
              ],
            ),
          ),
          _Field(
            label: l10n.settingsSmtpUsername,
            value: settings.smtpUsername,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) =>
                controller.edit((s) => s.copyWith(smtpUsername: v)),
          ),
          _Field(
            label: l10n.settingsSmtpSender,
            hint: l10n.settingsSmtpSenderHint,
            value: settings.smtpSender,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => controller.edit((s) => s.copyWith(smtpSender: v)),
          ),
          const _PasswordField(),
          _HelperLink(
            label: l10n.settingsGoogleLink,
            url: 'https://myaccount.google.com/apppasswords',
          ),
          SwitchListTile(
            value: settings.smtpUseTls,
            onChanged: (v) => controller.edit((s) => s.copyWith(smtpUseTls: v)),
            title: Text(l10n.settingsSmtpTls),
            subtitle: Text(l10n.settingsSmtpTlsRequired),
            contentPadding: EdgeInsets.zero,
          ),
          const _SmtpTestButton(),
          _Section(title: l10n.settingsEpubSection),
          SwitchListTile(
            value: settings.downloadImages,
            onChanged: (v) =>
                controller.edit((s) => s.copyWith(downloadImages: v)),
            title: Text(l10n.settingsEpubImages),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: settings.grayscaleImages,
            onChanged: (v) =>
                controller.edit((s) => s.copyWith(grayscaleImages: v)),
            title: Text(l10n.settingsEpubGrayscale),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: settings.translateToFrench,
            onChanged: (v) =>
                controller.edit((s) => s.copyWith(translateToFrench: v)),
            title: const Text('Traduire en français (MyMemory)'),
            subtitle: const Text(
              'Traduit automatiquement le contenu anglais à l\'ajout.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          _Field(
            label: l10n.settingsEpubImageWidth,
            value: '${settings.imageMaxWidth}',
            keyboardType: TextInputType.number,
            onChanged: (v) => controller.edit(
              (s) =>
                  s.copyWith(imageMaxWidth: int.tryParse(v) ?? s.imageMaxWidth),
            ),
          ),
          _Field(
            label: l10n.settingsEpubSizeLimit,
            value: '${settings.sizeLimitMb}',
            keyboardType: TextInputType.number,
            suffix: 'Mo',
            onChanged: (v) => controller.edit(
              (s) => s.copyWith(sizeLimitMb: int.tryParse(v) ?? s.sizeLimitMb),
            ),
          ),
          _Section(title: l10n.settingsThemeSection),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l10n.settingsThemeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l10n.settingsThemeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(l10n.settingsThemeDark),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) =>
                controller.edit((s) => s.copyWith(themeMode: selection.first)),
          ),
          _Section(title: l10n.settingsDataSection),
          Wrap(
            spacing: Eink.space2,
            runSpacing: Eink.space2,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final json = await ref
                      .read(settingsBackupServiceProvider)
                      .exportJson();
                  await Clipboard.setData(ClipboardData(text: json));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.settingsExportCopied)),
                    );
                },
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(l10n.settingsExport),
              ),
              OutlinedButton.icon(
                onPressed: () => _showImportDialog(context, ref),
                icon: const Icon(Icons.file_download_outlined),
                label: Text(l10n.settingsImport),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final purged = await ref
                      .read(articleServiceProvider)
                      .purgeSentContent();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('$purged')));
                },
                icon: const Icon(Icons.delete_sweep_outlined),
                label: Text(l10n.settingsPurge),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context)!;
    final textController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsImport),
        content: TextField(
          controller: textController,
          maxLines: 6,
          decoration: InputDecoration(hintText: l10n.settingsImportHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(settingsBackupServiceProvider)
                    .importJson(textController.text);
                ref.invalidate(settingsProvider);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(l10n.settingsImportSuccess)),
                  );
              } catch (e) {
                if (!dialogContext.mounted) return;
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(l10n.settingsImportError('$e'))),
                  );
              }
            },
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Eink.space4, bottom: Eink.space2),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.suffix,
    this.keyboardType,
  });

  final String label;
  final String? hint;
  final String value;
  final String? suffix;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Eink.space3),
      child: TextFormField(
        initialValue: value,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
        ),
      ),
    );
  }
}

/// Le mot de passe n'est jamais dans l'état de l'interface plus d'une seconde :
/// il va droit dans le Keystore.
class _PasswordField extends ConsumerStatefulWidget {
  const _PasswordField();

  @override
  ConsumerState<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends ConsumerState<_PasswordField> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save(String text) {
    final clean = text.trim().replaceAll(' ', '');
    ref.read(secretStoreProvider).writePassword(clean);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: Eink.space3),
      child: TextField(
        controller: _controller,
        obscureText: true,
        onChanged: _save,
        onSubmitted: _save,
        decoration: InputDecoration(
          labelText: l10n.settingsSmtpPassword,
          helperText: 'Espaces supprimés automatiquement (ex: abcd efgh …)',
          suffixIcon: IconButton(
            icon: Icon(_saving ? Icons.hourglass_empty : Icons.save_outlined),
            tooltip: 'Enregistrer le mot de passe',
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    final clean = _controller.text.trim().replaceAll(' ', '');
                    await ref.read(secretStoreProvider).writePassword(clean);
                    if (!mounted) return;
                    _controller.clear();
                    setState(() => _saving = false);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(l10n.settingsSmtpPassword)),
                      );
                  },
          ),
        ),
      ),
    );
  }
}

class _SmtpTestButton extends ConsumerStatefulWidget {
  const _SmtpTestButton();

  @override
  ConsumerState<_SmtpTestButton> createState() => _SmtpTestButtonState();
}

class _SmtpTestButtonState extends ConsumerState<_SmtpTestButton> {
  bool _testing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: Eink.space2, bottom: Eink.space3),
      child: OutlinedButton.icon(
        onPressed: _testing
            ? null
            : () async {
                setState(() => _testing = true);
                final outcome = await ref.read(mailerProvider).sendTest();
                if (!mounted) return;
                setState(() => _testing = false);
                final message = switch (outcome) {
                  SendSucceeded() => l10n.sendTestSuccess,
                  SendFailed(:final reason) => reason,
                };
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
              },
        icon: _testing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send_outlined),
        label: Text(l10n.sendTestButton),
      ),
    );
  }
}

class _HelperLink extends StatelessWidget {
  const _HelperLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: Eink.space1, bottom: Eink.space3),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.open_in_new,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: Eink.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    url,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              visualDensity: VisualDensity.compact,
              tooltip: l10n.linkCopied,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
