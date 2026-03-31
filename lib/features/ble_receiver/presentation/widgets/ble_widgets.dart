import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ble_device_entity.dart';
import '../bloc/ble_bloc.dart';

// ── BleStatusBadge ────────────────────────────────────────────────────────

/// Badge d'état de connexion BLE (style identique au StatusBadge existant).
class BleStatusBadge extends StatelessWidget {
  final BleState state;

  const BleStatusBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      BleInitial() => ('INACTIF', AppColors.textDisabled),
      BleScanning() => ('SCAN...', AppColors.warning),
      BleConnecting() => ('CONNEXION', AppColors.warning),
      BleConnected() => ('CONNECTÉ', AppColors.success),
      BleSending() => ('ENVOI', AppColors.info),
      BleDisconnected() => ('DÉCONNECTÉ', AppColors.textSecondary),
      BleError() => ('ERREUR', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
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

// ── RssiBar ───────────────────────────────────────────────────────────────

/// Indicateur visuel de force du signal RSSI (barres de style radio).
class RssiBar extends StatelessWidget {
  final int rssi;

  const RssiBar({super.key, required this.rssi});

  int get _level {
    if (rssi >= -60) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    return 1;
  }

  Color get _color {
    if (rssi >= -60) return AppColors.success;
    if (rssi >= -70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final active = i < _level;
        return Container(
          width: 4,
          height: 4.0 + i * 3.0,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: active ? _color : AppColors.border,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

// ── BleDeviceTile ─────────────────────────────────────────────────────────

/// Tuile représentant un appareil BLE dans la liste de scan.
class BleDeviceTile extends StatelessWidget {
  final BleDeviceEntity device;
  final VoidCallback onConnect;

  const BleDeviceTile({
    super.key,
    required this.device,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icône Bluetooth
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.bluetooth,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),

          // Nom + ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  device.id,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textDisabled,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // RSSI
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RssiBar(rssi: device.rssi),
              const SizedBox(height: 3),
              Text(
                '${device.rssi} dBm',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Bouton Connecter
          SizedBox(
            height: 28,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: onConnect,
              child: const Text('CONN.'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── BleJsonEntry ──────────────────────────────────────────────────────────

/// Entrée du journal d'échange JSON (envoyé ou reçu), avec expansion.
class BleJsonEntry extends StatefulWidget {
  final BleJsonRecord record;

  const BleJsonEntry({super.key, required this.record});

  @override
  State<BleJsonEntry> createState() => _BleJsonEntryState();
}

class _BleJsonEntryState extends State<BleJsonEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isReceived = widget.record.direction == BleDirection.received;
    final dirColor = isReceived ? AppColors.success : AppColors.info;
    final dirLabel = isReceived ? '← REÇU' : '→ ENVOYÉ';
    final dirIcon = isReceived
        ? Icons.download_outlined
        : Icons.upload_outlined;

    final ts = widget.record.timestamp;
    final timeStr =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';

    // Aperçu d'une ligne
    final preview = widget.record.data.entries
        .take(3)
        .map((e) => '"${e.key}": ${e.value}')
        .join(', ');

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _expanded ? dirColor.withOpacity(0.4) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête ──
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: dirColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: dirColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(dirIcon, size: 10, color: dirColor),
                        const SizedBox(width: 4),
                        Text(
                          dirLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: dirColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textDisabled,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.record.data.length} clés',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 14,
                    color: AppColors.textDisabled,
                  ),
                ],
              ),
            ),

            // ── Aperçu compact (collapsed) ──
            if (!_expanded)
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
                child: Text(
                  '{ $preview${widget.record.data.length > 3 ? ', ...' : ''} }',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // ── JSON complet (expanded) ──
            if (_expanded)
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  widget.record.prettyJson,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── BleSectionDivider ─────────────────────────────────────────────────────

/// Diviseur de section (style identique à l'app existante).
class BleSectionDivider extends StatelessWidget {
  final String label;

  const BleSectionDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textDisabled,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
        ],
      ),
    );
  }
}
