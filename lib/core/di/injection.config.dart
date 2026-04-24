// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:amex5/core/ble/ble_service.dart' as _i184;
import 'package:amex5/core/ble/datasources/ble_data_source.dart' as _i428;
import 'package:amex5/core/ble/repositories/ble_repository.dart' as _i927;
import 'package:amex5/core/ble/repositories/ble_repository_impl.dart' as _i928;
import 'package:amex5/core/database/isar_config.dart' as _i553;
import 'package:amex5/core/network/dio_config.dart' as _i604;
import 'package:amex5/core/network/interceptors/auth_interceptor.dart' as _i660;
import 'package:amex5/core/network/interceptors/error_interceptor.dart'
    as _i1073;
import 'package:amex5/core/network/interceptors/logging_interceptor.dart'
    as _i715;
import 'package:amex5/core/network/interceptors/token_provider.dart' as _i929;
import 'package:amex5/core/session/session_manager.dart' as _i714;
import 'package:amex5/features/agent_works/data/datasources/agent_works_remote_datasource.dart'
    as _i285;
import 'package:amex5/features/agent_works/data/repositories/agent_works_repository_impl.dart'
    as _i861;
import 'package:amex5/features/agent_works/domain/repositories/agent_works_repository.dart'
    as _i806;
import 'package:amex5/features/agent_works/presentation/bloc/agent_works_bloc.dart'
    as _i184;
import 'package:amex5/features/authentification/data/auth_repository.dart'
    as _i521;
import 'package:amex5/features/authentification/presentation/login_cubit.dart'
    as _i468;
import 'package:amex5/features/ble_receive_works/data/datasources/ble_receive_remote_datasource.dart'
    as _i998;
import 'package:amex5/features/ble_receive_works/data/repositories/ble_receive_works_repository_impl.dart'
    as _i252;
import 'package:amex5/features/ble_receive_works/domain/repositories/ble_receive_works_repository.dart'
    as _i74;
import 'package:amex5/features/ble_receive_works/presentation/bloc/ble_receive_works_bloc.dart'
    as _i409;
import 'package:amex5/features/discharge_works/data/datasources/discharge_works_remote_datasource.dart'
    as _i345;
import 'package:amex5/features/discharge_works/data/repositories/discharge_works_repository_impl.dart'
    as _i551;
import 'package:amex5/features/discharge_works/domain/repositories/discharge_works_repository.dart'
    as _i838;
import 'package:amex5/features/discharge_works/domain/usecases/upload_discharge_works_usecase.dart'
    as _i494;
import 'package:amex5/features/discharge_works/presentation/bloc/discharge_works_bloc.dart'
    as _i881;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioConfig = _$DioConfig();
    gh.singleton<_i553.IsarConfig>(() => _i553.IsarConfig());
    gh.singleton<_i929.TokenProvider>(() => _i929.TokenProvider());
    gh.singleton<_i714.SessionManager>(() => _i714.SessionManager());
    gh.lazySingleton<_i1073.ErrorInterceptor>(() => _i1073.ErrorInterceptor());
    gh.factory<_i428.BleDataSource>(() => _i428.WindowsBleClientDataSource());
    gh.lazySingleton<_i715.LoggingInterceptor>(
      () => _i715.LoggingInterceptor(enabled: gh<bool>()),
    );
    gh.factory<_i927.BleRepository>(
      () => _i928.BleRepositoryImpl(gh<_i428.BleDataSource>()),
    );
    gh.lazySingleton<_i660.AuthInterceptor>(
      () => _i660.AuthInterceptor(
        gh<_i929.TokenProvider>(),
        gh<_i714.SessionManager>(),
      ),
    );
    gh.singleton<_i184.BleService>(
      () => _i184.BleService(gh<_i927.BleRepository>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioConfig.dio(
        gh<_i660.AuthInterceptor>(),
        gh<_i1073.ErrorInterceptor>(),
      ),
    );
    gh.lazySingleton<_i345.DischargeWorksRemoteDataSource>(
      () => _i345.DischargeWorksRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i285.AgentWorksRemoteDataSource>(
      () => _i285.AgentWorksRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i521.AuthRepository>(
      () => _i521.AuthRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i998.BleReceiveRemoteDataSource>(
      () => _i998.BleReceiveRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i838.DischargeWorksRepository>(
      () => _i551.DischargeWorksRepositoryImpl(
        gh<_i345.DischargeWorksRemoteDataSource>(),
      ),
    );
    gh.factory<_i468.LoginCubit>(
      () => _i468.LoginCubit(
        gh<_i521.AuthRepository>(),
        gh<_i714.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i806.AgentWorksRepository>(
      () => _i861.AgentWorksRepositoryImpl(
        gh<_i285.AgentWorksRemoteDataSource>(),
      ),
    );
    gh.factory<_i184.AgentWorksBloc>(
      () => _i184.AgentWorksBloc(
        gh<_i806.AgentWorksRepository>(),
        gh<_i714.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i494.UploadDischargeWorksUseCase>(
      () => _i494.UploadDischargeWorksUseCase(
        gh<_i838.DischargeWorksRepository>(),
      ),
    );
    gh.lazySingleton<_i74.BleReceiveWorksRepository>(
      () => _i252.BleReceiveWorksRepositoryImpl(
        gh<_i998.BleReceiveRemoteDataSource>(),
      ),
    );
    gh.factory<_i881.DischargeWorksBloc>(
      () => _i881.DischargeWorksBloc(gh<_i494.UploadDischargeWorksUseCase>()),
    );
    gh.factory<_i409.BleReceiveWorksBloc>(
      () => _i409.BleReceiveWorksBloc(
        gh<_i74.BleReceiveWorksRepository>(),
        gh<_i184.BleService>(),
      ),
    );
    return this;
  }
}

class _$DioConfig extends _i604.DioConfig {}
