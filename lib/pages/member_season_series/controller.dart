import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/member_ss/item.dart';
import 'package:PiliPlus/models/member_ss/season.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';

class SeasonSeriesController
    extends CommonListController<MemberSsData, MemberSsModel> {
  SeasonSeriesController(this.mid);
  final int mid;
  int? count;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<MemberSsModel>? getDataList(MemberSsData response) {
    count = response.page?.total;
    return (response.seasonsList ?? <MemberSsModel>[]) +
        (response.seriesList ?? <MemberSsModel>[]);
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<MemberSsData>> customGetData() =>
      MemberHttp.seasonSeriesList(
        mid: mid,
        pn: page,
      );
}
