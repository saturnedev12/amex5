import '../../../../core/base/base_repository.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl with SafeCallMixin implements PostRepository {
  final PostRemoteDataSource _remote;

  PostRepositoryImpl(this._remote);

  @override
  Future<Result<List<Post>>> getPosts() => safeCall(() => _remote.getPosts());

  @override
  Future<Result<Post>> getPostById(int id) =>
      safeCall(() => _remote.getPostById(id));
}
