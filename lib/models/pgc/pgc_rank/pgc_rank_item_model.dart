import 'package:PiliPlus/models/pgc/pgc_rank/badge_info.dart';
import 'package:PiliPlus/models/pgc/pgc_rank/icon_font.dart';
import 'package:PiliPlus/models/pgc/pgc_rank/new_ep.dart';
import 'package:PiliPlus/models/pgc/pgc_rank/stat.dart';

class PgcRankItemModel {
  String? badge;
  BadgeInfo? badgeInfo;
  int? badgeType;
  String? cover;
  String? desc;
  bool? enableVt;
  IconFont? iconFont;
  NewEp? newEp;
  int? rank;
  String? rating;
  int? seasonId;
  String? ssHorizontalCover;
  Stat? stat;
  String? title;
  String? url;

  PgcRankItemModel({
    this.badge,
    this.badgeInfo,
    this.badgeType,
    this.cover,
    this.desc,
    this.enableVt,
    this.iconFont,
    this.newEp,
    this.rank,
    this.rating,
    this.seasonId,
    this.ssHorizontalCover,
    this.stat,
    this.title,
    this.url,
  });

  factory PgcRankItemModel.fromJson(Map<String, dynamic> json) =>
      PgcRankItemModel(
        badge: json['badge'] as String?,
        badgeInfo: json['badge_info'] == null
            ? null
            : BadgeInfo.fromJson(json['badge_info'] as Map<String, dynamic>),
        badgeType: json['badge_type'] as int?,
        cover: json['cover'] as String?,
        desc: json['desc'] as String?,
        enableVt: json['enable_vt'] as bool?,
        iconFont: json['icon_font'] == null
            ? null
            : IconFont.fromJson(json['icon_font'] as Map<String, dynamic>),
        newEp: json['new_ep'] == null
            ? null
            : NewEp.fromJson(json['new_ep'] as Map<String, dynamic>),
        rank: json['rank'] as int?,
        rating: json['rating'] as String?,
        seasonId: json['season_id'] as int?,
        ssHorizontalCover: json['ss_horizontal_cover'] as String?,
        stat: json['stat'] == null
            ? null
            : Stat.fromJson(json['stat'] as Map<String, dynamic>),
        title: json['title'] as String?,
        url: json['url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'badge': badge,
        'badge_info': badgeInfo?.toJson(),
        'badge_type': badgeType,
        'cover': cover,
        'desc': desc,
        'enable_vt': enableVt,
        'icon_font': iconFont?.toJson(),
        'new_ep': newEp?.toJson(),
        'rank': rank,
        'rating': rating,
        'season_id': seasonId,
        'ss_horizontal_cover': ssHorizontalCover,
        'stat': stat?.toJson(),
        'title': title,
        'url': url,
      };
}
