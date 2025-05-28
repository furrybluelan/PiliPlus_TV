// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceFavItemModel _$ListFromJson(Map<String, dynamic> json) =>
    SpaceFavItemModel(
      mediaId: (json['media_id'] as num?)?.toInt(),
      count: (json['count'] as num?)?.toInt(),
      isPublic: (json['is_public'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      fid: (json['fid'] as num?)?.toInt(),
      mid: (json['mid'] as num?)?.toInt(),
      attr: (json['attr'] as num?)?.toInt(),
      attrDesc: json['attr_desc'] as String?,
      title: json['title'] as String?,
      cover: json['cover'] as String?,
      upper: json['upper'] == null
          ? null
          : Upper.fromJson(json['upper'] as Map<String, dynamic>),
      coverType: (json['cover_type'] as num?)?.toInt(),
      intro: json['intro'] as String?,
      ctime: (json['ctime'] as num?)?.toInt(),
      mtime: (json['mtime'] as num?)?.toInt(),
      state: (json['state'] as num?)?.toInt(),
      favState: (json['fav_state'] as num?)?.toInt(),
      mediaCount: (json['media_count'] as num?)?.toInt(),
      viewCount: (json['view_count'] as num?)?.toInt(),
      vt: (json['vt'] as num?)?.toInt(),
      isTop: json['is_top'] as bool?,
      recentFav: json['recent_fav'],
      playSwitch: (json['play_switch'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      link: json['link'] as String?,
      bvid: json['bvid'] as String?,
    );

Map<String, dynamic> _$ListToJson(SpaceFavItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fid': instance.fid,
      'mid': instance.mid,
      'attr': instance.attr,
      'attr_desc': instance.attrDesc,
      'title': instance.title,
      'cover': instance.cover,
      'upper': instance.upper,
      'cover_type': instance.coverType,
      'intro': instance.intro,
      'ctime': instance.ctime,
      'mtime': instance.mtime,
      'state': instance.state,
      'fav_state': instance.favState,
      'media_count': instance.mediaCount,
      'view_count': instance.viewCount,
      'vt': instance.vt,
      'is_top': instance.isTop,
      'recent_fav': instance.recentFav,
      'play_switch': instance.playSwitch,
      'type': instance.type,
      'link': instance.link,
      'bvid': instance.bvid,
    };
