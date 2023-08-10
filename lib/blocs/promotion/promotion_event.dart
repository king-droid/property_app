abstract class PromotionEvent {}

class InitialEvent extends PromotionEvent {}

class AddPromotion extends PromotionEvent {
  final String? userId;
  final String? title;
  final String? description;
  final String? city;
  final List<String?>? pictures;

  AddPromotion(
    this.userId,
    this.title,
    this.description,
    this.city,
    this.pictures,
  );
}

class UpdatePromotion extends PromotionEvent {
  final String? promotionId;
  final String? userId;
  final String? title;
  final String? description;
  final String? city;
  final List<String?>? pictures;

  UpdatePromotion(this.promotionId, this.userId, this.title, this.description,
      this.city, this.pictures);
}
