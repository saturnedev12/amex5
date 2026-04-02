import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/discharge_entities.dart';
import '../bloc/discharge_works_bloc.dart';
import '../widgets/discharge_widgets.dart';
import '../../../../core/di/injection.dart';

class DischargeWorksPage extends StatelessWidget {
  const DischargeWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DischargeWorksBloc>(),
      child: const _DischargeWorksView(),
    );
  }
}

class _DischargeWorksView extends StatelessWidget {
  const _DischargeWorksView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DischargeWorksBloc, DischargeWorksState>(
      listener: _handleStateListener,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocBuilder<DischargeWorksBloc, DischargeWorksState>(
          builder: (context, state) => _buildBody(context, state),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(width: 4, height: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text('DISCHARGE WORKS'),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'v1.0',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textDisabled,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DischargeWorksState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Panneau gauche : contrôles ──────────────────────────────────
        SizedBox(
          width: 340,
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusHeader(state),
                  const SizedBox(height: 20),
                  _buildFilePickerCard(context, state),
                  const SizedBox(height: 16),
                  _buildUploadCard(context, state),
                ],
              ),
            ),
          ),
        ),

        // ── Panneau droit : preview / résultat ──────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildPreviewPanel(context, state)],
            ),
          ),
        ),
      ],
    );
  }

  // ── Status header ────────────────────────────────────────────────────────

  Widget _buildStatusHeader(DischargeWorksState state) {
    final badge = switch (state) {
      DischargeWorksInitial() => StatusBadge.idle(),
      DischargeWorksPickingFile() => StatusBadge.idle(),
      DischargeWorksFileSelected() => StatusBadge.selected(),
      DischargeWorksUploading() => StatusBadge.uploading(),
      DischargeWorksSuccess() => StatusBadge.success(),
      DischargeWorksError() => StatusBadge.error(),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('STATUT', style: AppTextStyles.labelSmall),
        badge,
      ],
    );
  }

  // ── File picker card ─────────────────────────────────────────────────────

  Widget _buildFilePickerCard(BuildContext context, DischargeWorksState state) {
    final isUploading = state is DischargeWorksUploading;
    DischargeFile? file;
    if (state is DischargeWorksFileSelected) file = state.file;
    if (state is DischargeWorksUploading) file = state.file;
    if (state is DischargeWorksSuccess) file = state.file;
    if (state is DischargeWorksError) file = state.file;

    return IndustrialCard(
      title: 'Sélection fichier',
      icon: Icons.folder_open_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zone de drop / click
          _FileDropZone(
            file: file,
            enabled: !isUploading,
            onTap: () =>
                context.read<DischargeWorksBloc>().add(PickFileEvent()),
          ),
          if (file != null) ...[
            const SizedBox(height: 12),
            _FileInfoRow(
              label: 'FICHIER',
              value: file.name,
              icon: Icons.insert_drive_file_outlined,
            ),
            const SizedBox(height: 6),
            _FileInfoRow(
              label: 'TAILLE',
              value: file.sizeLabel,
              icon: Icons.data_usage_outlined,
            ),
            const SizedBox(height: 6),
            _FileInfoRow(
              label: 'CLÉS JSON',
              value: '${file.content.length} clé(s)',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ],
      ),
    );
  }

  // ── Upload card ──────────────────────────────────────────────────────────

  Widget _buildUploadCard(BuildContext context, DischargeWorksState state) {
    final canUpload = state is DischargeWorksFileSelected;
    final isUploading = state is DischargeWorksUploading;
    final isSuccess = state is DischargeWorksSuccess;

    return IndustrialCard(
      title: 'Envoi API',
      icon: Icons.cloud_upload_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Endpoint display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    'POST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '/test_upload',
                    style: AppTextStyles.mono,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PrimaryActionButton(
            label: isSuccess ? 'Renvoyer' : 'Lancer l\'upload',
            icon: Icons.upload_outlined,
            loading: isUploading,
            onPressed: canUpload
                ? () =>
                      context.read<DischargeWorksBloc>().add(UploadFileEvent())
                : null,
          ),
          const SizedBox(height: 10),
          PrimaryActionButton(
            label: 'Réinitialiser',
            icon: Icons.refresh_outlined,
            color: AppColors.surfaceVariant,
            onPressed: isUploading
                ? null
                : () => context.read<DischargeWorksBloc>().add(ResetEvent()),
          ),
        ],
      ),
    );
  }

  // ── Preview panel ────────────────────────────────────────────────────────

  Widget _buildPreviewPanel(BuildContext context, DischargeWorksState state) {
    return switch (state) {
      DischargeWorksInitial() => _EmptyPreview(),
      DischargeWorksPickingFile() => const _LoadingPreview(
        message: 'Ouverture du sélecteur de fichier…',
      ),
      DischargeWorksFileSelected(file: final f) => _JsonPreview(
        title: 'APERÇU PAYLOAD',
        json: f.content,
        accentColor: AppColors.info,
      ),
      DischargeWorksUploading(file: final f) => _UploadingPreview(file: f),
      DischargeWorksSuccess(result: final r, file: final f) => _SuccessPreview(
        result: r,
        file: f,
      ),
      DischargeWorksError(failure: final fail, file: final f) => _ErrorPreview(
        message: fail.message,
        file: f,
      ),
    };
  }

  void _handleStateListener(BuildContext context, DischargeWorksState state) {
    if (state is DischargeWorksError && state.file == null) {
      // Erreur au niveau du pick (pas de fichier préalable)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: AppColors.surfaceVariant,
        ),
      );
    }
  }
}

// ── Sous-widgets internes ────────────────────────────────────────────────────

class _FileDropZone extends StatelessWidget {
  final DischargeFile? file;
  final bool enabled;
  final VoidCallback onTap;

  const _FileDropZone({
    required this.file,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primary.withOpacity(0.06)
              : AppColors.background,
          border: Border.all(
            color: hasFile ? AppColors.primary : AppColors.border,
            style: hasFile ? BorderStyle.solid : BorderStyle.solid,
            width: hasFile ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: enabled
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasFile
                          ? Icons.check_circle_outline
                          : Icons.upload_file_outlined,
                      size: 28,
                      color: hasFile
                          ? AppColors.primary
                          : AppColors.textDisabled,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasFile
                          ? 'CLIQUER POUR CHANGER'
                          : 'CLIQUER POUR SÉLECTIONNER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: hasFile
                            ? AppColors.primary
                            : AppColors.textDisabled,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Fichiers JSON acceptés',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _FileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _FileInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textDisabled),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.mono,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 40,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: 12),
            Text('AUCUN FICHIER SÉLECTIONNÉ', style: AppTextStyles.labelSmall),
            SizedBox(height: 6),
            Text(
              'Sélectionnez un fichier JSON pour voir son contenu',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingPreview extends StatelessWidget {
  final String message;
  const _LoadingPreview({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(message, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _JsonPreview extends StatelessWidget {
  final String title;
  final Map<String, dynamic> json;
  final Color accentColor;

  const _JsonPreview({
    required this.title,
    required this.json,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final pretty = encoder.convert(json);

    return IndustrialCard(
      title: title,
      icon: Icons.data_object_outlined,
      actions: [
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: pretty));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copié dans le presse-papier')),
            );
          },
          child: const Row(
            children: [
              Icon(
                Icons.copy_outlined,
                size: 12,
                color: AppColors.textDisabled,
              ),
              SizedBox(width: 4),
              Text(
                'COPIER',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textDisabled,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(3),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            pretty,
            style: AppTextStyles.mono.copyWith(fontSize: 11),
          ),
        ),
      ),
    );
  }
}

class _UploadingPreview extends StatelessWidget {
  final DischargeFile file;
  const _UploadingPreview({required this.file});

  @override
  Widget build(BuildContext context) {
    return IndustrialCard(
      title: 'Envoi en cours',
      icon: Icons.upload_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'TRANSMISSION DE ${file.name.toUpperCase()}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'POST /test_upload  •  ${file.sizeLabel}',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            backgroundColor: AppColors.border,
            color: AppColors.accent,
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}

class _SuccessPreview extends StatelessWidget {
  final DischargeUploadResult result;
  final DischargeFile file;

  const _SuccessPreview({required this.result, required this.file});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner succès
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UPLOAD RÉUSSI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.message ?? 'Données transmises avec succès.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(result.uploadedAt),
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Réponse serveur
        if (result.responseData != null)
          _JsonPreview(
            title: 'Réponse serveur',
            json: result.responseData!,
            accentColor: AppColors.success,
          )
        else
          IndustrialCard(
            title: 'Réponse serveur',
            icon: Icons.cloud_done_outlined,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Aucune donnée retournée par le serveur.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _ErrorPreview extends StatelessWidget {
  final String message;
  final DischargeFile? file;

  const _ErrorPreview({required this.message, this.file});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ERREUR D\'UPLOAD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(message, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (file != null) ...[
          const SizedBox(height: 16),
          _JsonPreview(
            title: 'Payload envoyé',
            json: file!.content,
            accentColor: AppColors.error,
          ),
        ],
      ],
    );
  }
}
