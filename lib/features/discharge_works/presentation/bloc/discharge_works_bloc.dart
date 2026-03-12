import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/discharge_works_remote_datasource.dart';
import '../../data/repositories/discharge_works_repository_impl.dart';
import '../../domain/entities/discharge_entities.dart';
import '../../domain/usecases/upload_discharge_works_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────

sealed class DischargeWorksEvent {}

/// Ouvre le file picker et charge le fichier JSON.
class PickFileEvent extends DischargeWorksEvent {}

/// Lance l'upload vers l'API.
class UploadFileEvent extends DischargeWorksEvent {}

/// Réinitialise la sélection.
class ResetEvent extends DischargeWorksEvent {}

// ── States ────────────────────────────────────────────────────────────────

sealed class DischargeWorksState {}

class DischargeWorksInitial extends DischargeWorksState {}

class DischargeWorksPickingFile extends DischargeWorksState {}

class DischargeWorksFileSelected extends DischargeWorksState {
  final DischargeFile file;
  DischargeWorksFileSelected(this.file);
}

class DischargeWorksUploading extends DischargeWorksState {
  final DischargeFile file;
  DischargeWorksUploading(this.file);
}

class DischargeWorksSuccess extends DischargeWorksState {
  final DischargeFile file;
  final DischargeUploadResult result;
  DischargeWorksSuccess({required this.file, required this.result});
}

class DischargeWorksError extends DischargeWorksState {
  final Failure failure;

  /// Fichier qui était sélectionné avant l'erreur (peut être null si erreur au pick).
  final DischargeFile? file;
  DischargeWorksError({required this.failure, this.file});
  String get message => failure.message;
}

// ── BLoC ──────────────────────────────────────────────────────────────────

class DischargeWorksBloc
    extends Bloc<DischargeWorksEvent, DischargeWorksState> {
  DischargeWorksBloc() : super(DischargeWorksInitial()) {
    on<PickFileEvent>(_onPickFile);
    on<UploadFileEvent>(_onUploadFile);
    on<ResetEvent>(_onReset);
  }

  // ── Helpers ──

  UploadDischargeWorksUseCase _buildUseCase() {
    final client = AppConfig.instance.dioClient;
    final dataSource = DischargeWorksRemoteDataSource(client);
    final repository = DischargeWorksRepositoryImpl(dataSource);
    return UploadDischargeWorksUseCase(repository);
  }

  // ── Handlers ──

  Future<void> _onPickFile(
    PickFileEvent event,
    Emitter<DischargeWorksState> emit,
  ) async {
    emit(DischargeWorksPickingFile());

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      // Annulé — retour à l'état initial
      emit(DischargeWorksInitial());
      return;
    }

    final picked = result.files.single;
    final filePath = picked.path;

    if (filePath == null) {
      emit(
        DischargeWorksError(
          failure: const UnknownFailure(
            'Impossible de lire le chemin du fichier.',
          ),
        ),
      );
      return;
    }

    try {
      final file = File(filePath);
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);

      // On accepte un objet JSON ou un tableau JSON
      final Map<String, dynamic> content;
      if (decoded is Map<String, dynamic>) {
        content = decoded;
      } else if (decoded is List) {
        content = {'data': decoded};
      } else {
        throw const FormatException(
          'Le fichier JSON doit être un objet ou un tableau.',
        );
      }

      emit(
        DischargeWorksFileSelected(
          DischargeFile(
            path: filePath,
            name: picked.name,
            content: content,
            sizeBytes: picked.size,
          ),
        ),
      );
    } on FormatException catch (e) {
      emit(
        DischargeWorksError(
          failure: ParseFailure('JSON invalide : ${e.message}'),
        ),
      );
    } catch (e) {
      emit(
        DischargeWorksError(failure: UnknownFailure('Erreur de lecture : $e')),
      );
    }
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<DischargeWorksState> emit,
  ) async {
    final current = state;
    if (current is! DischargeWorksFileSelected) return;

    final file = current.file;
    emit(DischargeWorksUploading(file));

    final useCase = _buildUseCase();
    final result = await useCase(file.content);

    result.fold(
      (failure) => emit(DischargeWorksError(failure: failure, file: file)),
      (uploadResult) =>
          emit(DischargeWorksSuccess(file: file, result: uploadResult)),
    );
  }

  void _onReset(ResetEvent event, Emitter<DischargeWorksState> emit) {
    emit(DischargeWorksInitial());
  }
}
