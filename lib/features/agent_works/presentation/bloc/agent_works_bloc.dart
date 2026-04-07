import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:amex5/core/session/session_manager.dart';
import 'package:amex5/features/agent_works/data/models/task_model.dart';
import 'package:amex5/features/agent_works/data/models/wo_model.dart';
import 'package:amex5/features/agent_works/domain/repositories/agent_works_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────

sealed class AgentWorksEvent {}

class LoadWorksEvent extends AgentWorksEvent {}

class LoadChecklistEvent extends AgentWorksEvent {
  final String woCode;
  final int act;
  LoadChecklistEvent({required this.woCode, required this.act});
}

class LoadAllChecklistsEvent extends AgentWorksEvent {}

class LoadSelectedChecklistsEvent extends AgentWorksEvent {
  final List<WoModel> selectedWorks;
  LoadSelectedChecklistsEvent(this.selectedWorks);
}

class ToggleWorkSelectionEvent extends AgentWorksEvent {
  final String woCode;
  ToggleWorkSelectionEvent(this.woCode);
}

class SelectAllWorksEvent extends AgentWorksEvent {}

class DeselectAllWorksEvent extends AgentWorksEvent {}

class SendViaBleEvent extends AgentWorksEvent {}

class DownloadJsonEvent extends AgentWorksEvent {}

class ResetEvent extends AgentWorksEvent {}

// ── State ───────────────────────────────────────────────────────────────

class AgentWorksState {
  final List<WoModel> works;
  final Map<String, List<TaskModel>> checklistsByWoCode;
  final Set<String> loadingChecklists;
  final Set<String> selectedWoCodes;
  final bool isLoadingWorks;
  final bool isSendingBle;
  final String? error;
  final String? successMessage;

  const AgentWorksState({
    this.works = const [],
    this.checklistsByWoCode = const {},
    this.loadingChecklists = const {},
    this.selectedWoCodes = const {},
    this.isLoadingWorks = false,
    this.isSendingBle = false,
    this.error,
    this.successMessage,
  });

  bool get hasAnyChecklist => checklistsByWoCode.isNotEmpty;

  bool hasChecklist(String woCode) => checklistsByWoCode.containsKey(woCode);

  /// Aggregate all check items, deduplicated by code.
  List<TaskModel> get allCheckItems {
    final seen = <String>{};
    final items = <TaskModel>[];
    for (final entry in checklistsByWoCode.values) {
      for (final task in entry) {
        if (task.code != null && seen.add(task.code!)) {
          items.add(task);
        }
      }
    }
    return items;
  }

  AgentWorksState copyWith({
    List<WoModel>? works,
    Map<String, List<TaskModel>>? checklistsByWoCode,
    Set<String>? loadingChecklists,
    Set<String>? selectedWoCodes,
    bool? isLoadingWorks,
    bool? isSendingBle,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AgentWorksState(
      works: works ?? this.works,
      checklistsByWoCode: checklistsByWoCode ?? this.checklistsByWoCode,
      loadingChecklists: loadingChecklists ?? this.loadingChecklists,
      selectedWoCodes: selectedWoCodes ?? this.selectedWoCodes,
      isLoadingWorks: isLoadingWorks ?? this.isLoadingWorks,
      isSendingBle: isSendingBle ?? this.isSendingBle,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

// ── BLoC ────────────────────────────────────────────────────────────────

@injectable
class AgentWorksBloc extends Bloc<AgentWorksEvent, AgentWorksState> {
  final AgentWorksRepository _repository;
  final SessionManager _sessionManager;

  AgentWorksBloc(this._repository, this._sessionManager)
    : super(const AgentWorksState()) {
    on<LoadWorksEvent>(_onLoadWorks);
    on<LoadChecklistEvent>(_onLoadChecklist);
    on<LoadAllChecklistsEvent>(_onLoadAllChecklists);
    on<LoadSelectedChecklistsEvent>(_onLoadSelectedChecklists);
    on<ToggleWorkSelectionEvent>(_onToggleSelection);
    on<SelectAllWorksEvent>(_onSelectAll);
    on<DeselectAllWorksEvent>(_onDeselectAll);
    on<SendViaBleEvent>(_onSendViaBle);
    on<DownloadJsonEvent>(_onDownloadJson);
    on<ResetEvent>(_onReset);
  }

  Future<void> _onLoadWorks(
    LoadWorksEvent event,
    Emitter<AgentWorksState> emit,
  ) async {
    emit(state.copyWith(isLoadingWorks: true, clearError: true));
    final result = await _repository.fetchAllWorks();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoadingWorks: false, error: failure.message)),
      (response) => emit(
        state.copyWith(
          isLoadingWorks: false,
          works: response.dataUnitMap?.wo ?? [],
        ),
      ),
    );
  }

  Future<void> _onLoadChecklist(
    LoadChecklistEvent event,
    Emitter<AgentWorksState> emit,
  ) async {
    final loading = {...state.loadingChecklists, event.woCode};
    emit(state.copyWith(loadingChecklists: loading, clearError: true));

    final result = await _repository.fetchChecklist(
      woCode: event.woCode,
      act: event.act,
    );

    result.fold(
      (failure) {
        final done = {...state.loadingChecklists}..remove(event.woCode);
        emit(
          state.copyWith(
            loadingChecklists: done,
            error: 'Erreur checklist ${event.woCode}: ${failure.message}',
          ),
        );
      },
      (response) {
        final done = {...state.loadingChecklists}..remove(event.woCode);
        final updated = {...state.checklistsByWoCode};
        if (response.checkItems != null && response.checkItems!.isNotEmpty) {
          updated[event.woCode] = response.checkItems!;
        }
        emit(
          state.copyWith(loadingChecklists: done, checklistsByWoCode: updated),
        );
      },
    );
  }

  Future<void> _onLoadAllChecklists(
    LoadAllChecklistsEvent event,
    Emitter<AgentWorksState> emit,
  ) async {
    for (final wo in state.works) {
      if (wo.woCode != null && !state.hasChecklist(wo.woCode!)) {
        add(LoadChecklistEvent(woCode: wo.woCode!, act: wo.act ?? 10));
      }
    }
  }

  Future<void> _onLoadSelectedChecklists(
    LoadSelectedChecklistsEvent event,
    Emitter<AgentWorksState> emit,
  ) async {
    for (final wo in event.selectedWorks) {
      if (wo.woCode != null && !state.hasChecklist(wo.woCode!)) {
        add(LoadChecklistEvent(woCode: wo.woCode!, act: wo.act ?? 10));
      }
    }
  }

  void _onToggleSelection(
    ToggleWorkSelectionEvent event,
    Emitter<AgentWorksState> emit,
  ) {
    final selected = {...state.selectedWoCodes};
    if (selected.contains(event.woCode)) {
      selected.remove(event.woCode);
    } else {
      selected.add(event.woCode);
    }
    emit(state.copyWith(selectedWoCodes: selected));
  }

  void _onSelectAll(SelectAllWorksEvent event, Emitter<AgentWorksState> emit) {
    final all = state.works
        .where((w) => w.woCode != null)
        .map((w) => w.woCode!)
        .toSet();
    emit(state.copyWith(selectedWoCodes: all));
  }

  void _onDeselectAll(
    DeselectAllWorksEvent event,
    Emitter<AgentWorksState> emit,
  ) {
    emit(state.copyWith(selectedWoCodes: {}));
  }

  Future<void> _onSendViaBle(
    SendViaBleEvent event,
    Emitter<AgentWorksState> emit,
  ) async {
    // This event is handled in the UI which delegates to BleBloc
    // The BLE payload is built via buildBlePayload()
  }

  Future<void> _onDownloadJson(
    DownloadJsonEvent event,
    Emitter<AgentWorksState> emit,
  ) async {
    try {
      final payload = _buildFullPayload();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);
      debugPrint(jsonStr);
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Enregistrer les données',
        fileName: 'agent_works_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        await File(result).writeAsString(jsonStr);
        emit(state.copyWith(successMessage: 'Fichier enregistré: $result'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Erreur lors du téléchargement: $e'));
    }
  }

  void _onReset(ResetEvent event, Emitter<AgentWorksState> emit) {
    emit(const AgentWorksState());
  }

  /// Build the complete BLE payload with action wrappers.
  Map<String, dynamic> buildBlePayload() {
    return _buildFullPayload();
  }

  Map<String, dynamic> _buildFullPayload() {
    // Works with their loaded checklists
    final worksPayload = state.works.map((wo) {
      final woJson = wo.toJson();
      if (wo.woCode != null && state.hasChecklist(wo.woCode!)) {
        woJson['checkListItems'] = state.checklistsByWoCode[wo.woCode!]!
            .map((t) => t.toJson())
            .toList();
      }
      return woJson;
    }).toList();

    // Deduplicated checkItems
    final checkItems = state.allCheckItems.map((t) => t.toJson()).toList();

    return {
      'LOGGIN': _sessionManager.loginResponse ?? {},
      'UPPLOAD_WORK': {'wo': worksPayload, 'checkItems': checkItems},
    };
  }

  /// Build login-only BLE payload.
  Map<String, dynamic> buildLoginPayload() {
    return {'LOGGIN': _sessionManager.loginResponse ?? {}};
  }

  /// Build works-only BLE payload.
  Map<String, dynamic> buildWorksPayload() {
    final worksPayload = state.works.map((wo) {
      final woJson = wo.toJson();
      if (wo.woCode != null && state.hasChecklist(wo.woCode!)) {
        woJson['checkListItems'] = state.checklistsByWoCode[wo.woCode!]!
            .map((t) => t.toJson())
            .toList();
      }
      return woJson;
    }).toList();

    return {
      'UPPLOAD_WORK': {'wo': worksPayload},
    };
  }

  /// Build tasks-only BLE payload (deduplicated checkItems).
  Map<String, dynamic> buildTasksPayload() {
    return {
      'UPLOAD_TASK': {
        'checkItems': state.allCheckItems.map((t) => t.toJson()).toList(),
      },
    };
  }
}
