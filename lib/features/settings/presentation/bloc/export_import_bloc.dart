import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/settings/domain/usecase/export_data_usecase.dart';
import 'package:opennutritracker/features/settings/domain/usecase/import_data_usecase.dart';
import 'package:opennutritracker/features/settings/domain/usecase/export_data_supabase_usecase.dart';
import 'package:opennutritracker/features/settings/domain/usecase/import_data_supabase_usecase.dart';

part 'export_import_event.dart';

part 'export_import_state.dart';

class ExportImportBloc extends Bloc<ExportImportEvent, ExportImportState> {
  static const exportZipFileName = 'opennutritracker-export.zip';
  static const userActivityJsonFileName = 'user_activity.json';
  static const userIntakeJsonFileName = 'user_intake.json';
  static const trackedDayJsonFileName = 'user_tracked_day.json';
  static const userWeightJsonFileName = 'user_weight.json';
  static const recipesJsonFileName = 'recipes.json';
  static const userJsonFileName = 'user.json';

  final ExportDataUsecase _exportDataUsecase;
  final ImportDataUsecase _importDataUsecase;
  final ExportDataSupabaseUsecase _exportDataSupabaseUsecase;
  final ImportDataSupabaseUsecase _importDataSupabaseUsecase;

  ExportImportBloc(this._exportDataUsecase, this._importDataUsecase,
      this._exportDataSupabaseUsecase, this._importDataSupabaseUsecase)
      : super(ExportImportInitial()) {
    on<ExportDataEvent>((event, emit) async {
      try {
        emit(ExportImportLoadingState());

        final result = await _exportDataUsecase.exportData(
          exportZipFileName,
          userActivityJsonFileName,
          userIntakeJsonFileName,
          trackedDayJsonFileName,
          userWeightJsonFileName,
          recipesJsonFileName,
          userJsonFileName,
        );

        if (result) {
          emit(ExportImportSuccess());
        } else {
          emit(ExportImportInitial());
        }
      } catch (e) {
        emit(ExportImportError());
      }
    });

    on<ExportDataSupabaseEvent>((event, emit) async {
      try {
        emit(ExportImportLoadingState());

        final result = await _exportDataSupabaseUsecase.exportData(
          exportZipFileName,
          userActivityJsonFileName,
          userIntakeJsonFileName,
          trackedDayJsonFileName,
          userWeightJsonFileName,
          recipesJsonFileName,
          userJsonFileName,
        );

        if (result) {
          emit(ExportImportSuccess());
        } else {
          emit(ExportImportError());
        }
      } catch (e) {
        emit(ExportImportError());
      }
    });

    on<ImportDataEvent>((event, emit) async {
      try {
        emit(ExportImportLoadingState());

        final result = await _importDataUsecase.importData(
            userActivityJsonFileName,
            userIntakeJsonFileName,
            trackedDayJsonFileName,
            userWeightJsonFileName,
            recipesJsonFileName,
            userJsonFileName);
        if (result) {
          emit(ExportImportSuccess());
        } else {
          emit(ExportImportInitial());
        }
      } catch (e) {
        emit(ExportImportError());
      }
    });

    on<ImportDataSupabaseEvent>((event, emit) async {
      try {
        emit(ExportImportLoadingState());

        final result = await _importDataSupabaseUsecase.importData(
          exportZipFileName,
          userActivityJsonFileName,
          userIntakeJsonFileName,
          trackedDayJsonFileName,
          userWeightJsonFileName,
          recipesJsonFileName,
          userJsonFileName,
        );

        if (result) {
          emit(ExportImportSuccess());
        } else {
          emit(ExportImportError());
        }
      } catch (e) {
        emit(ExportImportError());
      }
    });
  }
}
