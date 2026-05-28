import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amex5/core/ble/ble_service.dart';
import 'package:amex5/core/ble/widgets/ble_widgets.dart';
import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/theme/app_theme.dart';
import 'package:amex5/features/agent_works/data/models/task_model.dart';
import 'package:amex5/features/agent_works/domain/repositories/agent_works_repository.dart';

import '../../domain/entities/discharge_entities.dart';
import '../bloc/discharge_works_cubit.dart';
import '../widgets/discharge_widgets.dart';

class DischargeWorksPage extends StatelessWidget {
  const DischargeWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bleService = getIt<BleService>();
    return BlocProvider(
      create: (_) =>
          DischargeWorksCubit(getIt<AgentWorksRepository>(), bleService),
      child: _DischargeWorksView(bleService: bleService),
    );
  }
}

class _DischargeWorksView extends StatefulWidget {
  final BleService bleService;

  const _DischargeWorksView({required this.bleService});

  @override
  State<_DischargeWorksView> createState() => _DischargeWorksViewState();
}

class _DischargeWorksViewState extends State<_DischargeWorksView> {
  bool _initialScanRequested = false;

  @override
  void initState() {
    super.initState();
    widget.bleService.addListener(_maybeStartInitialScan);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startInitialScan());
  }

  @override
  void dispose() {
    widget.bleService.removeListener(_maybeStartInitialScan);
    super.dispose();
  }

  void _maybeStartInitialScan() {
    if (!mounted || _initialScanRequested || widget.bleService.isConnected) {
      return;
    }
    if (!widget.bleService.isBluetoothOn) return;
    if (widget.bleService.connectionState != BleConnectionState.disconnected) {
      return;
    }
    _initialScanRequested = true;
    unawaited(widget.bleService.startScan());
  }

  Future<void> _startInitialScan() async {
    if (_initialScanRequested || widget.bleService.isConnected) return;
    if (!widget.bleService.isBluetoothOn) return;
    _initialScanRequested = true;
    await widget.bleService.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DischargeWorksCubit, DischargeWorksCubitState>(
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
              _buildAppBar(state),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 380,
                      child: _BleReceptionPanel(bleService: widget.bleService),
                    ),
                    Container(width: 1, color: AppColors.border),
                    Expanded(child: _PayloadPanel(state: state)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(DischargeWorksCubitState state) {
    return ListenableBuilder(
      listenable: widget.bleService,
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
                Icons.download_for_offline_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'DÉCHARGEMENT TRAVAUX',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 15,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              _AdapterBadge(bleService: widget.bleService),
              const SizedBox(width: 8),
              BleStatusBadge(state: widget.bleService.connectionState),
              const Spacer(),
              if (state.payload != null)
                Text(
                  '${state.payload!.sentCount} / ${state.payload!.totalItems} envoyés',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: state.payload!.allSent
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

class _BleReceptionPanel extends StatelessWidget {
  final BleService bleService;

  const _BleReceptionPanel({required this.bleService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bleService,
      builder: (context, _) {
        final isBusy =
            bleService.connectionState == BleConnectionState.scanning ||
            bleService.connectionState == BleConnectionState.connecting;

        return Container(
          height: double.infinity,
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: IndustrialCard(
                  title: 'Réception bluetooth',
                  icon: Icons.bluetooth_searching,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoRow(
                        icon: Icons.settings_bluetooth,
                        label: 'BLUETOOTH',
                        value: _adapterLabel(bleService.adapterState),
                        color: bleService.isBluetoothReady
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.devices_other_outlined,
                        label: 'APPAREIL',
                        value:
                            bleService.connectedDevice?.name ??
                            'Aucun appareil connecté',
                        color: bleService.isConnected
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      if (bleService.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _InlineError(message: bleService.errorMessage!),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _ConnectionActionButton(
                              label:
                                  bleService.connectionState ==
                                      BleConnectionState.scanning
                                  ? 'Recherche...'
                                  : 'Rechercher',
                              icon: Icons.radar_outlined,
                              loading:
                                  bleService.connectionState ==
                                  BleConnectionState.scanning,
                              onPressed: isBusy || bleService.isConnected
                                  ? null
                                  : bleService.startScan,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ConnectionActionButton(
                              label: 'Déconnecter',
                              icon: Icons.bluetooth_disabled,
                              onPressed: bleService.isConnected
                                  ? bleService.disconnect
                                  : null,
                              outlined: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border.symmetric(
                    horizontal: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.memory_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${bleService.scanResults.length} appareil(s) détecté(s)',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bleService.isConnected
                    ? _ConnectedDeviceView(bleService: bleService)
                    : _ScanResultsView(bleService: bleService),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: const Text(
                  'ÉCOUTE JSON BLUETOOTH ACTIVE APRÈS CONNEXION',
                  style: AppTextStyles.bodyMedium,
                ),
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

class _ScanResultsView extends StatelessWidget {
  final BleService bleService;

  const _ScanResultsView({required this.bleService});

  @override
  Widget build(BuildContext context) {
    if (bleService.connectionState == BleConnectionState.scanning &&
        bleService.scanResults.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (bleService.scanResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'AUCUN APPAREIL DÉTECTÉ',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bleService.scanResults.length,
      itemBuilder: (context, index) {
        final device = bleService.scanResults[index];
        return BleDeviceTile(
          device: device,
          onConnect: () => bleService.connectToDevice(device),
        );
      },
    );
  }
}

class _ConnectedDeviceView extends StatelessWidget {
  final BleService bleService;

  const _ConnectedDeviceView({required this.bleService});

  @override
  Widget build(BuildContext context) {
    final device = bleService.connectedDevice;
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

class _PayloadPanel extends StatelessWidget {
  final DischargeWorksCubitState state;

  const _PayloadPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final payload = state.payload;
    if (payload == null) {
      return const _WaitingPayloadView();
    }

    return Column(
      children: [
        _MetricsHeader(payload: payload, state: state),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _WorksListPanel(lines: payload.works)),
              Container(width: 1, color: AppColors.border),
              Expanded(
                child: _CheckItemsListPanel(lines: payload.checkItemsWorks),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaitingPayloadView extends StatelessWidget {
  const _WaitingPayloadView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.data_object_outlined,
            size: 48,
            color: AppColors.textDisabled.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 14),
          const Text(
            'AUCUNE DONNÉE JSON REÇUE',
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'WORKS: 0 • CHECK_ITEMS_WORKS: 0',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MetricsHeader extends StatelessWidget {
  final DischargePayload payload;
  final DischargeWorksCubitState state;

  const _MetricsHeader({required this.payload, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MetricTile(
                label: 'TRAVAUX',
                value: '${payload.works.length}',
                icon: Icons.work_outline,
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'CHECK ITEMS WO',
                value: '${payload.checkItemsWorks.length}',
                icon: Icons.fact_check_outlined,
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'CHECKLISTS',
                value: '${payload.totalChecklistItems}',
                icon: Icons.checklist_outlined,
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'TAILLE',
                value: payload.sizeLabel,
                icon: Icons.data_usage_outlined,
              ),
              const Spacer(),
              SizedBox(
                width: 170,
                child: PrimaryActionButton(
                  label: state.isUploadingAll ? 'Envoi...' : 'Tout envoyer',
                  icon: Icons.cloud_upload_outlined,
                  loading: state.isUploadingAll,
                  onPressed: state.canUploadAll
                      ? context.read<DischargeWorksCubit>().uploadAll
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 46,
                height: 44,
                child: OutlinedButton(
                  onPressed: state.isUploadingAll
                      ? null
                      : context.read<DischargeWorksCubit>().resetPayload,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Icon(Icons.refresh_outlined, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 46,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => _copyRawJson(context, payload.rawJson),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Icon(Icons.copy_outlined, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 3,
              value: payload.totalItems == 0
                  ? 0
                  : payload.sentCount / payload.totalItems,
              color: payload.errorCount > 0
                  ? AppColors.error
                  : AppColors.success,
              backgroundColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }

  void _copyRawJson(BuildContext context, Map<String, dynamic> rawJson) {
    final pretty = const JsonEncoder.withIndent('  ').convert(rawJson);
    Clipboard.setData(ClipboardData(text: pretty));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON reçu copié dans le presse-papier')),
    );
  }
}

class _WorksListPanel extends StatelessWidget {
  final List<DischargeWorkLine> lines;

  const _WorksListPanel({required this.lines});

  @override
  Widget build(BuildContext context) {
    return _ListPanel(
      title: 'WORKS',
      count: lines.length,
      icon: Icons.work_outline,
      emptyMessage: 'Aucun travail dans le JSON reçu.',
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          final checklistItems =
              line.work.checkListItems ?? const <TaskModel>[];
          return _UploadLineTile(
            title: line.title,
            subtitle: line.work.woDesc ?? line.work.objectDesc ?? '-',
            detail: '${checklistItems.length} item(s) checklist',
            status: line.status,
            errorMessage: line.errorMessage,
            footer: _ChecklistItemsPreview(items: checklistItems),
            onSend: () =>
                context.read<DischargeWorksCubit>().uploadWork(line.id),
          );
        },
      ),
    );
  }
}

class _CheckItemsListPanel extends StatelessWidget {
  final List<DischargeCheckItemLine> lines;

  const _CheckItemsListPanel({required this.lines});

  @override
  Widget build(BuildContext context) {
    return _ListPanel(
      title: 'CHECK_ITEMS_WORKS',
      count: lines.length,
      icon: Icons.fact_check_outlined,
      emptyMessage: 'Aucun check item work dans le JSON reçu.',
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          final checkItem = line.checkItem;
          return _UploadLineTile(
            title: line.title,
            subtitle: checkItem.woDesc ?? '-',
            detail:
                'WO ${checkItem.woCode ?? '—'} • Mobile ${checkItem.woMobileUuid ?? '—'}',
            status: line.status,
            errorMessage: line.errorMessage,
            onSend: () =>
                context.read<DischargeWorksCubit>().uploadCheckItem(line.id),
          );
        },
      ),
    );
  }
}

class _ListPanel extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final String emptyMessage;
  final Widget child;

  const _ListPanel({
    required this.title,
    required this.count,
    required this.icon,
    required this.emptyMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.surfaceVariant,
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.labelSmall),
              const Spacer(),
              Text('$count', style: AppTextStyles.monoAccent),
            ],
          ),
        ),
        Expanded(
          child: count == 0
              ? Center(
                  child: Text(
                    emptyMessage,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : child,
        ),
      ],
    );
  }
}

class _UploadLineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String detail;
  final DischargeUploadStatus status;
  final String? errorMessage;
  final VoidCallback onSend;
  final Widget? footer;

  const _UploadLineTile({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.status,
    required this.onSend,
    this.errorMessage,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);
    final isSending = status == DischargeUploadStatus.sending;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      )
                    : Icon(_statusIcon(status), size: 16, color: statusColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      detail,
                      style: AppTextStyles.mono.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        errorMessage!,
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
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: isSending ? null : onSend,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    side: BorderSide(color: statusColor.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    status == DischargeUploadStatus.sent
                        ? 'RENVOYER'
                        : 'ENVOYER',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          if (footer != null) ...[const SizedBox(height: 8), footer!],
        ],
      ),
    );
  }

  Color _statusColor(DischargeUploadStatus status) {
    return switch (status) {
      DischargeUploadStatus.pending => AppColors.textSecondary,
      DischargeUploadStatus.sending => AppColors.accent,
      DischargeUploadStatus.sent => AppColors.success,
      DischargeUploadStatus.error => AppColors.error,
    };
  }

  IconData _statusIcon(DischargeUploadStatus status) {
    return switch (status) {
      DischargeUploadStatus.pending => Icons.schedule_outlined,
      DischargeUploadStatus.sending => Icons.sync,
      DischargeUploadStatus.sent => Icons.check_circle_outline,
      DischargeUploadStatus.error => Icons.error_outline,
    };
  }
}

class _ChecklistItemsPreview extends StatelessWidget {
  final List<TaskModel> items;

  const _ChecklistItemsPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Aucun élément de checklist détecté dans ce travail.',
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          dense: true,
          initiallyExpanded: items.length <= 3,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textDisabled,
          title: Text(
            '${items.length} élément(s) de checklist',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final item in items) _ChecklistItemRow(item: item),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItemRow extends StatelessWidget {
  final TaskModel item;

  const _ChecklistItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final completed = item.completed ?? false;
    final color = completed ? AppColors.success : AppColors.textDisabled;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            completed
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.desc ?? item.longLabel ?? '-',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.code ?? '—'} • ${item.type ?? '—'} • séq. ${item.sequence ?? 0}',
                  style: AppTextStyles.mono.copyWith(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.notes!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10,
                      color: AppColors.accent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
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

class _ConnectionActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  const _ConnectionActionButton({
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
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final style = outlined
        ? OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          )
        : ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          );

    return SizedBox(
      height: 36,
      child: outlined
          ? OutlinedButton(
              onPressed: loading ? null : onPressed,
              style: style,
              child: child,
            )
          : ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: style,
              child: child,
            ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 15, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdapterBadge extends StatelessWidget {
  final BleService bleService;

  const _AdapterBadge({required this.bleService});

  @override
  Widget build(BuildContext context) {
    final ready = bleService.isBluetoothReady;
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
