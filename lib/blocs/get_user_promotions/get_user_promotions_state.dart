import 'package:property_feeds/models/promotion.dart';

abstract class GetUserPromotionsState {
  GetUserPromotionsState();
}

class Initial extends GetUserPromotionsState {
  Initial() : super();
}

class Loading extends GetUserPromotionsState {
  Loading() : super();
}

class PromotionsLoaded extends GetUserPromotionsState {
  final bool? result;
  final List<Promotion>? promotions;

  PromotionsLoaded(this.result, this.promotions) : super();
}

class Error extends GetUserPromotionsState {
  final String? error;

  Error(this.error) : super();
}
