class TopicPubSearchItem {
  int? id;
  String? name;
  int? view;
  int? discuss;
  String? statDesc;
  String? description;
  bool? showInteractData;

  TopicPubSearchItem({
    this.id,
    this.name,
    this.view,
    this.discuss,
    this.statDesc,
    this.description,
    this.showInteractData,
  });

  factory TopicPubSearchItem.fromJson(Map<String, dynamic> json) =>
      TopicPubSearchItem(
        id: json['id'] as int?,
        name: json['name'] as String?,
        view: json['view'] as int?,
        discuss: json['discuss'] as int?,
        statDesc: json['stat_desc'] as String?,
        description: json['description'] as String?,
        showInteractData: json['show_interact_data'] as bool?,
      );
}
