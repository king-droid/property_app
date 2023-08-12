import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_user_promotions/get_user_promotions_event.dart';
import 'package:property_feeds/blocs/get_user_promotions/get_user_promotions_state.dart';
import 'package:property_feeds/models/get_promotions_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/promotion_service.dart';

class GetUserPromotionsBloc
    extends Bloc<GetUserPromotionsEvent, GetUserPromotionsState> {
  PromotionService promotionService = PromotionService();

  GetUserPromotionsBloc() : super(Initial()) {
    on<GetUserPromotions>(GetUserAllPromotions);
  }

  Future<void> GetUserAllPromotions(
      GetUserPromotions event, Emitter<GetUserPromotionsState> emit) async {
    emit(Loading());
    Map<String, String> params = {
      "method": "get_user_promotions",
      "user_id": event.userId ?? ""
    };

    print(params);
    final apiResponse = await promotionService.getUserPromotions(params);
    if (apiResponse.status == Status.success && apiResponse.data != null) {
      GetPromotionsResponse getPromotionsResponse =
          GetPromotionsResponse.fromJson(apiResponse.data);
      if (getPromotionsResponse.status == "success") {
        if (getPromotionsResponse.data != null) {
          emit(PromotionsLoaded(
              true, getPromotionsResponse.data?.promotions ?? []));
        } else {
          emit(PromotionsLoaded(
              false, getPromotionsResponse.data?.promotions ?? []));
          emit(Error("Promotions data not found"));
        }
      } else {
        emit(Error(getPromotionsResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }
}
