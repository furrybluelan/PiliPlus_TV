class MemberSsPage {
  int? pageNum;
  int? pageSize;
  int? total;

  MemberSsPage({
    this.pageNum,
    this.pageSize,
    this.total,
  });

  factory MemberSsPage.fromJson(Map<String, dynamic> json) => MemberSsPage(
        pageNum: json["page_num"],
        pageSize: json["page_size"],
        total: json["total"],
      );
}
