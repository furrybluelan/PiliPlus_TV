// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favourite2 _$Favourite2FromJson(Map<String, dynamic> json) => Favourite2(
      count: (json['count'] as num?)?.toInt(),
      item: (json['item'] as List<dynamic>?)
          ?.map((e) => SpaceFavItemModel.fromJson(e))
          .toList(),
    );

Map<String, dynamic> _$Favourite2ToJson(Favourite2 instance) =>
    <String, dynamic>{
      'count': instance.count,
      'item': instance.item?.map((e) => e.toJson()).toList(),
    };
