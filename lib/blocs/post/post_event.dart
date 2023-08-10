

abstract class PostEvent {}

class InitialEvent extends PostEvent {}

class AddPost extends PostEvent {
  final String? requirementType;
  final String? userId;
  final String? city;
  final String? title;
  final String? description;
  final String? location;
  final List<String?>? pictures;
  final String? size;
  final String? sizeType;
  final String? prize;
  final String? prizeType;

  AddPost(
      this.requirementType,
      this.userId,
      this.city,
      this.title,
      this.description,
      this.location,
      this.pictures,
      this.size,
      this.sizeType,
      this.prize,
      this.prizeType);
}

class UpdatePost extends PostEvent {
  final String? postId;
  final String? requirementType;
  final String? userId;
  final String? city;
  final String? title;
  final String? description;
  final String? location;
  final List<String?>? pictures;
  final String? size;
  final String? sizeType;
  final String? prize;
  final String? prizeType;

  UpdatePost(
      this.postId,
      this.requirementType,
      this.userId,
      this.city,
      this.title,
      this.description,
      this.location,
      this.pictures,
      this.size,
      this.sizeType,
      this.prize,
      this.prizeType);
}
