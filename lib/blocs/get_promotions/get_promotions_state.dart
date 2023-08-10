import 'package:property_feeds/models/promotion.dart';

abstract class GetPromotionsState {
  GetPromotionsState();
}

class Initial extends GetPromotionsState {
  Initial() : super();
}

class Loading extends GetPromotionsState {
  Loading() : super();
}

class PromotionsLoaded extends GetPromotionsState {
  final bool? result;
  final List<Promotion>? promotions;

  PromotionsLoaded(this.result, this.promotions) : super();
}

class Error extends GetPromotionsState {
  final String? error;

  Error(this.error) : super();
}
