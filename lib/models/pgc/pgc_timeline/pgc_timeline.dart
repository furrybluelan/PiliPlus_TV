import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

class PgcTimeline {
  int? code;
  String? message;
  List<Result>? result;

  PgcTimeline({this.code, this.message, this.result});

  factory PgcTimeline.fromJson(Map<String, dynamic> json) => PgcTimeline(
        code: json['code'] as int?,
        message: json['message'] as String?,
        result: (json['result'] as List<dynamic>?)
            ?.map((e) => Result.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'result': result?.map((e) => e.toJson()).toList(),
      };
}
