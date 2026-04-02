import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

/// Source de données distante — communique uniquement via [Dio].
class PostRemoteDataSource {
  final Dio _client;

  PostRemoteDataSource(this._client);

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _client.get<List<dynamic>>('/posts');
      final data = response.data;
      if (data == null) throw const ParseException('Réponse vide.');
      return data.cast<Map<String, dynamic>>().map(PostModel.fromJson).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException(e.toString());
    }
  }

  Future<PostModel> getPostById(int id) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/posts/$id');
      final data = response.data;
      if (data == null) throw const ParseException('Réponse vide.');
      return PostModel.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException(e.toString());
    }
  }
}
