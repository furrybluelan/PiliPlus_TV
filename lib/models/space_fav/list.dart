import 'package:PiliPlus/models/space_fav/upper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'list.g.dart';

@JsonSerializable()
class SpaceFavItemModel {
  int? id;
  int? fid;
  int? mid;
  int? attr;
  @JsonKey(name: 'attr_desc')
  String? attrDesc;
  String? title;
  String? cover;
  Upper? upper;
  @JsonKey(name: 'cover_type')
  int? coverType;
  String? intro;
  int? ctime;
  int? mtime;
  int? state;
  @JsonKey(name: 'fav_state')
  int? favState;
  @JsonKey(name: 'media_count')
  int? mediaCount;
  @JsonKey(name: 'view_count')
  int? viewCount;
  int? vt;
  @JsonKey(name: 'is_top')
  bool? isTop;
  @JsonKey(name: 'recent_fav')
  dynamic recentFav;
  @JsonKey(name: 'play_switch')
  int? playSwitch;
  int? type;
  String? link;
  String? bvid;
  int? mediaId;
  int? count;
  int? isPublic;

  SpaceFavItemModel({
    this.mediaId,
    this.count,
    this.isPublic,
    this.id,
    this.fid,
    this.mid,
    this.attr,
    this.attrDesc,
    this.title,
    this.cover,
    this.upper,
    this.coverType,
    this.intro,
    this.ctime,
    this.mtime,
    this.state,
    this.favState,
    this.mediaCount,
    this.viewCount,
    this.vt,
    this.isTop,
    this.recentFav,
    this.playSwitch,
    this.type,
    this.link,
    this.bvid,
  });

  factory SpaceFavItemModel.fromJson(Map<String, dynamic> json) =>
      _$ListFromJson(json);

  Map<String, dynamic> toJson() => _$ListToJson(this);
}
