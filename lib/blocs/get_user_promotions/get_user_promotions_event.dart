abstract class GetUserPromotionsEvent {}

class GetUserPromotions extends GetUserPromotionsEvent {
  final String? userId;

  GetUserPromotions(this.userId);
}
