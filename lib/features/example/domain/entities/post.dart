/// Entité domain — pure Dart, aucune dépendance externe.
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  @override
  String toString() => 'Post(id: $id, title: $title)';
}
