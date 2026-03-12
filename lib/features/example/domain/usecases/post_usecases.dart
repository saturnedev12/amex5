import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase extends UseCase<List<Post>, NoParams> {
  final PostRepository _repository;

  GetPostsUseCase(this._repository);

  @override
  Future<Result<List<Post>>> call(NoParams params) => _repository.getPosts();
}

class GetPostByIdUseCase extends UseCase<Post, int> {
  final PostRepository _repository;

  GetPostByIdUseCase(this._repository);

  @override
  Future<Result<Post>> call(int id) => _repository.getPostById(id);
}
