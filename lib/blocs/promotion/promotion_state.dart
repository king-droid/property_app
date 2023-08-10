import 'package:property_feeds/models/promotion.dart';

abstract class PromotionState {
  PromotionState();
}

class Initial extends PromotionState {
  Initial() : super();
}

class Loading extends PromotionState {
  Loading() : super();
}

class PromotionAdded extends PromotionState {
  final bool? result;
  final Promotion? data;

  PromotionAdded(this.result, this.data) : super();
}

class Error extends PromotionState {
  final String? error;

  Error(this.error) : super();
}
