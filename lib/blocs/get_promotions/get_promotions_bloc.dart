import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_promotions/get_promotions_event.dart';
import 'package:property_feeds/blocs/get_promotions/get_promotions_state.dart';
import 'package:property_feeds/models/get_promotions_response.dart';
import 'package:property_feeds/models/promotion.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/promotion_service.dart';

class GetPromotionsBloc extends Bloc<GetPromotionsEvent, GetPromotionsState> {
  PromotionService promotionService = PromotionService();
  List<Promotion>? allPromotions = [];
  String? totalResults;

  GetPromotionsBloc() : super(Initial()) {
    //on<GetPromotions>(getAllPromotions);
  }

  Future<List<Promotion>?> getAllPromotions(bool isRefresh, String? userId,
      String? city, int? offset, bool? isPagination) async {
    Map<String, String> params = {
      "method": "get_all_promotions",
      "user_id": userId ?? "",
      "city": city?.trim() ?? "",
      "offset": "${offset ?? "0"}",
    };
    if (isPagination == false) {
      allPromotions!.clear();
    }
    print(params);
    final apiResponse = await promotionService.getAllPromotions(params);
    if (apiResponse.status == Status.success && apiResponse.data != null) {
      GetPromotionsResponse getPromotionsResponse =
          GetPromotionsResponse.fromJson(apiResponse.data);
      if (getPromotionsResponse.status == "success") {
        if (getPromotionsResponse.data != null) {
          totalResults = getPromotionsResponse.data?.totalResults ?? "0";
          allPromotions!.addAll(getPromotionsResponse.data?.promotions ?? []);
          return allPromotions ?? [];
          //emit(PromotionsLoaded(true, getPromotionsResponse.data));
        } else {
          //emit(PromotionsLoaded(false, getPromotionsResponse.data));
          return allPromotions ?? [];
          emit(Error("Promotion data not found"));
        }
      } else {
        return allPromotions ?? [];
        //emit(Error(getPromotionsResponse.message));
      }
    } else {
      return allPromotions ?? [];
      //emit(Error(apiResponse.message ?? ""));
    }
  }
}
