import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/space_fav/datum.dart';
import 'package:PiliPlus/models/space_fav/list.dart';
import 'package:PiliPlus/pages/common/common_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class MemberFavoriteCtr extends CommonDataController {
  MemberFavoriteCtr({
    required this.mid,
  });

  final int mid;

  Rx<SpaceFavData> first = SpaceFavData().obs;
  Rx<SpaceFavData> second = SpaceFavData().obs;

  RxBool firstEnd = true.obs;
  RxBool secondEnd = true.obs;

  late int page = 2;
  late int page1 = 2;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> onRefresh() {
    page = 2;
    page1 = 2;
    return super.onRefresh();
  }

  @override
  bool customHandleResponse(bool isRefresh, Success response) {
    try {
      List<SpaceFavData> res = response.response;
      first.value = res.first;
      second.value = res[1];

      firstEnd.value = (res.first.mediaListResponse?.count ?? -1) <=
          (res.first.mediaListResponse?.list?.length ?? -1);
      secondEnd.value = (res[1].mediaListResponse?.count ?? -1) <=
          (res[1].mediaListResponse?.list?.length ?? -1);
    } catch (e) {
      debugPrint(e.toString());
    }
    loadingState.value = response;
    return true;
  }

  Future<void> userfavFolder() async {
    var res = await Request().get(Api.userFavFolder, queryParameters: {
      'pn': page,
      'ps': 20,
      'up_mid': mid,
    });
    if (res.data['code'] == 0) {
      page++;
      firstEnd.value = res.data['data']['has_more'] == false;
      if (res.data['data'] != null) {
        List<SpaceFavItemModel> list =
            (res.data['data']['list'] as List<dynamic>?)
                    ?.map((item) => SpaceFavItemModel.fromJson(item))
                    .toList() ??
                <SpaceFavItemModel>[];
        first.value.mediaListResponse?.list?.addAll(list);
        first.refresh();
      } else {
        firstEnd.value = true;
      }
    } else {
      SmartDialog.showToast(res.data['message'] ?? '账号未登录');
    }
  }

  Future<void> userSubFolder() async {
    var res = await Request().get(Api.userSubFolder, queryParameters: {
      'up_mid': mid,
      'ps': 20,
      'pn': page1,
      'platform': 'web',
    });
    if (res.data['code'] == 0) {
      page++;
      secondEnd.value = res.data['data']['has_more'] == false;
      if (res.data['data'] != null) {
        List<SpaceFavItemModel> list =
            (res.data['data']['list'] as List<dynamic>?)
                    ?.map((item) => SpaceFavItemModel.fromJson(item))
                    .toList() ??
                <SpaceFavItemModel>[];
        second.value.mediaListResponse?.list?.addAll(list);
        second.refresh();
      } else {
        secondEnd.value = true;
      }
    } else {
      SmartDialog.showToast(res.data['message'] ?? '账号未登录');
    }
  }

  @override
  Future<LoadingState> customGetData() => MemberHttp.spaceFav(mid: mid);
}
