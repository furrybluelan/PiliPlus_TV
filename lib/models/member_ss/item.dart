import 'package:PiliPlus/models/member_ss/page.dart';
import 'package:PiliPlus/models/member_ss/season.dart';

class MemberSsData {
  MemberSsPage? page;
  List<MemberSsModel>? seasonsList;
  List<MemberSsModel>? seriesList;

  MemberSsData({
    this.page,
    this.seasonsList,
    this.seriesList,
  });

  factory MemberSsData.fromJson(Map<String, dynamic> json) => MemberSsData(
        page: json["page"] == null ? null : MemberSsPage.fromJson(json["page"]),
        seasonsList: json["seasons_list"] == null
            ? null
            : List<MemberSsModel>.from(
                json["seasons_list"]!.map((x) => MemberSsModel.fromJson(x))),
        seriesList: json["series_list"] == null
            ? null
            : List<MemberSsModel>.from(
                json["series_list"]!.map((x) => MemberSsModel.fromJson(x))),
      );
}
