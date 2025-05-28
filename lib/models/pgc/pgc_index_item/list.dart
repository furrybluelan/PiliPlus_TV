class PgcIndexItemModel {
  String? badge;
  int? badgeType;
  String? cover;
  String? indexShow;
  int? isFinish;
  String? link;
  int? mediaId;
  String? order;
  String? orderType;
  String? score;
  int? seasonId;
  int? seasonStatus;
  int? seasonType;
  String? subTitle;
  String? title;
  String? titleIcon;

  PgcIndexItemModel({
    this.badge,
    this.badgeType,
    this.cover,
    this.indexShow,
    this.isFinish,
    this.link,
    this.mediaId,
    this.order,
    this.orderType,
    this.score,
    this.seasonId,
    this.seasonStatus,
    this.seasonType,
    this.subTitle,
    this.title,
    this.titleIcon,
  });

  factory PgcIndexItemModel.fromJson(Map<String, dynamic> json) =>
      PgcIndexItemModel(
        badge: json['badge'] as String?,
        badgeType: json['badge_type'] as int?,
        cover: json['cover'] as String?,
        indexShow: json['index_show'] as String?,
        isFinish: json['is_finish'] as int?,
        link: json['link'] as String?,
        mediaId: json['media_id'] as int?,
        order: json['order'] as String?,
        orderType: json['order_type'] as String?,
        score: json['score'] as String?,
        seasonId: json['season_id'] as int?,
        seasonStatus: json['season_status'] as int?,
        seasonType: json['season_type'] as int?,
        subTitle: json['subTitle'] as String?,
        title: json['title'] as String?,
        titleIcon: json['title_icon'] as String?,
      );
}
