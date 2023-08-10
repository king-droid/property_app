abstract class GetPromotionViewsEvent {}

class GetPromotionViews extends GetPromotionViewsEvent {
  final String? promotionId;

  GetPromotionViews(this.promotionId);
}
