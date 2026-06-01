import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../theme/app_theme.dart';
import 'ble_service.dart';
import 'widgets/ble_widgets.dart';

Future<bool> showBleConnectDialog(BuildContext context) async {
  final service = getIt<BleService>();

  // Démarrer le scan automatiquement à l'ouverture
  if (!service.isConnected) {
    unawaited(service.startScan());
  }

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AnimatedBuilder(
        animation: service,
        builder: (context, _) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                const Text(
                  'Connexion Bluetooth',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: () async {
                    await service.stopScan();
                    if (context.mounted) Navigator.of(context).pop(false);
                  },
                  icon: const Icon(CupertinoIcons.xmark_circle_fill),
                ),
              ],
            ),
            content: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (service.connectionState == BleConnectionState.error) ...[
                    _BleDialogMessage(
                      message: service.errorMessage ?? 'Erreur inconnue',
                      isError: true,
                    ),
                  ] else if (service.errorMessage != null &&
                      service.connectionState !=
                          BleConnectionState.connected) ...[
                    _BleDialogMessage(message: service.errorMessage!),
                  ],
                  if (service.connectionState ==
                      BleConnectionState.connecting) ...[
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ] else if (service.connectionState ==
                      BleConnectionState.connected) ...[
                    const Expanded(
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 64,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: service.scanResults.isEmpty
                          ? Center(
                              child: Text(
                                service.connectionState ==
                                        BleConnectionState.scanning
                                    ? 'Recherche en cours...'
                                    : 'Aucun appareil RONDEX détecté.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textDisabled,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: service.scanResults.length,
                              itemBuilder: (context, index) {
                                final device = service.scanResults[index];
                                return BleDeviceTile(
                                  device: device,
                                  onConnect: () async {
                                    await service.connectToDevice(device);
                                    if (service.isConnected &&
                                        context.mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed:
                    service.connectionState == BleConnectionState.scanning ||
                        service.connectionState == BleConnectionState.connecting
                    ? null
                    : () => unawaited(service.startScan()),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Relancer'),
              ),
              TextButton.icon(
                onPressed:
                    service.connectionState == BleConnectionState.scanning
                    ? () => unawaited(service.stopScan())
                    : null,
                icon: const Icon(Icons.stop_rounded, size: 16),
                label: const Text('Stop'),
              ),
            ],
          );
        },
      );
    },
  );

  return result ?? false;
}

class _BleDialogMessage extends StatelessWidget {
  const _BleDialogMessage({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(message, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
