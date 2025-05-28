import 'package:PiliPlus/models/member_ss/stat.dart';

class MemberSsArchive {
  int? aid;
  String? bvid;
  int? ctime;
  int? duration;
  bool? enableVt;
  bool? interactiveVideo;
  String? pic;
  int? playbackPosition;
  int? pubdate;
  MemberSsStat? stat;
  int? state;
  String? title;
  int? ugcPay;
  String? vtDisplay;
  int? isLessonVideo;
  MemberSsArchive({
    this.aid,
    this.bvid,
    this.ctime,
    this.duration,
    this.enableVt,
    this.interactiveVideo,
    this.pic,
    this.playbackPosition,
    this.pubdate,
    this.stat,
    this.state,
    this.title,
    this.ugcPay,
    this.vtDisplay,
    this.isLessonVideo,
  });

  factory MemberSsArchive.fromJson(Map<String, dynamic> json) =>
      MemberSsArchive(
        aid: json["aid"],
        bvid: json["bvid"],
        ctime: json["ctime"],
        duration: json["duration"],
        enableVt: json["enable_vt"],
        interactiveVideo: json["interactive_video"],
        pic: json["pic"],
        playbackPosition: json["playback_position"],
        pubdate: json["pubdate"],
        stat: json["stat"] == null ? null : MemberSsStat.fromJson(json["stat"]),
        state: json["state"],
        title: json["title"],
        ugcPay: json["ugc_pay"],
        vtDisplay: json["vt_display"],
        isLessonVideo: json["is_lesson_video"],
      );
}
