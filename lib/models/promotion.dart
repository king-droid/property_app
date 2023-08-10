class Promotion {
  Promotion({
    this.promotionId,
    this.createdOn,
    this.updatedOn,
    this.promotionTitle,
    this.promotionDescription,
    this.promotionPic,
    this.postedBy,
    this.promotionStatus,
    this.promotionIssue,
    this.promotionCity,
    this.userName,
    this.profilePic,
    this.promotionViewsCount,
    this.interestsCount,
    this.postsCount,
    this.promotionsCount,
    this.userInterestStatus,
    this.companyName,
    this.userId,
  });

  Promotion.fromJson(dynamic json) {
    promotionId = json['promotion_id'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    promotionTitle = json['promotion_title'];
    promotionDescription = json['promotion_description'];
    promotionPic = json['promotion_pic'];
    postedBy = json['posted_by'];
    promotionStatus = json['promotion_status'];
    promotionIssue = json['promotion_issue'];
    promotionCity = json['promotion_city'];
    userName = json['user_name'];
    profilePic = json['profile_pic'];
    promotionViewsCount = json['promotion_views_count'];
    interestsCount = json['interests_count'];
    promotionCommentsCount = json['comments_count'];
    userInterestStatus = json['user_interest_status'] == "0" ? false : true;
    companyName = json['company_name'];
    postsCount = json['posts_count'];
    promotionsCount = json['promotions_count'];
    userId = json['user_id'];
  }

  String? promotionId;
  String? createdOn;
  String? updatedOn;
  String? promotionTitle;
  String? promotionDescription;
  String? promotionPic;
  String? postedBy;
  String? promotionStatus;
  String? promotionIssue;
  String? promotionCity;
  String? userName;
  String? profilePic;
  String? promotionViewsCount;
  String? interestsCount;
  String? promotionCommentsCount;
  bool? userInterestStatus;
  String? companyName;
  String? postsCount;
  String? promotionsCount;
  String? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['promotion_id'] = promotionId;
    map['created_on'] = createdOn;
    map['updated_on'] = updatedOn;
    map['promotion_title'] = promotionTitle;
    map['promotion_description'] = promotionDescription;
    map['promotion_pic'] = promotionPic;
    map['posted_by'] = postedBy;
    map['promotion_status'] = promotionStatus;
    map['promotion_issue'] = promotionIssue;
    map['promotion_city'] = promotionCity;
    map['user_name'] = userName;
    map['profile_pic'] = profilePic;
    map['promotion_views_count'] = promotionViewsCount;
    map['comments_count'] = promotionCommentsCount;
    map['company_name'] = companyName;
    map['posts_count'] = postsCount;
    map['promotions_count'] = promotionsCount;
    map['user_id'] = userId;
    return map;
  }
}
