class Author {
  Author({
    this.mid,
    this.name,
    this.face,
  });
  String? mid;
  String? name;
  String? face;

  Author.fromJson(Map<String, dynamic> json) {
    mid = json["mid"];
    name = json["name"];
    face = json['face'];
  }
}
