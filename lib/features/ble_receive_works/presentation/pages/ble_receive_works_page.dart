import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ripple_wave/ripple_wave.dart';

import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/theme/app_theme.dart';
import 'package:amex5/features/agent_works/data/models/wo_model.dart';
import 'package:amex5/features/ble_receiver/domain/entities/ble_device_entity.dart';

import '../bloc/ble_receive_works_bloc.dart';

// ── Page root ─────────────────────────────────────────────────────────────

class BleReceiveWorksPage extends StatelessWidget {
  const BleReceiveWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BleReceiveWorksBloc>(),
      child: const _BleReceiveWorksView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────

class _BleReceiveWorksView extends StatelessWidget {
  const _BleReceiveWorksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _AppBar(),
          Expanded(
            child: BlocBuilder<BleReceiveWorksBloc, BleReceiveWorksState>(
              builder: (context, state) {
                return switch (state) {
                  BleReceiveIdle() => _IdleView(),
                  BleReceiveScanning() => _ScanningView(state: state),
                  BleReceiveConnecting() => _ConnectingView(state: state),
                  BleReceiveListening() => _ListeningView(state: state),
                  BleReceiveDataReady() => _DataReadyView(state: state),
                  BleReceiveError() => _ErrorView(state: state),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bluetooth_searching,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'BLE RECEIVE',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textDisabled,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          // Bouton recommencer depuis DataReady
          BlocBuilder<BleReceiveWorksBloc, BleReceiveWorksState>(
            builder: (context, state) {
              if (state is BleReceiveDataReady && !state.isSubmitting) {
                return _HeaderButton(
                  icon: Icons.refresh,
                  label: 'Recommencer',
                  onTap: () => context.read<BleReceiveWorksBloc>().add(
                    BleReceiveResetEvent(),
                  ),
                );
              }
              if (state is BleReceiveListening) {
                return _HeaderButton(
                  icon: Icons.bluetooth_disabled,
                  label: 'Déconnecter',
                  onTap: () => context.read<BleReceiveWorksBloc>().add(
                    BleReceiveDisconnectEvent(),
                  ),
                );
              }
              if (state is BleReceiveScanning) {
                return _HeaderButton(
                  icon: Icons.stop,
                  label: 'Annuler',
                  onTap: () => context.read<BleReceiveWorksBloc>().add(
                    BleReceiveResetEvent(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PHASE 1 : Idle ────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.bluetooth,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Réception via Bluetooth',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scannez pour trouver un appareil Android\nprêt à envoyer des travaux.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<BleReceiveWorksBloc>().add(
              BleReceiveStartScanEvent(),
            ),
            icon: const Icon(Icons.bluetooth_searching, size: 18),
            label: const Text('Scanner les appareils BLE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PHASE 1 : Scanning ────────────────────────────────────────────────────

class _ScanningView extends StatelessWidget {
  final BleReceiveScanning state;
  const _ScanningView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de statut scan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: AppColors.surfaceVariant,
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Scan en cours...',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${state.devices.length} appareil(s)',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
        if (state.devices.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar, size: 48, color: AppColors.textDisabled),
                  SizedBox(height: 12),
                  Text(
                    'Recherche d\'appareils BLE…',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.devices.length,
              itemBuilder: (context, i) =>
                  _DeviceTile(device: state.devices[i]),
            ),
          ),
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BleDeviceEntity device;
  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => context.read<BleReceiveWorksBloc>().add(
            BleReceiveConnectEvent(device),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_android,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.id,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textDisabled,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                _RssiChip(rssi: device.rssi),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RssiChip extends StatelessWidget {
  final int rssi;
  const _RssiChip({required this.rssi});

  Color get _color {
    if (rssi > -60) return AppColors.success;
    if (rssi > -80) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$rssi dBm',
        style: TextStyle(
          fontSize: 10,
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── PHASE 1 : Connecting ──────────────────────────────────────────────────

class _ConnectingView extends StatelessWidget {
  final BleReceiveConnecting state;
  const _ConnectingView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Connexion en cours…',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.device.name,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.accent,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ── PHASE 1 : Listening (ripple animation) ────────────────────────────────

class _ListeningView extends StatelessWidget {
  final BleReceiveListening state;
  const _ListeningView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ripple wave autour de l'icône Bluetooth
          SizedBox(
            width: 180,
            height: 180,
            child: RippleWave(
              color: AppColors.primary,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_connected,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'En attente de données…',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                'Connecté : ${state.device.name}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Lancez l\'envoi depuis l\'application Android.',
            style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}

// ── PHASE 2 : Data Ready ──────────────────────────────────────────────────

class _DataReadyView extends StatelessWidget {
  final BleReceiveDataReady state;
  const _DataReadyView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Barre d'actions ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: AppColors.surfaceVariant,
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                '${state.works.length} travaux reçus',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (state.isSubmitting) ...[
                const SizedBox(width: 12),
                Text(
                  '${state.sentCount} / ${state.works.length} envoyés',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              if (state.allSent)
                _StatusBadge(
                  label: 'TOUT ENVOYÉ',
                  color: AppColors.success,
                  icon: Icons.cloud_done,
                )
              else if (!state.isSubmitting)
                _SendAllButton(
                  onTap: () => context.read<BleReceiveWorksBloc>().add(
                    BleReceiveSubmitAllEvent(),
                  ),
                  hasErrors: state.hasErrors,
                ),
              if (state.isSubmitting) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Liste des travaux ────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.works.length,
            itemBuilder: (context, i) {
              final wo = state.works[i];
              final code = wo.woCode ?? '';
              final status = state.sendStatus[code] ?? WorkSendStatus.pending;
              return _WoSendTile(wo: wo, status: status);
            },
          ),
        ),

        // ── Bannière "Tout envoyé" ────────────────────────────────────────
        if (state.allSent)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.success.withValues(alpha: 0.12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_done, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Text(
                  'Tous les travaux ont été envoyés avec succès !',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SendAllButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasErrors;

  const _SendAllButton({required this.onTap, required this.hasErrors});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasErrors ? Icons.replay : Icons.cloud_upload_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                hasErrors ? 'Renvoyer les erreurs' : 'Envoyer tout',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WoSendTile extends StatelessWidget {
  final WoModel wo;
  final WorkSendStatus status;

  const _WoSendTile({required this.wo, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _tileColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            // Indicateur de statut
            _StatusIndicator(status: status),
            const SizedBox(width: 14),

            // Infos WO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        wo.woCode ?? '—',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (wo.woStatus != null)
                        _WoStatusChip(status: wo.woStatus!),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wo.woDesc ?? wo.rangeDesc ?? '—',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Méta
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${wo.checkListItems?.length ?? 0} tâche(s)',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 4),
                _SendStatusLabel(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _tileColor => switch (status) {
    WorkSendStatus.sent => AppColors.success.withValues(alpha: 0.06),
    WorkSendStatus.sending => AppColors.primary.withValues(alpha: 0.08),
    WorkSendStatus.error => AppColors.error.withValues(alpha: 0.06),
    WorkSendStatus.pending => AppColors.card,
  };

  Color get _borderColor => switch (status) {
    WorkSendStatus.sent => AppColors.success.withValues(alpha: 0.3),
    WorkSendStatus.sending => AppColors.primary.withValues(alpha: 0.3),
    WorkSendStatus.error => AppColors.error.withValues(alpha: 0.3),
    WorkSendStatus.pending => AppColors.border,
  };
}

class _StatusIndicator extends StatelessWidget {
  final WorkSendStatus status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == WorkSendStatus.sending) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: _color.withValues(alpha: 0.6)),
      ),
      child: Icon(_icon, size: 10, color: _color),
    );
  }

  Color get _color => switch (status) {
    WorkSendStatus.sent => AppColors.success,
    WorkSendStatus.sending => AppColors.primary,
    WorkSendStatus.error => AppColors.error,
    WorkSendStatus.pending => AppColors.textDisabled,
  };

  IconData get _icon => switch (status) {
    WorkSendStatus.sent => Icons.check,
    WorkSendStatus.sending => Icons.hourglass_empty,
    WorkSendStatus.error => Icons.close,
    WorkSendStatus.pending => Icons.radio_button_unchecked,
  };
}

class _SendStatusLabel extends StatelessWidget {
  final WorkSendStatus status;
  const _SendStatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WorkSendStatus.pending => ('EN ATTENTE', AppColors.textDisabled),
      WorkSendStatus.sending => ('ENVOI…', AppColors.primary),
      WorkSendStatus.sent => ('ENVOYÉ', AppColors.success),
      WorkSendStatus.error => ('ERREUR', AppColors.error),
    };

    return Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _WoStatusChip extends StatelessWidget {
  final String status;
  const _WoStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 9,
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── PHASE : Error ─────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final BleReceiveError state;
  const _ErrorView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: const Icon(
              Icons.bluetooth_disabled,
              size: 32,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Une erreur est survenue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<BleReceiveWorksBloc>().add(BleReceiveResetEvent()),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
