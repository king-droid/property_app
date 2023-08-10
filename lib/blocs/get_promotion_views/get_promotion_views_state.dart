import 'package:property_feeds/models/promotion_view.dart';

abstract class GetPromotionViewsState {
  GetPromotionViewsState();
}

class Initial extends GetPromotionViewsState {
  Initial() : super();
}

class Loading extends GetPromotionViewsState {
  Loading() : super();
}

class PromotionViewsLoaded extends GetPromotionViewsState {
  final bool? result;
  final List<PromotionView>? promotionViews;

  PromotionViewsLoaded(this.result, this.promotionViews) : super();
}

class Error extends GetPromotionViewsState {
  final String? error;

  Error(this.error) : super();
}
