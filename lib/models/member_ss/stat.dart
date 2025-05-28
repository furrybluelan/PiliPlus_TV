class MemberSsStat {
  int? view;
  int? vt;

  MemberSsStat({
    this.view,
    this.vt,
  });

  factory MemberSsStat.fromJson(Map<String, dynamic> json) => MemberSsStat(
        view: json["view"],
        vt: json["vt"],
      );
}

class MemberSsMeta {
  int? category;
  String? cover;
  String? description;
  int? mid;
  String? name;
  int? ptime;
  int? total;
  dynamic seasonId;
  dynamic seriesId;

  MemberSsMeta({
    this.category,
    this.cover,
    this.description,
    this.mid,
    this.name,
    this.ptime,
    this.total,
    this.seasonId,
    this.seriesId,
  });

  factory MemberSsMeta.fromJson(Map<String, dynamic> json) => MemberSsMeta(
        category: json["category"],
        cover: json["cover"],
        description: json["description"],
        mid: json["mid"],
        name: json["name"],
        ptime: json["ptime"],
        total: json["total"],
        seasonId: json["season_id"],
        seriesId: json["series_id"],
      );
}
