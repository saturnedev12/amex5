import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/theme/app_theme.dart';
import 'package:amex5/core/ble/ble_service.dart';
import 'package:amex5/core/ble/widgets/ble_widgets.dart';

import '../bloc/ble_receive_works_bloc.dart';

class BleReceiveWorksPage extends StatelessWidget {
  const BleReceiveWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: getIt<BleService>()),
        BlocProvider(create: (_) => getIt<BleReceiveWorksBloc>()),
      ],
      child: const _BleManagerView(),
    );
  }
}

class _BleManagerView extends StatelessWidget {
  const _BleManagerView();

  @override
  Widget build(BuildContext context) {
    final bleService = context.watch<BleService>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context, bleService),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panneau gauche: scan et historique JSON
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildConnectionPanel(context, bleService),
                      const Divider(height: 1),
                      Expanded(child: _buildLogPanel(bleService)),
                    ],
                  ),
                ),
                Container(width: 1, color: AppColors.border),
                // Panneau droit: réception travaux
                Expanded(
                  flex: 2,
                  child: const _WorksPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, BleService bleService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bluetooth, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            'GESTION BLE',
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          BleStatusBadge(state: bleService.connectionState),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel(BuildContext context, BleService bleService) {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Connexion Appareil',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (bleService.isConnected)
                ElevatedButton.icon(
                  onPressed: bleService.disconnect,
                  icon: const Icon(Icons.bluetooth_disabled, size: 16),
                  label: const Text('DÉCONNECTER'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => bleService.ensureConnected(context),
                  icon: const Icon(Icons.bluetooth_searching, size: 16),
                  label: const Text('CONNECTER'),
                ),
            ],
          ),
          if (bleService.connectedDevice != null) ...[
            const SizedBox(height: 8),
            Text(
              'Appareil: ${bleService.connectedDevice!.name} (${bleService.connectedDevice!.id})',
              style: const TextStyle(color: AppColors.success, fontSize: 13),
            ),
          ],
          if (bleService.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              bleService.errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildLogPanel(BleService bleService) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.surface,
          child: const Row(
            children: [
              Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'JOURNAL BLE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bleService.history.length,
            itemBuilder: (context, index) {
              final log = bleService.history[index];
              final isReceived = log.startsWith('Received: ');
              final jsonStr = isReceived ? log.substring(10) : log.substring(6);
              return BleJsonEntry(jsonRecord: jsonStr, isReceived: isReceived);
            },
          ),
        ),
        _TestJsonInput(bleService: bleService),
      ],
    );
  }
}

class _TestJsonInput extends StatefulWidget {
  final BleService bleService;
  const _TestJsonInput({required this.bleService});

  @override
  State<_TestJsonInput> createState() => _TestJsonInputState();
}

class _TestJsonInputState extends State<_TestJsonInput> {
  final _controller = TextEditingController(text: '{"test": true}');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Saisir du JSON à envoyer...',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.bleService.isConnected
                ? () {
                    try {
                      final parsed = jsonDecode(_controller.text) as Map<String, dynamic>;
                      widget.bleService.sendJson(parsed);
                      _controller.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('JSON Invalide: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.send, color: AppColors.primary),
          )
        ],
      ),
    );
  }
}

// ── Panneau Droite: Traitement Travaux ────────────────────────────────────

class _WorksPanel extends StatelessWidget {
  const _WorksPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleReceiveWorksBloc, BleReceiveWorksState>(
      builder: (context, state) {
        if (state is BleReceiveIdle) {
          return const Center(
            child: Text(
              'En attente de réception de travaux...',
              style: TextStyle(color: AppColors.textDisabled),
            ),
          );
        }
        
        if (state is BleReceiveError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is BleReceiveDataReady) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Text(
                      '${state.works.length} travaux reçus',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    if (!state.isSubmitting && !state.allSent)
                      ElevatedButton.icon(
                        onPressed: () => context.read<BleReceiveWorksBloc>().add(BleReceiveSubmitAllEvent()),
                        icon: const Icon(Icons.cloud_upload, size: 16),
                        label: const Text('TOUT ENVOYER'),
                      )
                    else if (state.allSent)
                      const Text(
                        'TOUT ENVOYÉ',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.works.length,
                  itemBuilder: (context, i) {
                    final wo = state.works[i];
                    final code = wo.woCode ?? '';
                    final status = state.sendStatus[code] ?? WorkSendStatus.pending;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status == WorkSendStatus.sent ? Icons.check_circle :
                            status == WorkSendStatus.error ? Icons.error :
                            status == WorkSendStatus.sending ? Icons.sync : Icons.schedule,
                            color: status == WorkSendStatus.sent ? AppColors.success :
                                   status == WorkSendStatus.error ? AppColors.error : AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'WO ${wo.woCode ?? '—'}: ${wo.woDesc ?? '—'}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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

        return const SizedBox.shrink();
      },
    );
  }
}
