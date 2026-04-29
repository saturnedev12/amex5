import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../di/injection.dart';
import '../theme/app_theme.dart';
import 'ble_service.dart';
import 'widgets/ble_widgets.dart';

Future<bool> showBleConnectDialog(BuildContext context) async {
  final service = getIt<BleService>();

  // Démarrer le scan automatiquement à l'ouverture
  if (!service.isConnected) {
    service.startScan();
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

                IconButton(onPressed: (){
                   Navigator.of(context).pop(false);
                }, icon:Icon(CupertinoIcons.xmark_circle_fill))
              ],
            ),
            content: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (service.connectionState == BleConnectionState.error) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        service.errorMessage ?? 'Erreur inconnue',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
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
                          ? const Center(
                              child: Text(
                                'Recherche en cours...',
                                style: TextStyle(
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
     
          );
        },
      );
    },
  );

  return result ?? false;
}
