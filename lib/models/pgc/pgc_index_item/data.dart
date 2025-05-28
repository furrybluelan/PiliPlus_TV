import 'package:PiliPlus/models/pgc/pgc_index_item/list.dart';

class PgcIndexItemData {
  int? hasNext;
  List<PgcIndexItemModel>? list;
  int? num;
  int? size;
  int? total;

  PgcIndexItemData({this.hasNext, this.list, this.num, this.size, this.total});

  factory PgcIndexItemData.fromJson(Map<String, dynamic> json) =>
      PgcIndexItemData(
        hasNext: json['has_next'] as int?,
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => PgcIndexItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        num: json['num'] as int?,
        size: json['size'] as int?,
        total: json['total'] as int?,
      );
}
