import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ble_device_entity.dart';
import '../bloc/ble_bloc.dart';
import '../widgets/ble_widgets.dart';

// ── Page Entry Point ──────────────────────────────────────────────────────

class BleReceiverPage extends StatelessWidget {
  const BleReceiverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BleBloc(),
      child: const _BleReceiverView(),
    );
  }
}

// ── Main View ─────────────────────────────────────────────────────────────

class _BleReceiverView extends StatelessWidget {
  const _BleReceiverView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BleBloc, BleState>(
      listener: _handleListener,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: BlocBuilder<BleBloc, BleState>(
          builder: (ctx, state) => _buildBody(ctx, state),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(width: 4, height: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text('BLE RECEIVER'),
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
          const SizedBox(width: 12),
          BlocBuilder<BleBloc, BleState>(
            builder: (ctx, state) => BleStatusBadge(state: state),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BleState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Panneau gauche : contrôles ──────────────────────────────────
        SizedBox(
          width: 340,
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ScanPanel(state: state),
                  if (state is BleConnected || state is BleSending) ...[
                    const BleSectionDivider(label: 'CONNEXION ACTIVE'),
                    _ConnectedInfoPanel(state: state),
                    const BleSectionDivider(label: 'ENVOYER JSON'),
                    _SendJsonPanel(state: state),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── Panneau droit : journal BLE ─────────────────────────────────
        Expanded(
          child: _JsonLogPanel(state: state),
        ),
      ],
    );
  }

  void _handleListener(BuildContext context, BleState state) {
    if (state is BleError) {
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
          action: SnackBarAction(
            label: 'RÉESSAYER',
            textColor: AppColors.primary,
            onPressed: () =>
                context.read<BleBloc>().add(BleResetEvent()),
          ),
        ),
      );
    } else if (state is BleDisconnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.bluetooth_disabled,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(state.reason ?? 'Déconnecté'),
            ],
          ),
          backgroundColor: AppColors.surfaceVariant,
        ),
      );
    }
  }
}

// ── Scan Panel ────────────────────────────────────────────────────────────

class _ScanPanel extends StatelessWidget {
  final BleState state;
  const _ScanPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final isScanning = state is BleScanning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BleSectionDivider(label: 'RECHERCHE APPAREILS'),

        // ── Boutons Scan ──
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isScanning ? AppColors.primaryDark : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: isScanning
                    ? null
                    : () =>
                        context.read<BleBloc>().add(BleScanStartEvent()),
                icon: isScanning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bluetooth_searching, size: 16),
                label: Text(
                  isScanning ? 'SCAN EN COURS...' : 'LANCER LE SCAN',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            if (isScanning) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: () =>
                      context.read<BleBloc>().add(BleStopScanEvent()),
                  child: const Icon(
                    Icons.stop,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // ── Info scan ──
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 12,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Service UUID : 0000ffe0-...-00805f9b34fb\n'
                  'L\'application Android doit être active et en mode serveur.',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textDisabled,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Liste appareils ──
        if (isScanning && (state as BleScanning).devices.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 28,
                    color: AppColors.textDisabled,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Recherche en cours...',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (state is BleScanning &&
            (state as BleScanning).devices.isNotEmpty) ...[
          Text(
            '${(state as BleScanning).devices.length} appareil(s) trouvé(s)',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ...((state as BleScanning).devices.map(
                (device) => BleDeviceTile(
                  device: device,
                  onConnect: () =>
                      context.read<BleBloc>().add(BleConnectDeviceEvent(device)),
                ),
              )),
        ] else if (state is BleConnecting)
          _buildConnectingIndicator(state as BleConnecting)
        else if (state is BleInitial)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Lancez un scan pour\ndécouvrir les appareils Android.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                  height: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConnectingIndicator(BleConnecting state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONNEXION EN COURS...',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.device.name,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Connected Info Panel ──────────────────────────────────────────────────

class _ConnectedInfoPanel extends StatelessWidget {
  final BleState state;
  const _ConnectedInfoPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final device = switch (state) {
      BleConnected(device: final d) => d,
      BleSending(device: final d) => d,
      _ => null,
    };
    if (device == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.bluetooth_connected,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
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
                    ),
                    Text(
                      device.id,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textDisabled,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              RssiBar(rssi: device.rssi),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: EdgeInsets.zero,
              ),
              onPressed: () =>
                  context.read<BleBloc>().add(BleDisconnectEvent()),
              icon: const Icon(Icons.bluetooth_disabled, size: 14),
              label: const Text(
                'DÉCONNECTER',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Send JSON Panel ───────────────────────────────────────────────────────

class _SendJsonPanel extends StatefulWidget {
  final BleState state;
  const _SendJsonPanel({required this.state});

  @override
  State<_SendJsonPanel> createState() => _SendJsonPanelState();
}

class _SendJsonPanelState extends State<_SendJsonPanel> {
  final _controller = TextEditingController();
  String? _errorMsg;

  static const _sampleJson = '{\n'
      '  "tracking_id": "TRK-001",\n'
      '  "status": "en_route",\n'
      '  "courier": "John Doe",\n'
      '  "timestamp": "2025-01-01T10:00:00Z"\n'
      '}';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMsg = 'Veuillez saisir un JSON.');
      return;
    }
    try {
      final decoded = jsonDecode(text);
      final Map<String, dynamic> data;
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else if (decoded is List) {
        data = {'data': decoded};
      } else {
        throw const FormatException('Objet ou tableau requis.');
      }
      setState(() => _errorMsg = null);
      context.read<BleBloc>().add(BleSendJsonEvent(data));
    } on FormatException catch (e) {
      setState(() => _errorMsg = 'JSON invalide : ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSending = widget.state is BleSending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Editeur JSON ──
        TextField(
          controller: _controller,
          maxLines: 8,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: AppColors.accent,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: _sampleJson,
            hintStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: AppColors.textDisabled,
              height: 1.5,
            ),
            errorText: _errorMsg,
            errorStyle: const TextStyle(fontSize: 10, color: AppColors.error),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            // Charger l'exemple
            SizedBox(
              height: 32,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textSecondary,
                ),
                onPressed: () {
                  _controller.text = _sampleJson;
                  setState(() => _errorMsg = null);
                },
                child: const Text(
                  'EXEMPLE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Copier
            SizedBox(
              height: 32,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textSecondary,
                ),
                onPressed: _controller.text.isNotEmpty
                    ? () => Clipboard.setData(
                          ClipboardData(text: _controller.text),
                        )
                    : null,
                child: const Icon(Icons.copy, size: 13),
              ),
            ),
            const Spacer(),
            // Envoyer
            SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: isSending ? null : _send,
                icon: isSending
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 13),
                label: Text(
                  isSending ? 'ENVOI...' : 'ENVOYER',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── JSON Log Panel ────────────────────────────────────────────────────────

class _JsonLogPanel extends StatelessWidget {
  final BleState state;
  const _JsonLogPanel({required this.state});

  List<BleJsonRecord> get _history => switch (state) {
        BleConnected(history: final h) => h,
        BleSending(history: final h) => h,
        _ => [],
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête du log ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 14,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(width: 8),
                const Text(
                  'JOURNAL DES ÉCHANGES JSON',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                    letterSpacing: 1.3,
                  ),
                ),
                const Spacer(),
                if (_history.isNotEmpty)
                  Text(
                    '${_history.length} entrée(s)',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textDisabled,
                    ),
                  ),
              ],
            ),
          ),

          // ── Légende ──
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  _LegendDot(color: AppColors.success, label: 'Reçu de Android'),
                  const SizedBox(width: 16),
                  _LegendDot(color: AppColors.info, label: 'Envoyé à Android'),
                  const SizedBox(width: 8),
                  const Text(
                    '· Cliquer pour afficher le JSON complet',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),

          // ── Corps du log ──
          Expanded(
            child: _buildLogBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogBody() {
    if (state is BleError) {
      return _buildErrorState((state as BleError).message);
    }

    if (state is BleInitial || state is BleDisconnected) {
      return _buildEmptyState(
        icon: Icons.bluetooth_outlined,
        message: state is BleDisconnected
            ? 'Déconnecté — les données précédentes\nne sont plus disponibles.'
            : 'En attente de connexion BLE.\nLancez un scan pour découvrir les appareils.',
      );
    }

    if (state is BleScanning || state is BleConnecting) {
      return _buildEmptyState(
        icon: Icons.bluetooth_searching,
        message: state is BleConnecting
            ? 'Connexion en cours...\nDécouverte des services BLE.'
            : 'Scan en cours...\nSélectionnez un appareil pour vous connecter.',
        loading: true,
      );
    }

    if (_history.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        message: 'Connecté — en attente de données JSON\nprovenant de l\'application Android.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: _history.length,
      itemBuilder: (_, i) => BleJsonEntry(record: _history[i]),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    bool loading = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.primary,
              ),
            )
          else
            Icon(icon, size: 40, color: AppColors.textDisabled),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDisabled,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête erreur ──
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ERREUR BLE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Message d'erreur sélectionnable ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.25),
                  ),
                ),
                child: SelectableText(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppColors.error,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Hint copier ──
              const Row(
                children: [
                  Icon(
                    Icons.content_copy,
                    size: 11,
                    color: AppColors.textDisabled,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Sélectionnez le texte ci-dessus pour le copier',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textDisabled),
        ),
      ],
    );
  }
}
