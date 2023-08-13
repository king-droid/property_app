import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:property_feeds/blocs/get_posts/get_posts_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/screens/post_item.dart';
import 'package:property_feeds/utils/Debouncer.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:property_feeds/utils/chips_input.dart';
import 'package:property_feeds/widgets/native_add_widget_posts_listing.dart';
import 'package:provider/provider.dart';

typedef CitySelectCallback = void Function(String);
typedef FilterSelectCallback = void Function(String);

class Feeds extends StatefulWidget {
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  List<String> categories = ["All", "Buy", "Sell", "Rent"];
  List<String> cities = [];
  List<String> allCities = [];
  ScrollController _listViewScrollController = new ScrollController();

  List<String> selectedCities = [];
  String? selectedCity = "";
  String? totalResults = "";
  ValueNotifier<int> postsCount = ValueNotifier(0);
  final Debouncer onSearchDebouncer =
      new Debouncer(delay: new Duration(milliseconds: 500));
  User? user;
  GetPostsBloc getPostsBloc = GetPostsBloc();
  TextEditingController? _editingController = TextEditingController();

  //BannerAd? _ad;
  NativeAd? _nativeAd;
  bool isAdLoaded = false;

  //BannerAd? _adLListing;
  List<Post>? posts = [];
  int selectedCityIndex = 0;
  int offset = 0;
  int selectedCategoryIndex = 0;
  String selectedCategory = "all";
  String searchKeyword = "";
  bool isLoading = true;
  bool isPaginationLoading = false;
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  getPosts({bool? isPagination}) {
    setState(() {
      isLoading = isPagination == true ? false : true;
      isPaginationLoading = isPagination == true ? true : false;
    });
    getPostsBloc
        .getAllPosts(
            isPagination ?? false,
            user?.userId ?? "",
            user?.defaultCity,
            selectedCategory,
            searchKeyword,
            offset,
            isPagination ?? false)
        .then((value) {
      setState(() {
        isLoading = false;
        isPaginationLoading = false;
        posts = value;
      });
    });
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      DefaultAssetBundle.of(context)
          .loadString("assets/cities.txt")
          .then((value) {
        value = value.replaceAll("\n", "");
        allCities = value.split(',');
      });
      selectedCity = user?.defaultCity ?? "";
      Future.delayed(Duration(seconds: 1)).then((value) {
        if (user?.accountType == "guest_account" &&
            (selectedCity ?? "").isEmpty) {
          _showSearchCityDialog();
        }
      });

      setState(() {
        cities = (user?.interestedCities ?? "").trim().isNotEmpty
            ? (user?.interestedCities ?? "").split(',')
            : [];
      });
      getPosts();
    });
    _listViewScrollController.addListener(() {
      if (_listViewScrollController.offset ==
          _listViewScrollController.position.maxScrollExtent) {
        //print("next page...");
        if (posts!.length < (int.parse(getPostsBloc.totalResults ?? "0")) &&
            !isPaginationLoading) {
          if (offset + 10 < (int.parse(getPostsBloc.totalResults ?? "0")))
            offset = offset + 10;
          else
            offset = offset +
                ((int.parse(getPostsBloc.totalResults ?? "0")) - offset);
          getPosts(isPagination: true);
        }
      }
    });

    super.initState();
  }

  Future<void> _pullRefresh() async {
    offset = 0;
    refreshKey.currentState!.show();
    getPosts(isPagination: false);
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      body: Container(
        color: AppColors.whiteLight,
        child: Column(
          children: [
            _buildSearchBarWidget(),
            //_buildSeparatorWidget(),
            //_buildCategorySelectionWidget(),
            _buildPostListViewWidget(),
            //_buildBottomAdViewWidget(),
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
            await Navigator.pushNamed(context, AppRoutes.addPostScreen,
                arguments: {"mode": "add"}).then((value) {
              if (value == true) {
                getPosts();
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildSearchBarWidget() {
    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Row(
        children: [
          IconButton(
              icon: Icon(Icons.location_on, color: AppColors.primaryColor),
              onPressed: () {
                //_showFilterCategoryDialog();
                _showSearchCityDialog();
              }),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              margin:
                  const EdgeInsets.only(left: 1, right: 1, top: 8, bottom: 2),
              padding: const EdgeInsets.only(left: 10),
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(width: 1, color: Colors.grey.withOpacity(0.9)),
                borderRadius: BorderRadius.circular(12),
                /*boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 10),
                      blurRadius: 50,
                      color: Theme.of(context).primaryColor.withOpacity(0.23),
                    )
                  ]*/
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _editingController,
                      textAlignVertical: TextAlignVertical.center,
                      autofocus: false,
                      onChanged: (value) {
                        this.onSearchDebouncer.debounce(
                          () {
                            searchKeyword = value;
                            offset = 0;
                            getPosts(isPagination: false);
                            setState(() {});
                          },
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        isDense: true,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black38),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  _editingController!.text.trim().isEmpty
                      ? IconButton(
                          icon:
                              Icon(Icons.search, color: AppColors.primaryColor),
                          onPressed: null)
                      : IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon:
                              Icon(Icons.clear, color: AppColors.primaryColor),
                          onPressed: () {
                            setState(() {
                              _editingController!.clear();
                              FocusScope.of(context).requestFocus(FocusNode());
                            });
                            searchKeyword = "";
                            offset = 0;
                            getPosts(isPagination: false);
                          }),
                ],
              ),
            ),
          ),
          IconButton(
              icon: Icon(Icons.filter_alt, color: AppColors.primaryColor),
              onPressed: () {
                //_showFilterSortDialog();
                _showFilterCategoryDialog();
              }),
          /*IconButton(
              icon: Icon(Icons.location_city, color: AppColors.primaryColor),
              onPressed: () {
                _showSearchCityDialog();
              }),*/
        ],
      ),
    );
  }

  _buildSeparatorWidget() {
    return Container(color: Colors.black26, height: 0.5);
  }

  _buildCategorySelectionWidget() {
    return StatefulBuilder(builder: (context, setState) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                _showSearchCityDialog();
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8),
                //color: Colors.blue,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                    child: Icon(
                      Icons.location_pin,
                      color: AppColors.primaryColor,
                      size: 15.0,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Text(
                        (user?.defaultCity ?? "").trim(),
                        maxLines: 2,
                        textAlign: TextAlign.end,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          ValueListenableBuilder(
              valueListenable: postsCount,
              builder: (BuildContext context, int postsCount, Widget? child) {
                return postsCount == 0
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Text(
                          /*(${categories[selectedCategoryIndex] ?? ""})*/
                          "${postsCount} results",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.black54, fontSize: 12),
                        ),
                      );
              }),
        ],
      );
    });
  }

  _buildPostListViewWidget() {
    return Expanded(
        flex: 1,
        child: RefreshIndicator(
          key: refreshKey,
          onRefresh: _pullRefresh,
          child: isLoading
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return Opacity(
                          opacity: 0.8,
                          child: Container(
                              margin: EdgeInsets.only(
                                  left: 8, top: 5, right: 8, bottom: 5),
                              child: Image.asset(
                                "assets/post_loading.png",
                                width: MediaQuery.of(context).size.width,
                                //height: 100,
                                fit: BoxFit.fitWidth,
                              )),
                        );
                      },
                    ),
                  ),
                ])
              /*Center(
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
              : /*kIsWeb
                  ? NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildResultsCountWidget(),
                          Expanded(
                              flex: 1, child: _buildWebPostsListViewWidget())
                        ],
                      ),
                    )
                  :*/
              NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildResultsCountWidget(),
                      Expanded(
                          flex: 1,
                          child: (posts ?? []).isNotEmpty
                              ? _buildPostsListViewWidget()
                              : _buildNoPostsWidget()),
                    ],
                  ),
                ),
        ));
  }

  _buildResultsCountWidget() {
    return (user?.defaultCity ?? "").isEmpty
        ? Container()
        : Container(
            margin: EdgeInsets.only(bottom: 3, top: 2),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${user?.defaultCity} > ${selectedCategory}",
                    textAlign: TextAlign.end,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.black54, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: (posts ?? []).isNotEmpty
                      ? Container(
                          margin: EdgeInsets.only(bottom: 5, right: 10),
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${posts?.length} of ${getPostsBloc.totalResults ?? "0"} results",
                            textAlign: TextAlign.end,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.black54, fontSize: 12),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          );
  }

  _buildWebPostsListViewWidget() {
    return MasonryGridView.count(
      itemCount: (posts ?? []).length,
      crossAxisCount: 1,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        Post post = (posts ?? [])[index];
        return GridTile(
          child: PostItem(
            post: post,
            postDeleteCallback: (postId) {
              setState(() {
                (posts ?? []).removeAt(index);
              });
            },
            postRefreshCallback: (status) {
              if (status) {
                getPosts();
              }
            },
          ),
        );
      },
    );
  }

  _buildPostsListViewWidget() {
    return SingleChildScrollView(
      controller: _listViewScrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            //padding: EdgeInsets.symmetric(horizontal: 0),
            itemCount: (posts ?? []).length,
            itemBuilder: (BuildContext context, int index) {
              Post post = (posts ?? [])[index];
              return Column(mainAxisSize: MainAxisSize.min, children: [
                PostItem(
                  post: post,
                  postDeleteCallback: (postId) {
                    setState(() {
                      (posts ?? []).removeAt(index);
                    });
                  },
                  postRefreshCallback: (status) {
                    if (status) {
                      getPosts();
                    }
                  },
                ),
                index != 0 && index % 2 == 0
                    ? NativeAdWidgetPostsListing()
                    : Container()
              ]);
            },
          ),
          posts!.length < (int.parse(getPostsBloc.totalResults ?? "0"))
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

  _buildNoPostsWidget() {
    return Stack(
      children: <Widget>[
        ListView(),
        Container(
          //color: Colors.white,
          child: Center(
            child: Text(
              "No posts",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.lineBorderColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }

  /*Widget _buildGuestCitySelectionBottomSheetWidget(
      CitySelectCallback citySelectCallback) {
    return Column(
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
        Padding(
          padding:
              const EdgeInsets.only(left: 15.0, top: 5, bottom: 15, right: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: _buildSuggestionBuilder2(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 20, right: 10),
          child: Text(
            "Note:- Posts will be shown matching city selected here.",
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.black54, fontSize: 12),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
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
                if ((selectedCities ?? []).isEmpty) {
                  AppUtils.showToast("Select at least one city to continue");
                  return;
                }
                cities = selectedCities;
                user?.defaultCity = selectedCities[0];
                Provider.of<UserProvider>(context, listen: false)
                    .updateUser(user);
                getPosts();
                Navigator.pop(context);
              }),
        ),
      ],
    );
  }*/

  _buildSuggestionBuilder1() {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 20.0, top: 10.0),
      //width: MediaQuery.of(context).size.width,
      height: 205,
      child: ChipsInput<String>(
        initialValue: cities,
        maxChips: 3,
        //enabled: selectedCities.length <= 3,
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
            borderSide: const BorderSide(
                color: AppColors.textFieldBgColorLight, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: AppColors.textFieldBgColorLight, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        findSuggestions: _findSuggestions,
        onChanged: (str) {
          selectedCities.clear();
          selectedCities.addAll(str);
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
            //padding: const EdgeInsets.all(5.0),
            key: ObjectKey(city),
            label: Text(
              city.toString(),
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            onDeleted: () {
              state.deleteChip(city);
              //updateButtonState();
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
        suggestionBuilder:
            (BuildContext context, ChipsInputState<String> state, String city) {
          return ListTile(
            key: ObjectKey(city),
            dense: true,
            contentPadding: EdgeInsets.only(left: 5),
            title: Text(city.toString(),
                style: Theme.of(context).textTheme.bodySmall!),
            onTap: () {
              state.selectSuggestion(city);
              //updateButtonState();
            },
          );
        },
      ),
    );
  }

  _buildSuggestionBuilder2() {
    selectedCity = user?.defaultCity;
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 10),
        child: Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            children: List.generate(
              (allCities ?? []).length,
              (index) {
                return GestureDetector(
                  onTap: () async {
                    selectedCity = allCities[index] ?? "";
                    if ((selectedCity ?? "").isEmpty) {
                      AppUtils.showToast(
                          "Select at least one city to continue");
                      return;
                    }
                    user?.defaultCity = selectedCity;
                    Provider.of<UserProvider>(context, listen: false)
                        .updateUser(user);
                    await AppUtils.saveUser(user);
                    getPosts();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 3, right: 3, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: selectedCity == (allCities[index] ?? "")
                          ? AppColors.primaryColor
                          : AppColors.white,
                      border: Border.all(
                          width: 1,
                          color: selectedCity == (allCities[index] ?? "")
                              ? AppColors.primaryColor
                              : AppColors.titleColorLight),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    padding: const EdgeInsets.only(
                        left: 7, right: 7, top: 4, bottom: 4),
                    child: Text(
                      allCities![index] ?? "",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: selectedCity == (allCities[index] ?? "")
                              ? AppColors.white
                              : AppColors.titleColorLight,
                          fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }); /*Container(
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
              */ /*if (selectedCities.isNotEmpty) {
                isCitiesFieldValid.value = true;
              }*/ /*
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
                  */ /*if (selectedCities.isNotEmpty) {
                    isCitiesFieldValid.value = true;
                  }*/ /*
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
    );*/
  }

  /*_showGuestCitySelectDialog() {
    cities.clear();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildGuestCitySelectionBottomSheetWidget((value) {
                  setState(() {});
                }),
                //Navigator.pop(context);
                const SizedBox(height: 15),
              ],
            ),
          );
        });
  }*/

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
          /* (user?.accountType == "guest_account")
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
                        if ((selectedCity ?? "").isEmpty) {
                          AppUtils.showToast(
                              "Select at least one city to continue");
                          return;
                        }
                        user?.defaultCity = selectedCity;
                        Provider.of<UserProvider>(context, listen: false)
                            .updateUser(user);
                        await AppUtils.saveUser(user);
                        getPosts();
                        Navigator.pop(context);
                      }),
                )
              : Container(),*/
          const SizedBox(height: 5),
        ],
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
                return Container(
                    margin:
                        const EdgeInsets.only(left: 15, right: 15.0, top: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildCitySelectionBottomSheetWidget(
                            (String selectedCity) {
                          user?.defaultCity = selectedCity;
                          Provider.of<UserProvider>(context, listen: false)
                              .updateUser(user);
                          getPosts();
                        }),
                        //Navigator.pop(context);
                        const SizedBox(height: 15),
                      ],
                    ));
              }),
            ),
          );
        });
  }

  _showFilterCategoryDialog() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Container(
                  //color: Colors.amber,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 20, bottom: 0),
                    child: Text(
                      "Filter results by",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                StatefulBuilder(builder: (context, setState) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          // /color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, top: 1, bottom: 5, right: 5),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.start,
                                children: List.generate(
                                  (categories ?? []).length,
                                  (index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategoryIndex = index;
                                          selectedCategory = categories[
                                                  selectedCategoryIndex] ??
                                              "all";
                                        });
                                        getPosts();
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 3,
                                            right: 3,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                          color: index == selectedCategoryIndex
                                              ? AppColors.primaryColor
                                                  .withOpacity(0.8)
                                              : AppColors.semiPrimary,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 8,
                                            bottom: 8),
                                        child: Text(
                                          categories[index] ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: index ==
                                                          selectedCategoryIndex
                                                      ? Colors.white
                                                      : Colors.black54,
                                                  fontSize: 14),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 25),
              ],
            ),
          );
        });
  }

  _showFilterSortDialog() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildFilterSortBottomSheetWidget((String selectedCity) {
                    getPosts();
                  }),
                  const SizedBox(height: 15),
                ],
              );
            }),
          );
        });
  }

  Widget _buildFilterSortBottomSheetWidget(
      FilterSelectCallback selectCallback) {
    String selectedFilter = "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 20, bottom: 0),
                child: Text("Sort results",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 18)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        //_buildSeparatorWidget(),
        //const SizedBox(height: 10),
        StatefulBuilder(builder: (context, innerSetState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, top: 10, right: 15, bottom: 15),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    innerSetState(() => selectedFilter = "sort_by_date");
                    selectCallback.call("sort_by_date");
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          selectedFilter == "sort_by_date"
                              ? Icons.radio_button_on
                              : Icons.radio_button_off,
                          color: AppColors.primaryColor,
                          size: 28),
                      Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "Newest first",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, top: 10, right: 15, bottom: 15),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    innerSetState(() => selectedFilter = "sort_by_relevance");
                    selectCallback.call("sort_by_relevance");
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          selectedFilter == "sort_by_relevance"
                              ? Icons.radio_button_on
                              : Icons.radio_button_off,
                          color: AppColors.primaryColor,
                          size: 28),
                      Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "By relevance",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        })
      ],
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
}
