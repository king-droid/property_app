import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_posts_interests/get_post_interests_bloc.dart';
import 'package:property_feeds/blocs/get_posts_interests/get_post_interests_event.dart';
import 'package:property_feeds/blocs/get_posts_interests/get_post_interests_state.dart';
import 'package:property_feeds/blocs/post/post_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/post_interest.dart';
import 'package:property_feeds/utils/app_utils.dart';

class PostInterestsScreen extends StatefulWidget {
  @override
  PostInterestsScreenState createState() => PostInterestsScreenState();
}

class PostInterestsScreenState extends State<PostInterestsScreen> {
  final bloc = PostBloc();
  Post? post;

  PostInterestsScreenState();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GetPostInterestsBloc>(context)
          .add(GetPostInterests(post?.postId ?? ""));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    post = (ModalRoute
        .of(context)!
        .settings
        .arguments) as Post;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.screenTitleColor,
              size: 22,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Post Interests",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.white,
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          margin: EdgeInsets.only(left: 5, right: 5),
          child: BlocConsumer<GetPostInterestsBloc, GetPostInterestsState>(
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
              } else if (state is PostInterestsLoaded) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  itemCount: (state.postViews ?? []).length,
                  itemBuilder: (BuildContext context, int index) {
                    PostInterest postInterest = (state.postViews ?? [])[index];
                    return PostInterestItem(postInterest);
                  },
                );
              } else {
                return Container(
                  child: Center(
                    child: Text(
                      "No interests",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                          fontSize: 13,
                          color: AppColors.lineBorderColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }
            },
            listener: (context, state) async {
              if (state is PostInterestsLoaded) {}
            },
          ),
        ),
      ),
    );
  }

  Widget PostInterestItem(PostInterest? postInterest) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          child: ListTile(
            leading: Container(
              child: (postInterest?.user?.profilePic ?? "").isNotEmpty
                  ? Container(
                child: CircleAvatar(
                  backgroundColor: AppColors.semiPrimary,
                  radius: 22,
                  child: ClipOval(
                    child: Image(
                      width: 44.5,
                      height: 44,
                      image: NetworkImage(
                        AppConstants.imagesBaseUrl +
                            "/profile_images/" +
                            (postInterest?.user?.profilePic ?? ""),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  : Container(
                child: CircleAvatar(
                    radius: 22,
                    backgroundImage:
                    AssetImage('assets/default_profile_pic.png')),
              ),
            ),
            contentPadding: EdgeInsets.all(0),
            title: Text(
              postInterest?.user?.userName ?? "",
              style: TextStyle(
                fontFamily: "Roboto_Bold",
                fontWeight: FontWeight.w500,
                color: Colors.black87.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
            trailing: Text(
              AppUtils.getFormattedPostDate(
                  postInterest?.postInterestDate ?? ""),
              style: TextStyle(
                fontFamily: "muli",
                color: AppColors.subTitleColor,
                fontSize: 11,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.viewProfileScreen,
                  arguments: postInterest?.user?.userId ?? "");
            },
          ),
        ),
        Container(
          //margin: const EdgeInsets.only(left: 10, right: 10),
          height: 0.8,
          color: Colors.black12.withOpacity(0.1),
        ),
      ],
    );
  }
}
