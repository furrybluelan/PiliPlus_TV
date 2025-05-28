import 'dart:async';

import 'package:PiliPlus/grpc/bilibili/app/viewunite/pgcanymodel.pb.dart'
    show ViewPgcAny;
import 'package:PiliPlus/grpc/view.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/pgc/info.dart';
import 'package:PiliPlus/models/user/fav_folder.dart';
import 'package:PiliPlus/models/video_tag/data.dart';
import 'package:PiliPlus/pages/dynamics_repost/view.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/pages/video/introduction/ugc/controller.dart';
import 'package:PiliPlus/pages/video/pay_coins/view.dart';
import 'package:PiliPlus/pages/video/reply/controller.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_repeat.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class BangumiIntroController extends GetxController {
  // 视频bvid
  String bvid = Get.parameters['bvid'] ?? '';
  var seasonId = Get.parameters['seasonId'] != null
      ? int.tryParse(Get.parameters['seasonId']!)
      : null;
  var epId = Get.parameters['epId'] != null
      ? int.tryParse(Get.parameters['epId']!)
      : null;

  late dynamic type =
      Get.parameters['type'] == '1' || Get.parameters['type'] == '4'
          ? '追番'
          : '追剧';

  final BangumiInfoModel bangumiItem = Get.arguments['bangumiItem'];

  // 是否点赞
  RxBool hasLike = false.obs;
  // 投币数量
  final RxInt _coinNum = 0.obs;
  // 是否投币
  bool get hasCoin => _coinNum.value != 0;
  // 是否收藏
  RxBool hasFav = false.obs;

  List<VideoTagItem>? videoTags;

  List? favIds;
  Rx<FavFolderData> favFolderData = FavFolderData().obs;

  bool isLogin = Accounts.main.isLogin;
  int mid = Accounts.main.mid;

  late final enableQuickFav =
      GStorage.setting.get(SettingBoxKey.enableQuickFav, defaultValue: false);

  @override
  void onInit() {
    super.onInit();
    if (isLogin) {
      if (seasonId != null) {
        queryIsFollowed();
      }
      if (epId != null) {
        queryBangumiLikeCoinFav();
      }
    }
    queryVideoTags();
  }

  Future<void> queryVideoTags() async {
    var result = await UserHttp.videoTags(bvid: bvid);
    if (result['status']) {
      videoTags = result['data'];
    }
  }

  // 获取点赞/投币/收藏状态
  Future<void> queryBangumiLikeCoinFav() async {
    var result = await VideoHttp.bangumiLikeCoinFav(epId: epId);
    if (result['status']) {
      hasLike.value = result["data"]['like'] == 1;
      _coinNum.value = result["data"]['coin_number'];
      hasFav.value = result["data"]['favorite'] == 1;
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  // （取消）点赞
  Future<void> actionLikeVideo() async {
    var result = await VideoHttp.likeVideo(bvid: bvid, type: !hasLike.value);
    if (result['status']) {
      SmartDialog.showToast(!hasLike.value ? result['data']['toast'] : '取消赞');
      bangumiItem.stat!['likes'] =
          bangumiItem.stat!['likes'] + (!hasLike.value ? 1 : -1);
      hasLike.value = !hasLike.value;
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  Future<void> coinVideo(int coin, [bool selectLike = false]) async {
    var res = await VideoHttp.coinVideo(
      bvid: bvid,
      multiply: coin,
      selectLike: selectLike ? 1 : 0,
    );
    if (res['status']) {
      SmartDialog.showToast('投币成功');
      bangumiItem.stat!['coins'] = bangumiItem.stat!['coins'] + coin;
      if (selectLike && hasLike.value.not) {
        hasLike.value = true;
        bangumiItem.stat!['likes'] = bangumiItem.stat!['likes'] + 1;
      }
      _coinNum.value += coin;
      GlobalData().afterCoin(coin);
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // 投币
  void actionCoinVideo() {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }

    if (_coinNum.value >= 2) {
      SmartDialog.showToast('达到投币上限啦~');
      return;
    }

    if (GlobalData().coins != null && GlobalData().coins! < 1) {
      SmartDialog.showToast('硬币不足');
      return;
    }

    PayCoinsPage.toPayCoinsPage(
      onPayCoin: coinVideo,
      hasCoin: _coinNum.value == 1,
    );
  }

  // （取消）收藏 bangumi
  Future<void> actionFavVideo({type = 'choose'}) async {
    // 收藏至默认文件夹
    if (type == 'default') {
      SmartDialog.showLoading(msg: '请求中');
      queryVideoInFolder().then((res) async {
        if (res['status']) {
          int defaultFolderId = favFolderData.value.list!.first.id!;
          int favStatus = favFolderData.value.list!.first.favState!;
          var result = await VideoHttp.favVideo(
            aid: epId,
            type: 24,
            addIds: favStatus == 0 ? '$defaultFolderId' : '',
            delIds: favStatus == 1 ? '$defaultFolderId' : '',
          );
          SmartDialog.dismiss();
          if (result['status']) {
            // 重新获取收藏状态
            await Future.delayed(const Duration(milliseconds: 255));
            await queryBangumiLikeCoinFav();
            SmartDialog.showToast('✅ 快速收藏/取消收藏成功');
          } else {
            SmartDialog.showToast(result['msg']);
          }
        } else {
          SmartDialog.dismiss();
        }
      });
      return;
    }

    List<int?> addMediaIdsNew = [];
    List<int?> delMediaIdsNew = [];
    try {
      for (var i in favFolderData.value.list!.toList()) {
        bool isFaved = favIds?.contains(i.id) == true;
        if (i.favState == 1) {
          if (isFaved.not) {
            addMediaIdsNew.add(i.id);
          }
        } else {
          if (isFaved) {
            delMediaIdsNew.add(i.id);
          }
        }
      }
    } catch (_) {}
    var result = await VideoHttp.favVideo(
      aid: epId,
      type: 24,
      addIds: addMediaIdsNew.join(','),
      delIds: delMediaIdsNew.join(','),
    );
    if (result['status']) {
      SmartDialog.showToast('操作成功');
      Get.back();
      Future.delayed(const Duration(milliseconds: 255), () {
        queryBangumiLikeCoinFav();
      });
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  // 分享视频
  void actionShareVideo(context) {
    showDialog(
        context: context,
        builder: (_) {
          String videoUrl = '${HttpString.baseUrl}/bangumi/play/ep$epId';
          return AlertDialog(
            clipBehavior: Clip.hardEdge,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  dense: true,
                  title: const Text(
                    '复制链接',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    Utils.copyText(videoUrl);
                  },
                ),
                ListTile(
                  dense: true,
                  title: const Text(
                    '其它app打开',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    PageUtils.launchURL(videoUrl);
                  },
                ),
                ListTile(
                  dense: true,
                  title: const Text(
                    '分享视频',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    Utils.shareText(videoUrl);
                  },
                ),
                ListTile(
                  dense: true,
                  title: const Text(
                    '分享至动态',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    EpisodeItem? item = bangumiItem.episodes
                        ?.firstWhereOrNull((item) => item.epId == epId);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => RepostPanel(
                        rid: epId,
                        /**
                         *  1：番剧 // 4097
                            2：电影 // 4098
                            3：纪录片 // 4101
                            4：国创 // 4100
                            5：电视剧 // 4099
                            6：漫画
                            7：综艺 // 4099
                         */
                        dynType: switch (Get.parameters['type']) {
                          '1' => 4097,
                          '2' => 4098,
                          '3' => 4101,
                          '4' => 4100,
                          '5' || '7' => 4099,
                          _ => -1,
                        },
                        pic: bangumiItem.cover,
                        title:
                            '${bangumiItem.title}${item != null ? '\n${item.showTitle}' : ''}',
                        uname: '',
                      ),
                    );
                  },
                ),
                ListTile(
                  dense: true,
                  title: const Text(
                    '分享至消息',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    try {
                      EpisodeItem item = bangumiItem.episodes!
                          .firstWhere((item) => item.epId == epId);
                      final title = '${bangumiItem.title!} ${item.showTitle}';
                      PageUtils.pmShare(
                        context,
                        content: {
                          "id": epId!.toString(),
                          "title": title,
                          "url": item.shareUrl,
                          "headline": title,
                          "source": 16,
                          "thumb": item.cover,
                          "source_desc": switch (bangumiItem.type) {
                            1 => '番剧',
                            2 => '电影',
                            3 => '纪录片',
                            4 => '国创',
                            5 => '电视剧',
                            6 => '漫画',
                            7 => '综艺',
                            _ => null,
                          }
                        },
                      );
                    } catch (e) {
                      SmartDialog.showToast(e.toString());
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  // 选择文件夹
  void onChoose(bool checkValue, int index) {
    feedBack();
    List<FavFolderItemData> datalist = favFolderData.value.list!;
    datalist[index].favState = checkValue ? 1 : 0;
    datalist[index].mediaCount = checkValue
        ? datalist[index].mediaCount! + 1
        : datalist[index].mediaCount! - 1;
    favFolderData.value.list = datalist;
    favFolderData.refresh();
  }

  // 修改分P或番剧分集
  void changeSeasonOrbangu(epId, bvid, cid, aid, cover) {
    // 重新获取视频资源
    this.epId = epId;
    this.bvid = bvid;

    final videoDetailCtr =
        Get.find<VideoDetailController>(tag: Get.arguments['heroTag'])
          ..plPlayerController.pause()
          ..makeHeartBeat()
          ..onReset()
          ..epId = epId
          ..bvid = bvid
          ..cid.value = cid
          ..danmakuCid.value = cid
          ..queryVideoUrl();
    if (cover is String && cover.isNotEmpty) {
      videoDetailCtr.videoItem['pic'] = cover;
    }

    // 重新请求评论
    if (videoDetailCtr.showReply) {
      try {
        Get.find<VideoReplyController>(tag: Get.arguments['heroTag'])
          ..aid = aid
          ..onReload();
      } catch (_) {}
    }

    if (isLogin) {
      queryBangumiLikeCoinFav();
    }

    try {
      Get.find<VideoIntroController>(tag: Get.arguments['heroTag'])
        ..bvid = bvid
        ..lastPlayCid.value = cid
        ..queryVideoIntro()
        ..queryOnlineTotal();
    } catch (_) {}
  }

  // 追番
  Future<void> bangumiAdd() async {
    var result = await VideoHttp.bangumiAdd(seasonId: bangumiItem.seasonId);
    if (result['status']) {
      isFollowed.value = true;
      followStatus.value = 2;
    }
    SmartDialog.showToast(result['msg']);
  }

  // 取消追番
  Future<void> bangumiDel() async {
    var result = await VideoHttp.bangumiDel(seasonId: bangumiItem.seasonId);
    if (result['status']) {
      isFollowed.value = false;
    }
    SmartDialog.showToast(result['msg']);
  }

  Future<void> bangumiUpdate(status) async {
    var result = await VideoHttp.bangumiUpdate(
      seasonId: [bangumiItem.seasonId],
      status: status,
    );
    if (result['status']) {
      followStatus.value = status;
    }
    SmartDialog.showToast(result['msg']);
  }

  Future queryVideoInFolder() async {
    favIds = null;
    var result = await VideoHttp.videoInFolder(
      mid: mid,
      rid: epId, // bangumi
      type: 24, // bangumi
    );
    if (result['status']) {
      favFolderData.value = result['data'];
      favIds = favFolderData.value.list
          ?.where((item) => item.favState == 1)
          .map((item) => item.id)
          .toList();
    }
    return result;
  }

  bool prevPlay() {
    List episodes = bangumiItem.episodes!;
    VideoDetailController videoDetailCtr =
        Get.find<VideoDetailController>(tag: Get.arguments['heroTag']);
    int currentIndex =
        episodes.indexWhere((e) => e.cid == videoDetailCtr.cid.value);
    int prevIndex = currentIndex - 1;
    PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;
    if (prevIndex < 0) {
      if (playRepeat == PlayRepeat.listCycle) {
        prevIndex = episodes.length - 1;
      } else {
        return false;
      }
    }
    int epid = episodes[prevIndex].epId;
    int cid = episodes[prevIndex].cid;
    String bvid = episodes[prevIndex].bvid;
    int aid = episodes[prevIndex].aid;
    dynamic cover = episodes[prevIndex].cover;
    changeSeasonOrbangu(epid, bvid, cid, aid, cover);
    return true;
  }

  /// 列表循环或者顺序播放时，自动播放下一个；自动连播时，播放相关视频
  bool nextPlay() {
    try {
      List episodes = bangumiItem.episodes!;
      VideoDetailController videoDetailCtr =
          Get.find<VideoDetailController>(tag: Get.arguments['heroTag']);
      PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;

      int currentIndex =
          episodes.indexWhere((e) => e.cid == videoDetailCtr.cid.value);
      int nextIndex = currentIndex + 1;
      // 列表循环
      if (nextIndex >= episodes.length) {
        if (playRepeat == PlayRepeat.listCycle) {
          nextIndex = 0;
        } else if (playRepeat == PlayRepeat.autoPlayRelated) {
          return false;
        } else {
          return false;
        }
      }
      int epid = episodes[nextIndex].epId;
      int cid = episodes[nextIndex].cid;
      String bvid = episodes[nextIndex].bvid;
      int aid = episodes[nextIndex].aid;
      dynamic cover = episodes[nextIndex].cover;
      changeSeasonOrbangu(epid, bvid, cid, aid, cover);
      return true;
    } catch (_) {
      return false;
    }
  }

  // 一键三连
  Future<void> actionOneThree() async {
    feedBack();
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (hasLike.value && hasCoin && hasFav.value) {
      // 已点赞、投币、收藏
      SmartDialog.showToast('已三连');
      return;
    }
    var result = await VideoHttp.triple(epId: epId, seasonId: seasonId);
    if (result['status']) {
      hasLike.value = result["data"]["like"] == 1;
      if (result["data"]["coin"] == 1) {
        _coinNum.value = 2;
        GlobalData().afterCoin(2);
      }
      hasFav.value = result["data"]["favorite"] == 1;
      SmartDialog.showToast('三连成功');
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  RxBool isFollowed = false.obs;
  RxInt followStatus = (-1).obs;

  Future<void> queryIsFollowed() async {
    // try {
    //   dynamic result = await Request().get(
    //     'https://www.bilibili.com/bangumi/play/ss$seasonId',
    //   );
    //   dom.Document document = html_parser.parse(result.data);
    //   dom.Element? scriptElement =
    //       document.querySelector('script#__NEXT_DATA__');
    //   if (scriptElement != null) {
    //     dynamic scriptContent = jsonDecode(scriptElement.text);
    //     isFollowed.value =
    //         scriptContent['props']['pageProps']['followState']['isFollowed'];
    //     followStatus.value =
    //         scriptContent['props']['pageProps']['followState']['followStatus'];
    //   }
    // } catch (_) {}
    ViewGrpc.view(bvid: bvid).then((res) {
      if (res.isSuccess) {
        ViewPgcAny view = ViewPgcAny.fromBuffer(res.data.supplement.value);
        isFollowed.value = view.ogvData.userStatus.follow == 1;
        followStatus.value = view.ogvData.userStatus.followStatus;
      }
    });
  }

  // 收藏
  void showFavBottomSheet(BuildContext context, {type = 'tap'}) {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    // 快速收藏 &
    // 点按 收藏至默认文件夹
    // 长按选择文件夹
    if (enableQuickFav) {
      if (type == 'tap') {
        actionFavVideo(type: 'default');
      } else {
        PageUtils.showFavBottomSheet(context: context, ctr: this);
      }
    } else if (type != 'longPress') {
      PageUtils.showFavBottomSheet(context: context, ctr: this);
    }
  }
}
