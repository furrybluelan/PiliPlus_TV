// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaListResponse _$MediaListResponseFromJson(Map<String, dynamic> json) =>
    MediaListResponse(
      count: (json['count'] as num?)?.toInt(),
      list: (json['list'] as List<dynamic>?)
          ?.map((item) => SpaceFavItemModel.fromJson(item))
          .toList(),
      hasMore: json['has_more'] as bool?,
    );

Map<String, dynamic> _$MediaListResponseToJson(MediaListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'list': instance.list,
      'has_more': instance.hasMore,
    };
