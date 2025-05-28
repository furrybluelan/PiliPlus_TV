import 'package:PiliPlus/models/pgc/pgc_timeline/episode.dart';

class Result {
  String? date;
  int? dateTs;
  int? dayOfWeek;
  List<Episode>? episodes;
  int? isToday;

  Result({
    this.date,
    this.dateTs,
    this.dayOfWeek,
    this.episodes,
    this.isToday,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        date: json['date'] as String?,
        dateTs: json['date_ts'] as int?,
        dayOfWeek: json['day_of_week'] as int?,
        episodes: (json['episodes'] as List<dynamic>?)
            ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
            .toList(),
        isToday: json['is_today'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'date_ts': dateTs,
        'day_of_week': dayOfWeek,
        'episodes': episodes?.map((e) => e.toJson()).toList(),
        'is_today': isToday,
      };
}
