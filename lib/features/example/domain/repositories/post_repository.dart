import '../../../../core/utils/result.dart';
import '../entities/post.dart';

/// Contrat du repository — défini dans domain, implémenté dans data.
abstract interface class PostRepository {
  Future<Result<List<Post>>> getPosts();
  Future<Result<Post>> getPostById(int id);
}
