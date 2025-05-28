import 'package:PiliPlus/models/member_ss/archive.dart';
import 'package:PiliPlus/models/member_ss/stat.dart';

class MemberSsModel {
  List<MemberSsArchive>? archives;
  MemberSsMeta? meta;
  List<int>? recentAids;

  MemberSsModel({
    this.archives,
    this.meta,
    this.recentAids,
  });

  factory MemberSsModel.fromJson(Map<String, dynamic> json) => MemberSsModel(
        archives: json["archives"] == null
            ? null
            : List<MemberSsArchive>.from(
                json["archives"]!.map((x) => MemberSsArchive.fromJson(x))),
        meta: json["meta"] == null ? null : MemberSsMeta.fromJson(json["meta"]),
        recentAids: json["recent_aids"] == null
            ? null
            : List<int>.from(json["recent_aids"]!.map((x) => x)),
      );
}
