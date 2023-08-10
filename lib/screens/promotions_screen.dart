import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:property_feeds/blocs/get_promotions/get_promotions_bloc.dart';
import 'package:property_feeds/components/custom_icon_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/models/promotion.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/screens/feeds_screen.dart';
import 'package:property_feeds/screens/promotion_item.dart';
import 'package:property_feeds/screens/promotion_item_placeholder.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:property_feeds/utils/chips_input.dart';
import 'package:property_feeds/widgets/native_add_widget_promotions_listing.dart';
import 'package:provider/provider.dart';

class Promotions extends StatefulWidget {
  @override
  _PromotionsState createState() => _PromotionsState();
}

class _PromotionsState extends State<Promotions> {
  User? user;
  BannerAd? _ad;
  List<Promotion>? promotions = [];
  GetPromotionsBloc getPromotionsBloc = GetPromotionsBloc();
  String? selectedCity = "";
  int selectedCityIndex = 0;
  List<String> cities = [];
  List<String> allCities = [];
  bool isLoading = true;
  int offset = 0;
  bool isPaginationLoading = false;
  ScrollController _listViewScrollController = new ScrollController();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context)
        .loadString("assets/cities.txt")
        .then((value) {
      value = value.replaceAll("\n", "");
      allCities = value.split(',');
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      selectedCity = user?.defaultCity ?? "";
      setState(() {
        cities = (user?.interestedCities ?? "").trim().isNotEmpty
            ? (user?.interestedCities ?? "").split(',')
            : [];
      });
      getPromotions();
    });
    _listViewScrollController.addListener(() {
      if (_listViewScrollController.offset ==
          _listViewScrollController.position.maxScrollExtent) {
        //print("next page...");
        if (promotions!.length <
                (int.parse(getPromotionsBloc.totalResults ?? "0")) &&
            !isPaginationLoading) {
          if (offset + 5 < (int.parse(getPromotionsBloc.totalResults ?? "0")))
            offset = offset + 5;
          else
            offset = offset +
                ((int.parse(getPromotionsBloc.totalResults ?? "0")) - offset);
          getPromotions(isPagination: true);
        }
      }
    });
  }

  Future<void> _pullRefresh() async {
    offset = 0;
    refreshKey.currentState!.show();
    getPromotions(isPagination: false);
    //BlocProvider.of<GetPromotionsBloc>(context).add(GetPromotions(true, user?.userId ?? "", user?.defaultCity));
    await Future.delayed(Duration(seconds: 2));
  }

  getPromotions({bool? isPagination}) {
    //BlocProvider.of<GetPromotionsBloc>(context).add(GetPromotions(false, user?.userId ?? "", user?.defaultCity));

    setState(() {
      isLoading = isPagination == true ? false : true;
      isPaginationLoading = isPagination == true ? true : false;
    });
    getPromotionsBloc
        .getAllPromotions(isPagination ?? false, user?.userId ?? "",
            user?.defaultCity, offset, isPagination ?? false)
        .then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isPaginationLoading = false;
          promotions = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Promotions",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
        leading: (user?.accountType == "guest_account")
            ? Container()
            : IconButton(
                icon: Icon(Icons.location_on, color: AppColors.primaryColor),
                onPressed: () {
                  //_showFilterCategoryDialog();
                  _showSearchCityDialog();
                }),
        /*actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_alt, color: AppColors.primaryColor),
            onPressed: () {},
          ),
        ],*/
      ),
      body: Container(
        color: AppColors.bgColorLight,
        child: Column(
          children: [
            _buildPostListViewWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        child: Icon(
          Icons.add,
          size: 25,
        ),
        onPressed: () async {
          if ((user?.accountType == "guest_account")) {
            AppUtils.showNativeAlertDialog(
                context: context,
                title: "Registration required",
                content:
                    "You are currently using app as guest.\n\nYou need to create account to access all features of app.",
                cancelActionText: "Cancel",
                defaultActionText: "Create account Now",
                defaultActionClick: () {
                  Navigator.pushNamed(context, AppRoutes.landingScreen);
                });
          } else {
            if (((user?.userType ?? "") == "end_user") ||
                ((user?.userType ?? "") == "investor")) {
              AppUtils.showNativeAlertDialog(
                context: context,
                title: "Add Promotion",
                content:
                    "Promotions can only be added by users who are registered as Dealers or Real Estate Company.\n\nYou can use properties section to post your property requirements for buying, selling and renting purposes.",
                defaultActionText: "Ok, Got It!",
              );
              return;
            }
            await Navigator.pushNamed(context, AppRoutes.addPromotionScreen,
                arguments: {"mode": "add"}).then((value) {
              if (value == true) {
                getPromotions(isPagination: false);
              }
            });
          }
        },
      ),
    );
  }

  _showSearchCityDialog() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: (selectedCity ?? "").isEmpty ? false : true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: WillPopScope(
              onWillPop: () async {
                return (selectedCity ?? "").isEmpty ? false : true;
              },
              child: StatefulBuilder(builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildCitySelectionBottomSheetWidget((String selectedCity) {
                      user?.defaultCity = selectedCity;
                      /*Provider.of<UserProvider>(context, listen: false)
                          .updateUser(user);*/
                      getPromotions(isPagination: false);
                    }),
                    //Navigator.pop(context);
                    const SizedBox(height: 15),
                  ],
                );
              }),
            ),
          );
        });
  }

  Widget _buildCitySelectionBottomSheetWidget(
      CitySelectCallback citySelectCallback) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 15),
              Container(
                child: Icon(
                  Icons.location_city,
                  color: AppColors.primaryColor,
                  size: 25.0,
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 20, bottom: 0),
                  child: Text("Select City",
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 15),
          (user?.accountType != "guest_account")
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, top: 5, bottom: 15, right: 15),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                        (cities ?? []).length,
                        (index) {
                          return InkWell(
                            onTap: () async {
                              setState(() {
                                selectedCityIndex = index;
                              });
                              user?.defaultCity =
                                  (cities ?? [])[selectedCityIndex];
                              Provider.of<UserProvider>(context, listen: false)
                                  .updateUser(user);
                              await AppUtils.saveUser(user);
                              citySelectCallback
                                  .call((cities ?? [])[selectedCityIndex]);
                              Navigator.pop(context);
                              /*BlocProvider.of<GetPostsBloc>(context).add(GetPosts(
                              user?.userId ?? "",
                              cities[selectedCityIndex] ?? ""));*/
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: (cities ?? [])[index] ==
                                        user?.defaultCity
                                    ? AppColors.primaryColor.withOpacity(0.8)
                                    : AppColors.semiPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 8, bottom: 8),
                              child: Text(
                                cities![index] ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: (cities ?? [])[index] ==
                                                user?.defaultCity
                                            ? Colors.white
                                            : Colors.black54,
                                        fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : Container(),
          (user?.accountType == "guest_account")
              ? _buildSuggestionBuilder2()
              : Container(),
          const SizedBox(height: 15),
          Container(
            margin: EdgeInsets.only(left: 35, right: 30),
            child: Text(
              "Note:- Posts will be shown matching city selected here.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.black54, fontSize: 12),
            ),
          ),
          (user?.accountType == "guest_account")
              ? Container(
                  margin: const EdgeInsets.only(
                      top: 15, left: 40, right: 40, bottom: 10),
                  child: CustomIconButton(
                      //width: 200,
                      elevation: 1,
                      cornerRadius: 10,
                      text: "Done",
                      color: AppColors.primaryColor,
                      textStyle: const TextStyle(
                          fontSize: 16,
                          color: AppColors.buttonTextColorWhite,
                          fontFamily: "Muli"),
                      onPress: () async {
                        /*if ((selectedCity ?? "").isEmpty) {
                          AppUtils.showToast(
                              "Select at least one city to continue");
                          return;
                        }*/
                        offset = 0;
                        user?.defaultCity = selectedCity;
                        /*Provider.of<UserProvider>(context, listen: false)
                            .updateUser(user);
                        await AppUtils.saveUser(user);*/
                        getPromotions();
                        Navigator.pop(context);
                      }),
                )
              : Container(),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  _buildSuggestionBuilder2() {
    selectedCity = user?.defaultCity;
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30.0, top: 0.0),
      child: ChipsInput<String>(
        maxChips: 1,
        initialValue:
            (selectedCity ?? "").isNotEmpty ? [selectedCity ?? ""] : [],
        decoration: InputDecoration(
          filled: true,
          isCollapsed: true,
          isDense: true,
          alignLabelWithHint: true,
          fillColor: AppColors.textFieldBgColorLight,
          contentPadding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          counterText: "",
          hintText: 'Search city name',
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.black38),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
                color: AppColors.textFieldBgColorLight, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        findSuggestions: _findSuggestions,
        onChanged: (str) {
          //isCitiesFieldValid.value = true;
          print(str);
        },
        chipBuilder:
            (BuildContext context, ChipsInputState<String> state, String city) {
          return InputChip(
            //labelPadding: const EdgeInsets.only(left: 5, right: 1, top: 1, bottom: 3),
            deleteIcon: Icon(
              Icons.close,
              color: Colors.white,
              size: 18.0,
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 3,
            shadowColor: Colors.grey[60],
            key: ObjectKey(city),
            label: Text(
              city.toString(),
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            onDeleted: () {
              selectedCity = "";
              //selectedCities.remove(city.toString());
              state.deleteChip(city);
              /*if (selectedCities.isNotEmpty) {
                isCitiesFieldValid.value = true;
              }*/
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
        suggestionBuilder:
            (BuildContext context, ChipsInputState<String> state, String city) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: ObjectKey(city),
                dense: true,
                contentPadding: EdgeInsets.only(left: 5),
                title: Text(city.toString(),
                    style: Theme.of(context).textTheme.bodySmall!),
                onTap: () {
                  selectedCity = city.toString();
                  //selectedCities.add(city.toString());
                  state.selectSuggestion(city);
                  /*if (selectedCities.isNotEmpty) {
                    isCitiesFieldValid.value = true;
                  }*/
                },
              ),
              Container(
                color: AppColors.bgColor,
                height: 1,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<String>> _findSuggestions(String query) async {
    if (query.length != 0) {
      return allCities.where((city) {
        return city.toLowerCase().startsWith(query.toLowerCase());
      }).toList(growable: false);
    } else {
      return const <String>[];
    }
  }

  _buildPostListViewWidget() {
    return Expanded(
        flex: 1,
        child: RefreshIndicator(
          key: refreshKey,
          onRefresh: _pullRefresh,
          child: isLoading
              ? /*Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 35.0, right: 35.0, top: 30.0, bottom: 10),
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )*/
              Column(mainAxisSize: MainAxisSize.min, children: [
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return PromotionItemPlaceHolder(
                          promotionDeleteCallback: (postId) {
                            setState(() {
                              (promotions ?? []).removeAt(index);
                            });
                          },
                          promotionRefreshCallback: (status) {
                            if (status) {
                              getPromotions();
                            }
                          },
                        );
                      },
                    ),
                  )
                ])
              : /*kIsWeb
                  ? _buildWebPostsListViewWidget()
                  :*/
              NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //_buildResultsCountWidget(),
                      Expanded(
                          flex: 1,
                          child: (promotions ?? []).isNotEmpty
                              ? _buildPromotionsListViewWidget()
                              : _buildNoPromotionsWidget()),
                    ],
                  ),
                ),
          /*BlocConsumer<GetPromotionsBloc, GetPromotionsState>(
              builder: (context, state) {
                if (state is Loading) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 35.0, right: 35.0, top: 30.0, bottom: 10),
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                } else if (state is PromotionsLoaded) {
                  //refreshKey.currentState?.deactivate();
                  return kIsWeb
                      ? MasonryGridView.count(
                          itemCount: (state.promotions ?? []).length,
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          itemBuilder: (context, index) {
                            Promotion promotion =
                                (state.promotions ?? [])[index];
                            return GridTile(
                              child: PromotionItem(
                                promotion: promotion,
                                promotionDeleteCallback: (postId) {
                                  setState(() {
                                    (state.promotions ?? []).removeAt(index);
                                  });
                                },
                                promotionRefreshCallback: (status) {
                                  if (status) {
                                    getPromotions();
                                  }
                                },
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          itemCount: (state.promotions ?? []).length,
                          itemBuilder: (BuildContext context, int index) {
                            Promotion promotion =
                                (state.promotions ?? [])[index];
                            return PromotionItem(
                              promotion: promotion,
                              promotionDeleteCallback: (postId) {
                                setState(() {
                                  (state.promotions ?? []).removeAt(index);
                                });
                              },
                              promotionRefreshCallback: (status) {
                                if (status) {
                                  getPromotions();
                                }
                              },
                            );
                          },
                        );
                } else {
                  return Stack(
                    children: <Widget>[
                      ListView(),
                      Container(
                        //color: Colors.blue,
                        child: Center(
                          child: Text(
                            "No promotions",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 13,
                                    color: AppColors.lineBorderColor,
                                    fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  );
                }
              },
              listener: (context, state) async {
                if (state is PromotionsLoaded) {
                  //postsCount.value = (state.posts ?? []).length;
                } else if (state is Loading) {
                  //postsCount.value = 0;
                }
              },
            )*/
        ));
  }

  _buildWebPostsListViewWidget() {
    return MasonryGridView.count(
      itemCount: (promotions ?? []).length,
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        Promotion promotion = (promotions ?? [])[index];
        return GridTile(
          child: PromotionItem(
            promotion: promotion,
            promotionDeleteCallback: (postId) {
              setState(() {
                (promotions ?? []).removeAt(index);
              });
            },
            promotionRefreshCallback: (status) {
              if (status) {
                getPromotions();
              }
            },
          ),
        );
      },
    );
  }

  _buildPromotionsListViewWidget() {
    return SingleChildScrollView(
      controller: _listViewScrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 0),
            itemCount: (promotions ?? []).length,
            itemBuilder: (BuildContext context, int index) {
              Promotion promotion = (promotions ?? [])[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PromotionItem(
                    promotion: promotion,
                    promotionDeleteCallback: (postId) {
                      setState(() {
                        (promotions ?? []).removeAt(index);
                      });
                    },
                    promotionRefreshCallback: (status) {
                      if (status) {
                        getPromotions();
                      }
                    },
                  ),
                  index != 0 && index % 2 == 0
                      ? NativeAdWidgetPromotionsListing()
                      : Container()
                ],
              );
            },
          ),
          promotions!.length <
                  (int.parse(getPromotionsBloc.totalResults ?? "0"))
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, bottom: 10, right: 5),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10),
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Loading more results",
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.black54, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  _buildNoPromotionsWidget() {
    return Stack(
      children: <Widget>[
        ListView(),
        Container(
          //color: Colors.white,
          child: Center(
            child: Text(
              "No promotions",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.lineBorderColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }
}
