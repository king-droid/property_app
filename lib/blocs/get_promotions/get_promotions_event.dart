abstract class GetPromotionsEvent {}

class GetPromotions extends GetPromotionsEvent {
  final bool? isRefresh;
  final String? userId;
  final String? city;

  GetPromotions(this.isRefresh, this.userId, this.city);
}
