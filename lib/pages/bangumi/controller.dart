import 'package:PiliPlus/http/bangumi.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BangumiController extends CommonListController<
    List<BangumiListItemModel>?, BangumiListItemModel> {
  BangumiController({required this.tabType});
  final HomeTabType tabType;

  int? mid;
  late final RxBool isLogin;
  late final showPgcTimeline =
      tabType == HomeTabType.bangumi && GStorage.showPgcTimeline;

  @override
  void onInit() {
    super.onInit();
    mid = Accounts.main.mid;
    isLogin = (mid != 0).obs;

    queryData();
    queryBangumiFollow();
    if (showPgcTimeline) {
      queryPgcTimeline();
    }
    if (isLogin.value) {
      followController = ScrollController();
    }
  }

  @override
  Future<void> onRefresh() {
    if (isLogin.value) {
      followPage = 1;
      followEnd = false;
    }
    queryBangumiFollow();
    if (showPgcTimeline) {
      queryPgcTimeline();
    }
    return super.onRefresh();
  }

  // follow
  late int followPage = 1;
  late RxInt followCount = (-1).obs;
  late bool followLoading = false;
  late bool followEnd = false;
  late Rx<LoadingState<List<BangumiListItemModel>?>> followState =
      LoadingState<List<BangumiListItemModel>?>.loading().obs;
  ScrollController? followController;

  // timeline
  late Rx<LoadingState<List<Result>?>> timelineState =
      LoadingState<List<Result>?>.loading().obs;

  Future<void> queryPgcTimeline() async {
    final res = await BangumiHttp.pgcTimeline(types: 1, before: 6, after: 6);
    timelineState.value = res;
  }

  // 我的订阅
  Future<void> queryBangumiFollow([bool isRefresh = true]) async {
    if (isLogin.value.not || followLoading || (isRefresh.not && followEnd)) {
      return;
    }
    followLoading = true;
    dynamic res = await BangumiHttp.bangumiFollowList(
      mid: mid,
      type: tabType == HomeTabType.bangumi ? 1 : 2,
      pn: followPage,
    );

    if (res is Success) {
      BangumiListDataModel data = res.response;
      List<BangumiListItemModel>? list = data.list;
      followCount.value = data.total ?? -1;
      if (data.hasNext == 0) {
        followEnd = true;
      }

      if (list.isNullOrEmpty) {
        followEnd = true;
        if (isRefresh) {
          followState.value = Success(list);
        }
        followLoading = false;
        return;
      }

      if (isRefresh) {
        if (list!.length >= followCount.value) {
          followEnd = true;
        }
        followState.value = Success(list);
        followController?.animToTop();
      } else if (followState.value is Success) {
        final currentList = followState.value.data!..addAll(list!);
        if (currentList.length >= followCount.value) {
          followEnd = true;
        }
        followState.refresh();
      }
      followPage++;
    } else if (isRefresh) {
      followState.value = res;
    }
    followLoading = false;
  }

  @override
  Future<LoadingState<List<BangumiListItemModel>?>> customGetData() =>
      BangumiHttp.bangumiList(
        page: page,
        indexType: tabType == HomeTabType.cinema ? 102 : null, // TODO: sort
      );

  @override
  void onClose() {
    followController?.dispose();
    super.onClose();
  }
}
