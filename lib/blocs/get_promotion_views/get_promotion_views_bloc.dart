import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_promotion_views/get_promotion_views_event.dart';
import 'package:property_feeds/blocs/get_promotion_views/get_promotion_views_state.dart';
import 'package:property_feeds/models/get_promotion_views_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/promotion_service.dart';

class GetPromotionViewsBloc
    extends Bloc<GetPromotionViewsEvent, GetPromotionViewsState> {
  PromotionService promotionService = PromotionService();

  GetPromotionViewsBloc() : super(Initial()) {
    on<GetPromotionViews>(getPromotionViews);
  }

  Future<void> getPromotionViews(
      GetPromotionViews event, Emitter<GetPromotionViewsState> emit) async {
    emit(Loading());
    Map<String, String> params = {
      "method": "get_promotion_views",
      "promotion_id": event.promotionId ?? ""
    };

    print(params);
    final apiResponse = await promotionService.getPromotionViews(params);
    if (apiResponse.status == Status.success) {
      GetPromotionViewsResponse getPromotionViewsResponse =
          GetPromotionViewsResponse.fromJson(apiResponse.data);
      if (getPromotionViewsResponse.status == "success") {
        if (getPromotionViewsResponse.data != null) {
          emit(PromotionViewsLoaded(true, getPromotionViewsResponse.data));
        } else {
          emit(PromotionViewsLoaded(false, getPromotionViewsResponse.data));
          emit(Error("Promotion data not found"));
        }
      } else {
        emit(Error(getPromotionViewsResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }
}
