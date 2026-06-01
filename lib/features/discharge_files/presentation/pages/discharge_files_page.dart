import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:amex5/core/ble/ble_service.dart';
import 'package:amex5/core/ble/widgets/ble_widgets.dart';
import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/theme/app_theme.dart';
import 'package:amex5/features/discharge_files/data/datasources/discharge_files_remote_datasource.dart';
import 'package:amex5/features/discharge_files/domain/repositories/discharge_files_repository.dart';

import '../../domain/entities/discharge_file_entities.dart';
import '../bloc/discharge_files_cubit.dart';

class DischargeFilesPage extends StatelessWidget {
  const DischargeFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = getIt<BleService>();
    final repository = DischargeFilesRepository(
      DischargeFilesRemoteDataSource(getIt<Dio>()),
    );
    return BlocProvider(
      create: (_) => DischargeFilesCubit(bluetoothService, repository),
      child: _DischargeFilesView(bluetoothService: bluetoothService),
    );
  }
}

class _DischargeFilesView extends StatefulWidget {
  final BleService bluetoothService;

  const _DischargeFilesView({required this.bluetoothService});

  @override
  State<_DischargeFilesView> createState() => _DischargeFilesViewState();
}

class _DischargeFilesViewState extends State<_DischargeFilesView> {
  bool _initialScanRequested = false;

  @override
  void initState() {
    super.initState();
    widget.bluetoothService.addListener(_maybeStartInitialScan);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startInitialScan());
  }

  @override
  void dispose() {
    widget.bluetoothService.removeListener(_maybeStartInitialScan);
    super.dispose();
  }

  void _maybeStartInitialScan() {
    if (!mounted ||
        _initialScanRequested ||
        widget.bluetoothService.isConnected) {
      return;
    }
    if (!widget.bluetoothService.isBluetoothOn) return;
    if (widget.bluetoothService.connectionState !=
        BleConnectionState.disconnected) {
      return;
    }
    _initialScanRequested = true;
    unawaited(widget.bluetoothService.startScan());
  }

  Future<void> _startInitialScan() async {
    if (_initialScanRequested || widget.bluetoothService.isConnected) return;
    if (!widget.bluetoothService.isBluetoothOn) return;
    _initialScanRequested = true;
    await widget.bluetoothService.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DischargeFilesCubit, DischargeFilesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _Header(bluetoothService: widget.bluetoothService, state: state),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 360,
                      child: _BluetoothPanel(
                        bluetoothService: widget.bluetoothService,
                        state: state,
                      ),
                    ),
                    Container(width: 1, color: AppColors.border),
                    Expanded(flex: 4, child: _FilesPanel(state: state)),
                    Container(width: 1, color: AppColors.border),
                    Expanded(flex: 3, child: _PreviewPanel(state: state)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final BleService bluetoothService;
  final DischargeFilesState state;

  const _Header({required this.bluetoothService, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bluetoothService,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.perm_media_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'DÉCHARGEMENT FICHIER',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 15,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              _BluetoothAdapterBadge(bluetoothService: bluetoothService),
              const SizedBox(width: 8),
              BleStatusBadge(state: bluetoothService.connectionState),
              const Spacer(),
              if (state.transferId != null)
                Text(
                  '${state.receivedCount} / ${state.totalFiles} reçus • ${state.uploadedCount} envoyés',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: state.transferCompleted
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BluetoothPanel extends StatelessWidget {
  final BleService bluetoothService;
  final DischargeFilesState state;

  const _BluetoothPanel({required this.bluetoothService, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bluetoothService,
      builder: (context, _) {
        final isBusy =
            bluetoothService.connectionState == BleConnectionState.scanning ||
            bluetoothService.connectionState == BleConnectionState.connecting;
        return Container(
          height: double.infinity,
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: _PanelCard(
                  title: 'Connexion bluetooth',
                  icon: Icons.bluetooth_searching,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoLine(
                        icon: Icons.settings_bluetooth,
                        label: 'BLUETOOTH',
                        value: _adapterLabel(bluetoothService.adapterState),
                        color: bluetoothService.isBluetoothReady
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(height: 8),
                      _InfoLine(
                        icon: Icons.devices_other_outlined,
                        label: 'APPAREIL',
                        value:
                            bluetoothService.connectedDevice?.name ??
                            'Aucun appareil connecté',
                        color: bluetoothService.isConnected
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      if (bluetoothService.errorMessage != null) ...[
                        const SizedBox(height: 10),
                        _InlineMessage(
                          message: bluetoothService.errorMessage!,
                          color: AppColors.error,
                          icon: Icons.error_outline,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SmallActionButton(
                              label:
                                  bluetoothService.connectionState ==
                                      BleConnectionState.scanning
                                  ? 'Recherche'
                                  : 'Rechercher',
                              icon: Icons.radar_outlined,
                              loading:
                                  bluetoothService.connectionState ==
                                  BleConnectionState.scanning,
                              onPressed: isBusy || bluetoothService.isConnected
                                  ? null
                                  : bluetoothService.startScan,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SmallActionButton(
                              label: 'Déconnecter',
                              icon: Icons.bluetooth_disabled,
                              outlined: true,
                              onPressed: bluetoothService.isConnected
                                  ? bluetoothService.disconnect
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _TransferSummary(state: state),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: AppColors.surfaceVariant,
                child: Row(
                  children: [
                    const Icon(
                      Icons.memory_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${bluetoothService.scanResults.length} appareil(s) détecté(s)',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bluetoothService.isConnected
                    ? _ConnectedDevice(bluetoothService: bluetoothService)
                    : _DeviceList(bluetoothService: bluetoothService),
              ),
            ],
          ),
        );
      },
    );
  }

  String _adapterLabel(BluetoothAdapterState state) {
    return switch (state) {
      BluetoothAdapterState.on => 'Actif',
      BluetoothAdapterState.off => 'Désactivé',
      BluetoothAdapterState.turningOn => 'Activation',
      BluetoothAdapterState.turningOff => 'Désactivation',
      BluetoothAdapterState.unavailable => 'Indisponible',
      BluetoothAdapterState.unauthorized => 'Non autorisé',
      BluetoothAdapterState.unknown => 'Inconnu',
    };
  }
}

class _TransferSummary extends StatelessWidget {
  final DischargeFilesState state;

  const _TransferSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: _PanelCard(
        title: 'Transfert',
        icon: Icons.folder_copy_outlined,
        child: Column(
          children: [
            _MetricLine(label: 'ID', value: state.transferId ?? '-'),
            _MetricLine(
              label: 'Fichiers',
              value: '${state.receivedCount} / ${state.totalFiles}',
            ),
            _MetricLine(label: 'Taille', value: state.totalSizeLabel),
            _MetricLine(
              label: 'Serveur',
              value: '${state.uploadedCount} envoyé(s)',
              color: state.uploadedCount > 0
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
            if (state.transferCompleted)
              const _InlineMessage(
                message: 'Transfert bluetooth terminé.',
                color: AppColors.success,
                icon: Icons.verified_outlined,
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  final BleService bluetoothService;

  const _DeviceList({required this.bluetoothService});

  @override
  Widget build(BuildContext context) {
    if (bluetoothService.connectionState == BleConnectionState.scanning &&
        bluetoothService.scanResults.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (bluetoothService.scanResults.isEmpty) {
      return const Center(
        child: Text('AUCUN APPAREIL DÉTECTÉ', style: AppTextStyles.bodyMedium),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bluetoothService.scanResults.length,
      itemBuilder: (context, index) {
        final device = bluetoothService.scanResults[index];
        return BleDeviceTile(
          device: device,
          onConnect: () => bluetoothService.connectToDevice(device),
        );
      },
    );
  }
}

class _ConnectedDevice extends StatelessWidget {
  final BleService bluetoothService;

  const _ConnectedDevice({required this.bluetoothService});

  @override
  Widget build(BuildContext context) {
    final device = bluetoothService.connectedDevice;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bluetooth_connected,
              size: 42,
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              device?.name ?? 'Appareil connecté',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              device?.id ?? '',
              style: AppTextStyles.mono.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilesPanel extends StatelessWidget {
  final DischargeFilesState state;

  const _FilesPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              _HeaderMetric(
                label: 'ANNONCÉS',
                value: '${state.totalFiles}',
                icon: Icons.list_alt_outlined,
              ),
              const SizedBox(width: 10),
              _HeaderMetric(
                label: 'REÇUS',
                value: '${state.receivedCount}',
                icon: Icons.download_done_outlined,
              ),
              const SizedBox(width: 10),
              _HeaderMetric(
                label: 'ENVOYÉS',
                value: '${state.uploadedCount}',
                icon: Icons.cloud_done_outlined,
              ),
              const Spacer(),
              SizedBox(
                width: 154,
                child: _SmallActionButton(
                  label: state.isUploadingAll ? 'Upload' : 'Tout envoyer',
                  icon: Icons.cloud_upload_outlined,
                  loading: state.isUploadingAll,
                  onPressed: state.canUploadAll
                      ? context.read<DischargeFilesCubit>().uploadAll
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 42,
                child: _SmallActionButton(
                  label: '',
                  icon: Icons.refresh_outlined,
                  outlined: true,
                  onPressed: state.isUploadingAll
                      ? null
                      : context.read<DischargeFilesCubit>().reset,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.files.isEmpty
              ? const _EmptyFiles()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return _FileTile(
                      file: file,
                      selected: state.selectedFile?.id == file.id,
                      onTap: () => context
                          .read<DischargeFilesCubit>()
                          .selectFile(file.id),
                      onUpload: file.received
                          ? () => context
                                .read<DischargeFilesCubit>()
                                .uploadFile(file.id)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyFiles extends StatelessWidget {
  const _EmptyFiles();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 48,
            color: AppColors.textDisabled.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          const Text('AUCUN FICHIER REÇU', style: AppTextStyles.labelSmall),
          const SizedBox(height: 6),
          const Text(
            'Connectez l’appareil bluetooth et lancez le transfert depuis la tablette.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final ReceivedDischargeFile file;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onUpload;

  const _FileTile({
    required this.file,
    required this.selected,
    required this.onTap,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(file);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.card,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Icon(_fileIcon(file), size: 17, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${file.mimeType.isEmpty ? file.extension : file.mimeType} • ${file.sizeLabel}',
                      style: AppTextStyles.mono.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (file.metadata.label.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        file.metadata.label,
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (file.errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        file.errorMessage!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (file.uploadStatus == DischargeFileUploadStatus.uploading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                )
              else
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: onUpload,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: BorderSide(color: color.withValues(alpha: 0.65)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      file.uploadStatus == DischargeFileUploadStatus.uploaded
                          ? 'RENVOYER'
                          : 'ENVOYER',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(ReceivedDischargeFile file) {
    return switch (file.uploadStatus) {
      DischargeFileUploadStatus.uploaded => AppColors.success,
      DischargeFileUploadStatus.uploading => AppColors.accent,
      DischargeFileUploadStatus.error => AppColors.error,
      DischargeFileUploadStatus.pending =>
        file.received ? AppColors.info : AppColors.textSecondary,
    };
  }

  IconData _fileIcon(ReceivedDischargeFile file) {
    if (file.isImage) return Icons.image_outlined;
    if (file.isVideo) return Icons.movie_outlined;
    if (!file.received) return Icons.schedule_outlined;
    return Icons.insert_drive_file_outlined;
  }
}

class _PreviewPanel extends StatelessWidget {
  final DischargeFilesState state;

  const _PreviewPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final file = state.selectedFile;
    if (file == null) return const _NoSelection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Icon(_previewIcon(file), size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file.fileName,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 118,
                child: _SmallActionButton(
                  label:
                      file.uploadStatus == DischargeFileUploadStatus.uploading
                      ? 'Upload'
                      : 'Envoyer',
                  icon: Icons.cloud_upload_outlined,
                  loading:
                      file.uploadStatus == DischargeFileUploadStatus.uploading,
                  onPressed: file.received
                      ? () => context.read<DischargeFilesCubit>().uploadFile(
                          file.id,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: _FilePreview(file: file),
          ),
        ),
        _FileMetadataPanel(file: file),
      ],
    );
  }

  IconData _previewIcon(ReceivedDischargeFile file) {
    if (file.isImage) return Icons.image_outlined;
    if (file.isVideo) return Icons.movie_outlined;
    return Icons.insert_drive_file_outlined;
  }
}

class _FilePreview extends StatelessWidget {
  final ReceivedDischargeFile file;

  const _FilePreview({required this.file});

  @override
  Widget build(BuildContext context) {
    if (!file.received || file.path == null) {
      return const _PreviewPlaceholder(
        icon: Icons.hourglass_empty_outlined,
        title: 'Fichier en attente',
        message:
            'Le manifeste est reçu, mais le contenu du fichier ne l’est pas encore.',
      );
    }

    final localFile = File(file.path!);
    if (file.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          color: AppColors.background,
          child: Image.file(
            localFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const _PreviewPlaceholder(
                  icon: Icons.broken_image_outlined,
                  title: 'Image illisible',
                  message:
                      'Le fichier existe, mais Flutter ne peut pas l’afficher.',
                ),
          ),
        ),
      );
    }

    if (file.isVideo) {
      return _VideoPreview(path: file.path!);
    }

    return _PreviewPlaceholder(
      icon: Icons.insert_drive_file_outlined,
      title: 'Aperçu non disponible',
      message: file.path!,
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String path;

  const _VideoPreview({required this.path});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    unawaited(_player.open(Media(widget.path), play: false));
  }

  @override
  void didUpdateWidget(covariant _VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      unawaited(_player.open(Media(widget.path), play: false));
    }
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(child: Video(controller: _controller)),
            Positioned(
              left: 12,
              bottom: 12,
              child: StreamBuilder<bool>(
                stream: _player.stream.playing,
                builder: (context, snapshot) {
                  final playing = snapshot.data ?? false;
                  return ElevatedButton.icon(
                    onPressed: _player.playOrPause,
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(playing ? 'PAUSE' : 'LECTURE'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PreviewPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: AppColors.textDisabled),
              const SizedBox(height: 12),
              Text(title.toUpperCase(), style: AppTextStyles.labelSmall),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoSelection extends StatelessWidget {
  const _NoSelection();

  @override
  Widget build(BuildContext context) {
    return const _PreviewPlaceholder(
      icon: Icons.visibility_outlined,
      title: 'Aucun fichier sélectionné',
      message: 'Sélectionnez un fichier reçu pour l’afficher ici.',
    );
  }
}

class _FileMetadataPanel extends StatelessWidget {
  final ReceivedDischargeFile file;

  const _FileMetadataPanel({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MetricLine(label: 'taskCode', value: file.metadata.taskCode),
          _MetricLine(label: 'ref', value: file.metadata.ref),
          _MetricLine(label: 'label', value: file.metadata.label),
          _MetricLine(label: 'entity', value: file.metadata.entity),
          _MetricLine(
            label: 'lastModifiedDate',
            value: file.metadata.lastModifiedDate,
          ),
          if (file.serverCode != null)
            _MetricLine(
              label: 'code serveur',
              value: file.serverCode!,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PanelCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricLine({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(label.toUpperCase(), style: AppTextStyles.labelSmall),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.mono.copyWith(
                fontSize: 10,
                color: color ?? AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _InlineMessage({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  const _SmallActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? AppColors.primary : Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          );

    final textStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.7,
    );

    return SizedBox(
      height: 36,
      child: outlined
          ? OutlinedButton(
              onPressed: loading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                textStyle: textStyle,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.35,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                textStyle: textStyle,
              ),
              child: child,
            ),
    );
  }
}

class _BluetoothAdapterBadge extends StatelessWidget {
  final BleService bluetoothService;

  const _BluetoothAdapterBadge({required this.bluetoothService});

  @override
  Widget build(BuildContext context) {
    final ready = bluetoothService.isBluetoothReady;
    final color = ready ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ready ? Icons.bluetooth : Icons.bluetooth_disabled,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            ready ? 'BLUETOOTH ACTIF' : 'BLUETOOTH INACTIF',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
