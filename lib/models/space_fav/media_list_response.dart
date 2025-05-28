import 'package:PiliPlus/models/space_fav/list.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_list_response.g.dart';

@JsonSerializable()
class MediaListResponse {
  int? count;
  List<SpaceFavItemModel>? list;
  @JsonKey(name: 'has_more')
  bool? hasMore;

  MediaListResponse({this.count, this.list, this.hasMore});

  factory MediaListResponse.fromJson(Map<String, dynamic> json) {
    return _$MediaListResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MediaListResponseToJson(this);
}
