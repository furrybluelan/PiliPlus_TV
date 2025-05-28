import 'package:PiliPlus/http/bangumi.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/pgc/pgc_index/condition.dart';
import 'package:PiliPlus/models/pgc/pgc_index_item/data.dart';
import 'package:PiliPlus/models/pgc/pgc_index_item/list.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class PgcIndexController
    extends CommonListController<PgcIndexItemData, PgcIndexItemModel> {
  PgcIndexController(this.indexType);
  int? indexType;
  Rx<LoadingState<PgcIndexCondition>> conditionState =
      LoadingState<PgcIndexCondition>.loading().obs;

  late final RxBool isExpand = false.obs;

  RxMap<String, dynamic> indexParams = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getPgcIndexCondition();
  }

  Future<void> getPgcIndexCondition() async {
    dynamic res = await BangumiHttp.pgcIndexCondition(
      seasonType: indexType == null ? 1 : null,
      type: 0,
      indexType: indexType,
    );
    if (res is Success) {
      PgcIndexCondition data = res.response;
      if (data.order?.isNotEmpty == true) {
        indexParams['order'] = data.order!.first.field;
      }
      if (data.filter?.isNotEmpty == true) {
        for (Filter item in data.filter!) {
          indexParams['${item.field}'] = item.values?.firstOrNull?.keyword;
        }
      }
      queryData();
    }
    conditionState.value = res;
  }

  @override
  Future<LoadingState<PgcIndexItemData>> customGetData() =>
      BangumiHttp.pgcIndexResult(
        page: page,
        params: indexParams,
        seasonType: indexType == null ? 1 : null,
        type: 0,
        indexType: indexType,
      );

  @override
  List<PgcIndexItemModel>? getDataList(PgcIndexItemData response) {
    if (response.hasNext == null || response.hasNext == 0) {
      isEnd = true;
    }
    return response.list;
  }
}
