import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_user_posts/get_user_posts_bloc.dart';
import 'package:property_feeds/blocs/get_user_posts/get_user_posts_event.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/screens/post_item.dart';
import 'package:provider/provider.dart';

import '../blocs/get_user_posts/get_user_posts_state.dart';

class UserPostsScreen extends StatefulWidget {
  @override
  _UserPostsScreenState createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  int? postsCount;
  String? userId;
  User? loggedInUser;

  getUserPosts() {
    BlocProvider.of<GetUserPostsBloc>(context).add(GetUserPosts(userId ?? ""));
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getUserPosts();
    });
    super.initState();
  }

  Future<void> _pullRefresh() async {
    getUserPosts();
  }

  @override
  Widget build(BuildContext context) {
    userId = ((ModalRoute.of(context)!.settings.arguments) as String) ?? "";
    loggedInUser = Provider.of<UserProvider>(context, listen: false).userData;

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
        title: Text(
            userId == (loggedInUser?.userId ?? "") ? "My Posts" : "User Posts",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.bgColor,
        child: Column(
          children: [
            _buildPostListViewWidget(),
          ],
        ),
      ),
    );
  }

  _buildPostListViewWidget() {
    return Expanded(
        flex: 1,
        child: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: BlocConsumer<GetUserPostsBloc, GetUserPostsState>(
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
                } else if (state is PostsLoaded) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    itemCount: (state.posts ?? []).length,
                    itemBuilder: (BuildContext context, int index) {
                      Post post = (state.posts ?? [])[index];
                      return PostItem(
                        post: post,
                        postDeleteCallback: (postId) {},
                        postRefreshCallback: (status) {},
                      );
                    },
                  );
                } else {
                  return Container(
                    child: Center(
                      child: Text(
                        "No posts",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.lineBorderColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }
              },
              listener: (context, state) async {},
            )));
  }
}
