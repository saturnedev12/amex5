// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:amex5/core/database/isar_config.dart' as _i553;
import 'package:amex5/core/network/dio_config.dart' as _i604;
import 'package:amex5/core/network/interceptors/auth_interceptor.dart' as _i660;
import 'package:amex5/core/network/interceptors/error_interceptor.dart'
    as _i1073;
import 'package:amex5/core/network/interceptors/token_provider.dart' as _i929;
import 'package:amex5/features/authentification/data/auth_repository.dart'
    as _i521;
import 'package:amex5/features/authentification/presentation/login_cubit.dart'
    as _i468;
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
    gh.lazySingleton<_i1073.ErrorInterceptor>(() => _i1073.ErrorInterceptor());
    gh.lazySingleton<_i660.AuthInterceptor>(
      () => _i660.AuthInterceptor(gh<_i929.TokenProvider>()),
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
    gh.lazySingleton<_i521.AuthRepository>(
      () => _i521.AuthRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i838.DischargeWorksRepository>(
      () => _i551.DischargeWorksRepositoryImpl(
        gh<_i345.DischargeWorksRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i494.UploadDischargeWorksUseCase>(
      () => _i494.UploadDischargeWorksUseCase(
        gh<_i838.DischargeWorksRepository>(),
      ),
    );
    gh.factory<_i468.LoginCubit>(
      () => _i468.LoginCubit(gh<_i521.AuthRepository>()),
    );
    gh.factory<_i881.DischargeWorksBloc>(
      () => _i881.DischargeWorksBloc(gh<_i494.UploadDischargeWorksUseCase>()),
    );
    return this;
  }
}

class _$DioConfig extends _i604.DioConfig {}
