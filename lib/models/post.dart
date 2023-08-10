class Post {
  Post(
      {this.postId,
      this.createdOn,
      this.updatedOn,
      this.postTitle,
      this.postDescription,
      this.propertyLocation,
      this.propertyPrice,
      this.propertySize,
      this.postPic,
      this.postedBy,
      this.propertyPriceType,
      this.propertySizeType,
      this.postStatus,
      this.postIssue,
      this.propertyCity,
      this.userName,
      this.userType,
      this.companyName,
      this.profilePic,
      this.postViewsCount,
      this.interestsCount,
      this.postsCount,
      this.promotionsCount,
      this.userInterestStatus,
      this.userId,
      this.requirementType});

  Post.fromJson(dynamic json) {
    postId = json['post_id'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    postTitle = json['post_title'];
    postDescription = json['post_description'];
    propertyLocation = json['property_location'];
    propertyPrice = json['property_price'];
    propertySize = json['property_size'];
    postPic = json['post_pic'];
    postedBy = json['posted_by'];
    propertyPriceType = json['property_price_type'];
    propertySizeType = json['property_size_type'];
    postStatus = json['post_status'];
    postIssue = json['post_issue'];
    propertyCity = json['property_city'];
    userName = json['user_name'];
    userType = json['user_type'];
    companyName = json['company_name'];
    profilePic = json['profile_pic'];
    postViewsCount = json['post_views_count'];
    interestsCount = json['interests_count'];
    postCommentsCount = json['comments_count'];
    userInterestStatus = json['user_interest_status'] == "0" ? false : true;
    userId = json['user_id'];
    postsCount = json['posts_count'];
    promotionsCount = json['promotions_count'];
    requirementType = json['requirement_type'];
  }

  String? postId;
  String? createdOn;
  String? updatedOn;
  String? postTitle;
  String? postDescription;
  String? propertyLocation;
  String? propertyPrice;
  String? propertySize;
  String? postPic;
  String? postedBy;
  String? propertyPriceType;
  String? propertySizeType;
  String? postStatus;
  String? postIssue;
  String? propertyCity;
  String? userName;
  String? userType;
  String? companyName;
  String? profilePic;
  String? postViewsCount;
  String? interestsCount;
  String? postCommentsCount;
  bool? userInterestStatus;
  String? userId;
  String? postsCount;
  String? promotionsCount;
  String? requirementType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['post_id'] = postId;
    map['created_on'] = createdOn;
    map['updated_on'] = updatedOn;
    map['post_title'] = postTitle;
    map['post_description'] = postDescription;
    map['property_location'] = propertyLocation;
    map['property_price'] = propertyPrice;
    map['property_size'] = propertySize;
    map['post_pic'] = postPic;
    map['posted_by'] = postedBy;
    map['property_price_type'] = propertyPriceType;
    map['property_size_type'] = propertySizeType;
    map['post_status'] = postStatus;
    map['post_issue'] = postIssue;
    map['property_city'] = propertyCity;
    map['user_name'] = userName;
    map['company_name'] = companyName;
    map['user_type'] = userType;
    map['profile_pic'] = profilePic;
    map['post_views_count'] = postViewsCount;
    map['comments_count'] = postCommentsCount;
    map['user_id'] = userId;
    map['posts_count'] = postsCount;
    map['promotions_count'] = promotionsCount;
    map['requirement_type'] = requirementType;
    return map;
  }
}
