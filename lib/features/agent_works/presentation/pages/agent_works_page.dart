import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/theme/app_theme.dart';
import 'package:amex5/features/agent_works/data/models/wo_model.dart';
import 'package:amex5/features/agent_works/presentation/bloc/agent_works_bloc.dart';
import 'package:amex5/core/ble/ble_service.dart';

class AgentWorksPage extends StatelessWidget {
  const AgentWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AgentWorksBloc>()..add(LoadWorksEvent()),
      child: const _AgentWorksView(),
    );
  }
}

class _AgentWorksView extends StatelessWidget {
  const _AgentWorksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: BlocConsumer<AgentWorksBloc, AgentWorksState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
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
                if (state.isLoadingWorks) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state.works.isEmpty) {
                  return _buildEmptyState(context);
                }
                return Row(
                  children: [
                    Expanded(flex: 3, child: _WorksList(state: state)),
                    Container(width: 1, color: AppColors.border),
                    Expanded(flex: 2, child: _DetailPanel(state: state)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            'TRAVAUX AGENTS',
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          BlocBuilder<AgentWorksBloc, AgentWorksState>(
            builder: (context, state) {
              final loadedCount = state.checklistsByWoCode.length;
              final totalCount = state.works.length;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$loadedCount / $totalCount checklists',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: loadedCount > 0
                            ? AppColors.success
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.refresh,
                    label: 'RECHARGER',
                    onPressed: () =>
                        context.read<AgentWorksBloc>().add(LoadWorksEvent()),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.download_for_offline_outlined,
                    label: 'TOUT CHARGER',
                    onPressed: totalCount > 0
                        ? () => context.read<AgentWorksBloc>().add(
                            LoadAllChecklistsEvent(),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.save_alt,
                    label: 'JSON',
                    onPressed: state.hasAnyChecklist
                        ? () => context.read<AgentWorksBloc>().add(
                            DownloadJsonEvent(),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _BleTransferButton(hasChecklist: state.hasAnyChecklist),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            'Aucun travail disponible',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<AgentWorksBloc>().add(LoadWorksEvent()),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Recharger'),
          ),
        ],
      ),
    );
  }
}

// ── Works List (left panel) ───────────────────────────────────────────

class _WorksList extends StatelessWidget {
  final AgentWorksState state;
  const _WorksList({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selection bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.surfaceVariant,
          child: Row(
            children: [
              Text(
                '${state.works.length} travaux',
                style: AppTextStyles.labelSmall,
              ),
              const Spacer(),
              if (state.selectedWoCodes.isNotEmpty) ...[
                Text(
                  '${state.selectedWoCodes.length} sélectionné(s)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                _SmallButton(
                  label: 'CHARGER SÉLECTION',
                  onPressed: () {
                    final selected = state.works
                        .where(
                          (w) =>
                              w.woCode != null &&
                              state.selectedWoCodes.contains(w.woCode),
                        )
                        .toList();
                    context.read<AgentWorksBloc>().add(
                      LoadSelectedChecklistsEvent(selected),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ],
              _SmallButton(
                label: state.selectedWoCodes.length == state.works.length
                    ? 'TOUT DÉSÉLECTIONNER'
                    : 'TOUT SÉLECTIONNER',
                onPressed: () {
                  final bloc = context.read<AgentWorksBloc>();
                  if (state.selectedWoCodes.length == state.works.length) {
                    bloc.add(DeselectAllWorksEvent());
                  } else {
                    bloc.add(SelectAllWorksEvent());
                  }
                },
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.works.length,
            itemBuilder: (context, index) {
              final wo = state.works[index];
              return _WoTile(
                wo: wo,
                hasChecklist:
                    wo.woCode != null && state.hasChecklist(wo.woCode!),
                isLoading:
                    wo.woCode != null &&
                    state.loadingChecklists.contains(wo.woCode!),
                isSelected:
                    wo.woCode != null &&
                    state.selectedWoCodes.contains(wo.woCode!),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Single WO Tile ────────────────────────────────────────────────────

class _WoTile extends StatelessWidget {
  final WoModel wo;
  final bool hasChecklist;
  final bool isLoading;
  final bool isSelected;

  const _WoTile({
    required this.wo,
    required this.hasChecklist,
    required this.isLoading,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            if (wo.woCode != null) {
              context.read<AgentWorksBloc>().add(
                ToggleWorkSelectionEvent(wo.woCode!),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : hasChecklist
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    if (wo.woCode != null) {
                      context.read<AgentWorksBloc>().add(
                        ToggleWorkSelectionEvent(wo.woCode!),
                      );
                    }
                  },
                  activeColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.textDisabled),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                // Status indicator
                _ChecklistBadge(
                  hasChecklist: hasChecklist,
                  isLoading: isLoading,
                ),
                const SizedBox(width: 10),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'WO ${wo.woCode ?? '—'}',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (wo.woStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                wo.woStatus!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accent,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          if (wo.completed == true) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppColors.success,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        wo.woDesc ?? 'Sans description',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (wo.objectDesc != null) ...[
                            Icon(
                              Icons.settings,
                              size: 10,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                wo.objectDesc!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (wo.trade != null)
                            Text(
                              wo.trade!,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 9,
                                color: AppColors.info,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action button
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else if (!hasChecklist)
                  _SmallButton(
                    label: 'PRENDRE EN CHARGE',
                    onPressed: () {
                      if (wo.woCode != null) {
                        context.read<AgentWorksBloc>().add(
                          LoadChecklistEvent(
                            woCode: wo.woCode!,
                            act: wo.act ?? 10,
                          ),
                        );
                      }
                    },
                  )
                else
                  const Icon(
                    Icons.checklist,
                    size: 18,
                    color: AppColors.success,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Checklist Badge ───────────────────────────────────────────────────

class _ChecklistBadge extends StatelessWidget {
  final bool hasChecklist;
  final bool isLoading;

  const _ChecklistBadge({required this.hasChecklist, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: hasChecklist
            ? AppColors.success
            : AppColors.textDisabled.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: hasChecklist
              ? AppColors.success.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }
}

// ── Detail Panel (right) ──────────────────────────────────────────────

class _DetailPanel extends StatelessWidget {
  final AgentWorksState state;
  const _DetailPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final allItems = state.allCheckItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.surfaceVariant,
          child: Row(
            children: [
              const Icon(Icons.checklist, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'CHECKLIST AGRÉGÉE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${allItems.length} tâches uniques',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ),
        if (allItems.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 40,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune checklist chargée',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prenez en charge un travail pour charger sa checklist',
                    style: AppTextStyles.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final task = allItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // Type badge
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor(task.type).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          task.type ?? '—',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _typeColor(task.type),
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.desc ?? '—',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (task.code != null)
                              Text(
                                'Code: ${task.code}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 9,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (task.completed == true)
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.success,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Color _typeColor(String? type) {
    return switch (type) {
      'NUMERIC' => AppColors.info,
      'YES_NO' => AppColors.accent,
      'ITEM' => AppColors.textSecondary,
      'DATETIME' => AppColors.primary,
      'COMMENT' => AppColors.warning,
      'QUALITATIVE' => AppColors.success,
      _ => AppColors.textDisabled,
    };
  }
}

// ── BLE Transfer Button ───────────────────────────────────────────────

class _BleTransferButton extends StatelessWidget {
  final bool hasChecklist;
  const _BleTransferButton({required this.hasChecklist});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hasChecklist
          ? 'Envoyer via Bluetooth'
          : 'Chargez au moins une checklist',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: hasChecklist ? () => _showBleTransferDialog(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: hasChecklist
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: hasChecklist
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bluetooth,
                  size: 14,
                  color: hasChecklist
                      ? AppColors.primary
                      : AppColors.textDisabled,
                ),
                const SizedBox(width: 6),
                Text(
                  'BLE',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    color: hasChecklist
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBleTransferDialog(BuildContext context) {
    final bloc = context.read<AgentWorksBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Envoi Bluetooth',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisissez les données à envoyer:',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              _TransferOption(
                icon: Icons.login,
                label: 'Données de connexion',
                subtitle: 'LOGGIN',
                onTap: () {
                  Navigator.pop(dialogContext);
                  _sendBle(context, bloc.buildLoginPayload());
                },
              ),
              const SizedBox(height: 8),
              _TransferOption(
                icon: Icons.work,
                label: 'Travaux',
                subtitle: 'UPPLOAD_WORK',
                onTap: () {
                  Navigator.pop(dialogContext);
                  _sendBle(context, bloc.buildWorksPayload());
                },
              ),
              const SizedBox(height: 8),
              _TransferOption(
                icon: Icons.checklist,
                label: 'Tâches (checkItems)',
                subtitle: 'UPLOAD_TASK',
                onTap: () {
                  Navigator.pop(dialogContext);
                  _sendBle(context, bloc.buildTasksPayload());
                },
              ),
              const SizedBox(height: 8),
              _TransferOption(
                icon: Icons.all_inclusive,
                label: 'Tout envoyer',
                subtitle: 'LOGGIN + UPPLOAD_WORK',
                onTap: () {
                  Navigator.pop(dialogContext);
                  _sendBle(context, bloc.buildBlePayload());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendBle(BuildContext context, Map<String, dynamic> payload) async {
    final bleService = getIt<BleService>();
    final connected = await bleService.ensureConnected(context);

    if (connected) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Envoi Bluetooth en cours...'),
            backgroundColor: AppColors.info,
          ),
        );
      }
      await bleService.sendJson(payload);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BLE non connecté ou annulation.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}

// ── Transfer Option ───────────────────────────────────────────────────

class _TransferOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _TransferOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 12),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 9,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.surfaceVariant
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SmallButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 9,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
