import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show MainListReply, ReplyInfo, SubjectControl, Mode;
import 'package:PiliPlus/grpc/bilibili/pagination.pb.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/reply.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/video/reply_new/view.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/reply_utils.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';

abstract class ReplyController<R> extends CommonListController<R, ReplyInfo> {
  RxInt count = (-1).obs;

  Rx<ReplySortType> sortType = ReplySortType.time.obs;

  late final savedReplies = {};

  late final bool isLogin = Accounts.main.isLogin;

  Int64? upMid;
  Int64? cursorNext;
  FeedPaginationReply? paginationReply;
  late Rx<Mode> mode = Mode.MAIN_LIST_HOT.obs;
  late bool hasUpTop = false;

  @override
  bool? get hasFooter => true;

  late final antiGoodsReply = GStorage.antiGoodsReply;

  // comment antifraud
  late final _enableCommAntifraud = GStorage.enableCommAntifraud;
  late final _biliSendCommAntifraud = GStorage.biliSendCommAntifraud;
  bool get enableCommAntifraud =>
      _enableCommAntifraud || _biliSendCommAntifraud;
  dynamic get sourceId;

  @override
  void onInit() {
    super.onInit();
    int defaultReplySortIndex = GStorage.setting
        .get(SettingBoxKey.replySortType, defaultValue: 1) as int;
    if (defaultReplySortIndex == 2) {
      GStorage.setting.put(SettingBoxKey.replySortType, 0);
      defaultReplySortIndex = 0;
    }
    sortType.value = ReplySortType.values[defaultReplySortIndex];
    if (sortType.value == ReplySortType.time) {
      mode.value = Mode.MAIN_LIST_TIME;
    }
  }

  @override
  void checkIsEnd(int length) {
    if (count.value != -1 && length >= count.value) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success response) {
    MainListReply data = response.response;
    cursorNext = data.cursor.next;
    paginationReply = data.paginationReply;
    count.value = data.subjectControl.count.toInt();
    if (isRefresh) {
      upMid ??= data.subjectControl.upMid;
      hasUpTop = data.hasUpTop();
      if (data.hasUpTop()) {
        data.replies.insert(0, data.upTop);
      }
    }
    isEnd = data.cursor.isEnd;
    return false;
  }

  @override
  Future<void> onRefresh() {
    cursorNext = null;
    paginationReply = null;
    return super.onRefresh();
  }

  // 排序搜索评论
  void queryBySort() {
    EasyThrottle.throttle('queryBySort', const Duration(seconds: 1), () {
      feedBack();
      switch (sortType.value) {
        case ReplySortType.time:
          sortType.value = ReplySortType.like;
          mode.value = Mode.MAIN_LIST_HOT;
          break;
        case ReplySortType.like:
          sortType.value = ReplySortType.time;
          mode.value = Mode.MAIN_LIST_TIME;
          break;
      }
      onReload();
    });
  }

  void onReply(
    BuildContext context, {
    int? oid,
    ReplyInfo? replyItem,
    int index = 0,
    int? replyType,
  }) {
    assert(replyItem != null || (oid != null && replyType != null));
    String? hint;
    try {
      if (loadingState.value is Success) {
        SubjectControl subjectControl =
            (loadingState.value as Success).response.subjectControl;
        if (subjectControl.hasSwitcherType() &&
            subjectControl.switcherType != 1 &&
            subjectControl.hasRootText()) {
          hint = subjectControl.rootText;
        }
      }
    } catch (_) {}
    dynamic key = oid ?? replyItem!.oid + replyItem.id;
    Navigator.of(context)
        .push(
      GetDialogRoute(
        pageBuilder: (buildContext, animation, secondaryAnimation) {
          return ReplyPage(
            oid: oid ?? replyItem!.oid.toInt(),
            root: oid != null ? 0 : replyItem!.id.toInt(),
            parent: oid != null ? 0 : replyItem!.id.toInt(),
            replyType: replyItem?.type.toInt() ?? replyType!,
            replyItem: replyItem,
            initialValue: savedReplies[key],
            onSave: (reply) {
              savedReplies[key] = reply;
            },
            hint: hint,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.linear;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    )
        .then(
      (res) {
        if (res != null) {
          savedReplies[key] = null;
          ReplyInfo replyInfo = RequestUtils.replyCast(res);
          if (loadingState.value is Success) {
            List<ReplyInfo>? list = (loadingState.value as Success).response;
            if (list == null) {
              loadingState.value = Success([replyInfo]);
            } else {
              if (oid != null) {
                list.insert(hasUpTop ? 1 : 0, replyInfo);
              } else {
                list[index]
                  ..count += 1
                  ..replies.add(replyInfo);
              }
              loadingState.refresh();
            }
          } else {
            loadingState.value = Success([replyInfo]);
          }
          count.value += 1;

          // check reply
          if (enableCommAntifraud && context.mounted) {
            ReplyUtils.onCheckReply(
              context: context,
              replyInfo: replyInfo,
              biliSendCommAntifraud: _biliSendCommAntifraud,
              sourceId: sourceId,
              isManual: false,
            );
          }
        }
      },
    );
  }

  void onRemove(int index, int? subIndex) {
    List<ReplyInfo> list = (loadingState.value as Success).response;
    if (subIndex == null) {
      list.removeAt(index);
    } else {
      list[index]
        ..count -= 1
        ..replies.removeAt(subIndex);
    }
    count.value -= 1;
    loadingState.refresh();
  }

  void onCheckReply(BuildContext context, ReplyInfo replyInfo) {
    ReplyUtils.onCheckReply(
      context: context,
      replyInfo: replyInfo,
      biliSendCommAntifraud: _biliSendCommAntifraud,
      sourceId: sourceId,
      isManual: true,
    );
  }

  Future<void> onToggleTop(index, oid, int type, bool isUpTop, int rpid) async {
    final res = await ReplyHttp.replyTop(
      oid: oid,
      type: type,
      rpid: rpid,
      isUpTop: isUpTop,
    );
    if (res['status']) {
      List<ReplyInfo> list = (loadingState.value as Success).response;
      list[index].replyControl.isUpTop = !isUpTop;
      if (!isUpTop && index != 0) {
        list[0].replyControl.isUpTop = false;
        final item = list.removeAt(index);
        list.insert(0, item);
      }
      loadingState.refresh();
      SmartDialog.showToast('${isUpTop ? '取消' : ''}置顶成功');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }
}
