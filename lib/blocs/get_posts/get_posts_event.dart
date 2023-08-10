abstract class GetPostsEvent {}

class GetPosts extends GetPostsEvent {
  final bool? isRefresh;
  final String? userId;
  final String? city;
  final String? category;
  final String? searchKeyword;
  final int? offset;
  final bool? isPagination;

  GetPosts(this.isRefresh, this.userId, this.city, this.category,
      this.searchKeyword, this.offset, this.isPagination);
}
