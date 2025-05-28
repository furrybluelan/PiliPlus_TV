import 'package:PiliPlus/models/fav_article/item.dart';

class FavArticleData {
  List<FavArticleItemModel>? items;
  bool? hasMore;
  String? offset;

  FavArticleData({
    this.items,
    this.hasMore,
    this.offset,
  });

  factory FavArticleData.fromJson(Map<String, dynamic> json) => FavArticleData(
        items: (json['items'] as List<dynamic>?)
            ?.map(
                (e) => FavArticleItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: json['has_more'] as bool?,
        offset: json['offset'] as String?,
      );
}
