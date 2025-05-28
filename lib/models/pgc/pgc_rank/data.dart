import 'package:PiliPlus/models/pgc/pgc_rank/pgc_rank_item_model.dart';

class Data {
  List<PgcRankItemModel>? list;
  String? note;
  int? seasonType;

  Data({this.list, this.note, this.seasonType});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => PgcRankItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        note: json['note'] as String?,
        seasonType: json['season_type'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'list': list?.map((e) => e.toJson()).toList(),
        'note': note,
        'season_type': seasonType,
      };
}
