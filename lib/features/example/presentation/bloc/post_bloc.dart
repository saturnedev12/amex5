import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/post_usecases.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/error/failures.dart';

// ── Events ────────────────────────────────────────────────────────────────

sealed class PostEvent {}

class LoadPostsEvent extends PostEvent {}

class LoadPostByIdEvent extends PostEvent {
  final int id;
  LoadPostByIdEvent(this.id);
}

// ── States ────────────────────────────────────────────────────────────────

sealed class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

class PostLoaded extends PostState {
  final Post post;
  PostLoaded(this.post);
}

class PostError extends PostState {
  final Failure failure;
  PostError(this.failure);

  String get message => failure.message;
}

// ── BLoC ──────────────────────────────────────────────────────────────────

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase _getPosts;
  final GetPostByIdUseCase _getPostById;

  PostBloc({
    required GetPostsUseCase getPosts,
    required GetPostByIdUseCase getPostById,
  }) : _getPosts = getPosts,
       _getPostById = getPostById,
       super(PostInitial()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<LoadPostByIdEvent>(_onLoadPostById);
  }

  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    final result = await _getPosts(const NoParams());
    result.fold((f) => emit(PostError(f)), (posts) => emit(PostsLoaded(posts)));
  }

  Future<void> _onLoadPostById(
    LoadPostByIdEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    final result = await _getPostById(event.id);
    result.fold((f) => emit(PostError(f)), (post) => emit(PostLoaded(post)));
  }
}
