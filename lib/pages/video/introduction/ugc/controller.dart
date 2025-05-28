import 'dart:async';

import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/user/fav_folder.dart';
import 'package:PiliPlus/models/video/ai.dart';
import 'package:PiliPlus/models/video_detail_res.dart';
import 'package:PiliPlus/models/video_tag/data.dart';
import 'package:PiliPlus/pages/dynamics_repost/view.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/pages/video/pay_coins/view.dart';
import 'package:PiliPlus/pages/video/related/controller.dart';
import 'package:PiliPlus/pages/video/reply/controller.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_repeat.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class VideoIntroController extends GetxController {
  // 视频bvid
  late String bvid;

  // 是否预渲染 骨架屏
  bool preRender = false;

  // 视频详情 上个页面传入
  Map videoItem = {};
  late final RxMap staffRelations = {}.obs;

  // 请求状态
  RxBool isLoading = false.obs;

  // 视频详情 请求返回
  Rx<VideoDetailData> videoDetail = VideoDetailData().obs;

  // up主粉丝数
  RxMap<String, dynamic> userStat = RxMap<String, dynamic>({'follower': '-'});

  List<VideoTagItem>? videoTags;

  // 是否点赞
  RxBool hasLike = false.obs;
  // 是否点踩
  RxBool hasDislike = false.obs;
  // 投币数量
  final RxInt _coinNum = 0.obs;
  // 是否投币
  bool get hasCoin => _coinNum.value != 0;
  // 是否收藏
  RxBool hasFav = false.obs;
  // 是否稍后再看
  RxBool hasLater = false.obs;
  bool isLogin = false;
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  Set? favIds;
  // 关注状态 默认未关注
  RxMap followStatus = {}.obs;

  RxInt lastPlayCid = 0.obs;
  dynamic userInfo;

  // 同时观看
  bool isShowOnlineTotal = false;
  RxString total = '1'.obs;
  Timer? timer;
  String heroTag = '';
  late ModelResult modelResult;
  RxMap<String, dynamic> queryVideoIntroData =
      RxMap<String, dynamic>({"status": true});

  ExpandableController? expandableCtr;

  late final showArgueMsg = GStorage.showArgueMsg;
  late final enableAi =
      GStorage.setting.get(SettingBoxKey.enableAi, defaultValue: false);
  late final enableQuickFav =
      GStorage.setting.get(SettingBoxKey.enableQuickFav, defaultValue: false);

  @override
  void onInit() {
    super.onInit();
    userInfo = GStorage.userInfo.get('userInfoCache');
    try {
      if (heroTag.isEmpty) {
        heroTag = Get.arguments['heroTag'];
      }
      bvid = Get.parameters['bvid']!;
    } catch (_) {}
    if (Get.arguments.isNotEmpty) {
      if (Get.arguments.containsKey('videoItem')) {
        preRender = true;
        var args = Get.arguments['videoItem'];
        var keys = Get.arguments.keys.toList();
        try {
          if (args.pic != null && args.pic != '') {
            videoItem['pic'] = args.pic;
          } else if (args.cover != null && args.cover != '') {
            videoItem['pic'] = args.cover;
          }
        } catch (_) {}
        if (args.title is String) {
          videoItem['title'] = args.title;
        } else {
          String str = '';
          for (Map map in args.title) {
            str += map['text'];
          }
          videoItem['title'] = str;
        }
        videoItem['stat'] = keys.contains('stat') ? args.stat : null;
        videoItem['pubdate'] = keys.contains('pubdate') ? args.pubdate : null;
        videoItem['owner'] = keys.contains('owner') ? args.owner : null;
      }
    }
    isLogin = userInfo != null;
    lastPlayCid.value = int.parse(Get.parameters['cid']!);
    isShowOnlineTotal = GStorage.setting
        .get(SettingBoxKey.enableOnlineTotal, defaultValue: false);
    startTimer();
    queryVideoIntro();
  }

  // 获取视频简介&分p
  Future<void> queryVideoIntro() async {
    queryVideoTags();
    var result = await VideoHttp.videoIntro(bvid: bvid);
    if (result['status']) {
      VideoDetailData data = result['data'];
      if (videoDetail.value.ugcSeason?.id == data.ugcSeason?.id) {
        // keep reversed season
        data.ugcSeason = videoDetail.value.ugcSeason;
      }
      if (videoDetail.value.cid == data.cid) {
        // keep reversed pages
        data
          ..pages = videoDetail.value.pages
          ..isPageReversed = videoDetail.value.isPageReversed;
      }
      videoDetail.value = data;
      videoItem['staff'] = data.staff;
      try {
        final videoDetailController =
            Get.find<VideoDetailController>(tag: heroTag);
        if (videoDetailController.videoItem['pic'] == null ||
            videoDetailController.videoItem['pic'] == '' ||
            (videoDetailController.videoUrl.isNullOrEmpty &&
                videoDetailController.isQuerying.not)) {
          videoDetailController.videoItem['pic'] = data.pic;
        }
        if (videoDetailController.showReply) {
          try {
            final videoReplyController =
                Get.find<VideoReplyController>(tag: heroTag);
            videoReplyController.count.value = data.stat?.reply ?? 0;
          } catch (_) {}
        }
      } catch (_) {}
      if (videoDetail.value.pages != null &&
          videoDetail.value.pages!.isNotEmpty &&
          lastPlayCid.value == 0) {
        lastPlayCid.value = videoDetail.value.pages!.first.cid!;
      }
      queryUserStat();
    } else {
      SmartDialog.showToast(
          "${result['code']} ${result['msg']} ${result['data']}");
    }
    queryVideoIntroData.addAll(result);
    if (isLogin) {
      queryAllStatus();
      queryFollowStatus();
    }
  }

  Future<void> queryVideoTags() async {
    videoTags = null;
    var result = await UserHttp.videoTags(bvid: bvid);
    if (result['status']) {
      videoTags = result['data'];
    }
  }

  // 获取up主粉丝数
  Future<void> queryUserStat() async {
    if (videoItem['staff']?.isNotEmpty == true) {
      Request().get(
        Api.relations,
        queryParameters: {
          'fids': (videoItem['staff'] as List<Staff>)
              .map((item) => item.mid)
              .join(',')
        },
      ).then((res) {
        if (res.data['code'] == 0) {
          staffRelations.addAll({
            'status': true,
            if (res.data['data'] != null) ...res.data['data'],
          });
        }
      });
    } else {
      if (videoDetail.value.owner == null) {
        return;
      }
      var result =
          await MemberHttp.memberCardInfo(mid: videoDetail.value.owner!.mid!);
      if (result['status']) {
        userStat.addAll(result['data']);
      }
    }
  }

  Future<void> queryAllStatus() async {
    var result = await VideoHttp.videoRelation(bvid: bvid);
    if (result['status']) {
      var data = result['data'];
      hasLike.value = data['like'];
      hasDislike.value = data['dislike'];
      _coinNum.value = data['coin'];
      hasFav.value = data['favorite'];
    }
  }

  // 一键三连
  Future<void> actionOneThree() async {
    feedBack();
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (hasLike.value && hasCoin && hasFav.value) {
      // 已点赞、投币、收藏
      SmartDialog.showToast('已三连');
      return;
    }
    var result = await VideoHttp.oneThree(bvid: bvid);
    if (result['status']) {
      hasLike.value = result["data"]["like"];
      if (result["data"]["coin"]) {
        _coinNum.value = 2;
        GlobalData().afterCoin(2);
      }
      hasFav.value = result["data"]["fav"];
      SmartDialog.showToast('三连成功');
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  // （取消）点赞
  Future<void> actionLikeVideo() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (videoDetail.value.stat?.like == null) {
      return;
    }
    var result = await VideoHttp.likeVideo(bvid: bvid, type: !hasLike.value);
    if (result['status']) {
      if (!hasLike.value) {
        SmartDialog.showToast(result['data']['toast']);
        hasLike.value = true;
        hasDislike.value = false;
        videoDetail.value.stat!.like = videoDetail.value.stat!.like! + 1;
      } else if (hasLike.value) {
        SmartDialog.showToast('取消赞');
        hasLike.value = false;
        videoDetail.value.stat!.like = videoDetail.value.stat!.like! - 1;
      }
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  Future<void> actionDislikeVideo() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    var result =
        await VideoHttp.dislikeVideo(bvid: bvid, type: !hasDislike.value);
    if (result['status']) {
      if (!hasDislike.value) {
        SmartDialog.showToast('点踩成功');
        hasDislike.value = true;
        hasLike.value = false;
      } else {
        SmartDialog.showToast('取消踩');
        hasDislike.value = false;
      }
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  Future<void> viewLater() async {
    var res = await (hasLater.value
        ? UserHttp.toViewDel(aids: [IdUtils.bv2av(bvid)])
        : await UserHttp.toViewLater(bvid: bvid));
    if (res['status']) hasLater.value = !hasLater.value;
    SmartDialog.showToast(res['msg']);
  }

  Future<void> coinVideo(int coin, [bool selectLike = false]) async {
    if (videoDetail.value.stat?.coin == null) {
      // not init
      return;
    }
    var res = await VideoHttp.coinVideo(
      bvid: bvid,
      multiply: coin,
      selectLike: selectLike ? 1 : 0,
    );
    if (res['status']) {
      SmartDialog.showToast('投币成功');
      _coinNum.value += coin;
      GlobalData().afterCoin(coin);
      videoDetail.value.stat!.coin = videoDetail.value.stat!.coin! + coin;
      if (selectLike && hasLike.value.not) {
        hasLike.value = true;
        videoDetail.value.stat!.like = videoDetail.value.stat!.like! + 1;
      }
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // 投币
  Future<void> actionCoinVideo() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }

    int copyright =
        (queryVideoIntroData['data'] as VideoDetailData?)?.copyright ?? 1;
    if ((copyright != 1 && _coinNum.value >= 1) || _coinNum.value >= 2) {
      SmartDialog.showToast('达到投币上限啦~');
      return;
    }

    if (GlobalData().coins != null && GlobalData().coins! < 1) {
      SmartDialog.showToast('硬币不足');
      return;
    }

    PayCoinsPage.toPayCoinsPage(
      onPayCoin: coinVideo,
      copyright: copyright,
      hasCoin: _coinNum.value == 1,
    );
  }

  // （取消）收藏
  Future<void> actionFavVideo({type = 'choose'}) async {
    // 收藏至默认文件夹
    if (type == 'default') {
      SmartDialog.showLoading(msg: '请求中');
      queryVideoInFolder().then((res) async {
        if (res['status']) {
          int defaultFolderId = favFolderData.value.list!.first.id!;
          bool notInDefFolder = favFolderData.value.list!.first.favState! == 0;
          var result = await VideoHttp.favVideo(
            aid: IdUtils.bv2av(bvid),
            addIds: notInDefFolder ? '$defaultFolderId' : '',
            delIds: !notInDefFolder ? '$defaultFolderId' : '',
          );
          SmartDialog.dismiss();
          if (result['status']) {
            hasFav.value = !hasFav.value || (hasFav.value && notInDefFolder);
            // 重新获取收藏状态
            // await queryHasFavVideo();
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
    } catch (e) {
      debugPrint(e.toString());
    }
    SmartDialog.showLoading(msg: '请求中');
    var result = await VideoHttp.favVideo(
      aid: IdUtils.bv2av(bvid),
      addIds: addMediaIdsNew.join(','),
      delIds: delMediaIdsNew.join(','),
    );
    SmartDialog.dismiss();
    if (result['status']) {
      Get.back();
      hasFav.value =
          addMediaIdsNew.isNotEmpty || favIds?.length != delMediaIdsNew.length;
      SmartDialog.showToast('操作成功');
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  // 分享视频
  void actionShareVideo(context) {
    showDialog(
        context: context,
        builder: (_) {
          String videoUrl = '${HttpString.baseUrl}/video/$bvid';
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
                    Utils.shareText('${videoDetail.value.title} '
                        'UP主: ${videoDetail.value.owner!.name!}'
                        ' - $videoUrl');
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
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => RepostPanel(
                        rid: videoDetail.value.aid,
                        dynType: 8,
                        pic: videoDetail.value.pic,
                        title: videoDetail.value.title,
                        uname: videoDetail.value.owner?.name,
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
                      PageUtils.pmShare(
                        context,
                        content: {
                          "id": videoDetail.value.aid!.toString(),
                          "title": videoDetail.value.title!,
                          "headline": videoDetail.value.title!,
                          "source": 5,
                          "thumb": videoDetail.value.pic!,
                          "author": videoDetail.value.owner!.name!,
                          "author_id": videoDetail.value.owner!.mid!.toString(),
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

  Future queryVideoInFolder() async {
    favIds = null;
    var result = await VideoHttp.videoInFolder(
        mid: userInfo.mid, rid: IdUtils.bv2av(bvid));
    if (result['status']) {
      favFolderData.value = result['data'];
      favIds = favFolderData.value.list
          ?.where((item) => item.favState == 1)
          .map((item) => item.id)
          .toSet();
    }
    return result;
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

  // 查询关注状态
  Future<void> queryFollowStatus() async {
    if (videoDetail.value.owner == null) {
      return;
    }
    var result = await UserHttp.hasFollow(videoDetail.value.owner!.mid!);
    if (result['status']) {
      Map data = result['data'];
      if (data['special'] == 1) data['attribute'] = -10;
      followStatus.value = data;
    }
  }

  // 关注/取关up
  Future<void> actionRelationMod(BuildContext context) async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    int? mid = videoDetail.value.owner?.mid;
    if (mid == null) {
      return;
    }
    int attr = followStatus['attribute'] ?? 0;
    if (attr == 128) {
      dynamic res = await VideoHttp.relationMod(
        mid: mid,
        act: 6,
        reSrc: 11,
      );
      if (res['status']) {
        GStorage.removeBlackMid(mid);
        followStatus['attribute'] = 0;
      }
      return;
    } else {
      RequestUtils.actionRelationMod(
        context: context,
        mid: mid,
        isFollow: attr != 0,
        followStatus: followStatus,
        callback: (attribute) {
          followStatus['attribute'] = attribute;
          Future.delayed(const Duration(milliseconds: 500), () {
            queryFollowStatus();
          });
        },
      );
    }
  }

  // 修改分P或番剧分集
  bool changeSeasonOrbangu(epid, bvid, cid, aid, cover, [isStein]) {
    // 重新获取视频资源
    final videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);

    if (videoDetailCtr.isPlayAll) {
      if (videoDetailCtr.mediaList.indexWhere((item) => item.bvid == bvid) ==
          -1) {
        PageUtils.toVideoPage(
          'bvid=$bvid&cid=$cid',
          arguments: {
            if (cover != null) 'pic': cover,
            'heroTag': Utils.makeHeroTag(bvid),
          },
        );
        return false;
      }
    }

    videoDetailCtr
      ..plPlayerController.pause()
      ..makeHeartBeat()
      ..updateMediaListHistory(aid)
      ..onReset(isStein)
      ..bvid = bvid
      ..oid.value = aid ?? IdUtils.bv2av(bvid)
      ..cid.value = cid
      ..danmakuCid.value = cid
      ..queryVideoUrl();

    if (this.bvid != bvid) {
      if (cover is String && cover.isNotEmpty) {
        videoDetailCtr.videoItem['pic'] = cover;
      }

      // 重新请求相关视频
      if (videoDetailCtr.plPlayerController.showRelatedVideo) {
        try {
          Get.find<RelatedController>(tag: heroTag)
            ..bvid = bvid
            ..queryData();
        } catch (_) {}
      }

      // 重新请求评论
      if (videoDetailCtr.showReply) {
        try {
          Get.find<VideoReplyController>(tag: heroTag)
            ..aid = aid
            ..onReload();
        } catch (_) {}
      }

      hasLater.value = false;
      this.bvid = bvid;
      queryVideoIntro();
    }

    lastPlayCid.value = cid;
    queryOnlineTotal();
    return true;
  }

  void startTimer() {
    if (isShowOnlineTotal) {
      queryOnlineTotal();
      timer ??= Timer.periodic(const Duration(seconds: 10), (Timer timer) {
        queryOnlineTotal();
      });
    }
  }

  void canelTimer() {
    timer?.cancel();
    timer = null;
  }

  // 查看同时在看人数
  Future<void> queryOnlineTotal() async {
    if (isShowOnlineTotal.not) {
      return;
    }
    dynamic result = await VideoHttp.onlineTotal(
      aid: IdUtils.bv2av(bvid),
      bvid: bvid,
      cid: lastPlayCid.value,
    );
    if (result['status']) {
      total.value = result['data'];
    }
  }

  @override
  void onClose() {
    canelTimer();
    expandableCtr?.dispose();
    expandableCtr = null;
    super.onClose();
  }

  /// 播放上一个
  bool prevPlay([bool skipPages = false]) {
    final List episodes = [];
    bool isPages = false;

    final videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);

    if (skipPages.not && (videoDetail.value.pages?.length ?? 0) > 1) {
      isPages = true;
      final List<Part> pages = videoDetail.value.pages!;
      episodes.addAll(pages);
    } else if (videoDetailCtr.isPlayAll) {
      episodes.addAll(videoDetailCtr.mediaList);
    } else if (videoDetail.value.ugcSeason != null) {
      final UgcSeason ugcSeason = videoDetail.value.ugcSeason!;
      final List<SectionItem> sections = ugcSeason.sections!;
      for (int i = 0; i < sections.length; i++) {
        final List<EpisodeItem> episodesList = sections[i].episodes!;
        episodes.addAll(episodesList);
      }
    }

    final int currentIndex = episodes.indexWhere((e) =>
        e.cid ==
        (skipPages
            ? videoDetail.value.isPageReversed == true
                ? videoDetail.value.pages!.last.cid
                : videoDetail.value.pages!.first.cid
            : lastPlayCid.value));
    int prevIndex = currentIndex - 1;
    final PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;

    // 列表循环
    if (prevIndex < 0) {
      if (isPages &&
          (videoDetailCtr.isPlayAll || videoDetail.value.ugcSeason != null)) {
        return prevPlay(true);
      }
      if (playRepeat == PlayRepeat.listCycle) {
        prevIndex = episodes.length - 1;
      } else {
        return false;
      }
    }
    final int cid = episodes[prevIndex].cid!;
    final String rBvid = isPages ? bvid : episodes[prevIndex].bvid;
    final int rAid = isPages ? IdUtils.bv2av(bvid) : episodes[prevIndex].aid!;
    changeSeasonOrbangu(null, rBvid, cid, rAid, null);
    return true;
  }

  /// 列表循环或者顺序播放时，自动播放下一个
  bool nextPlay([bool skipPages = false]) {
    try {
      final List episodes = [];
      bool isPages = false;
      final videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);

      // part -> playall -> season
      if (skipPages.not && (videoDetail.value.pages?.length ?? 0) > 1) {
        isPages = true;
        final List<Part> pages = videoDetail.value.pages!;
        episodes.addAll(pages);
      } else if (videoDetailCtr.isPlayAll) {
        episodes.addAll(videoDetailCtr.mediaList);
      } else if (videoDetail.value.ugcSeason != null) {
        final UgcSeason ugcSeason = videoDetail.value.ugcSeason!;
        final List<SectionItem> sections = ugcSeason.sections!;
        for (int i = 0; i < sections.length; i++) {
          final List<EpisodeItem> episodesList = sections[i].episodes!;
          episodes.addAll(episodesList);
        }
      }

      final PlayRepeat playRepeat =
          videoDetailCtr.plPlayerController.playRepeat;

      if (episodes.isEmpty) {
        if (playRepeat == PlayRepeat.autoPlayRelated &&
            videoDetailCtr.plPlayerController.showRelatedVideo) {
          return playRelated();
        }
        return false;
      }

      final int currentIndex = episodes.indexWhere((e) =>
          e.cid ==
          (skipPages
              ? videoDetail.value.isPageReversed == true
                  ? videoDetail.value.pages!.last.cid
                  : videoDetail.value.pages!.first.cid
              : videoDetailCtr.cid.value));

      int nextIndex = currentIndex + 1;

      if (isPages.not &&
          videoDetailCtr.isPlayAll &&
          currentIndex == episodes.length - 2) {
        videoDetailCtr.getMediaList();
      }

      // 列表循环
      if (nextIndex >= episodes.length) {
        if (isPages &&
            (videoDetailCtr.isPlayAll || videoDetail.value.ugcSeason != null)) {
          return nextPlay(true);
        }

        if (playRepeat == PlayRepeat.listCycle) {
          nextIndex = 0;
        } else if (playRepeat == PlayRepeat.autoPlayRelated &&
            videoDetailCtr.plPlayerController.showRelatedVideo) {
          return playRelated();
        } else {
          return false;
        }
      }

      int cid = episodes[nextIndex].cid!;

      while (cid == -1) {
        SmartDialog.showToast('当前视频暂不支持播放，自动跳过');
        nextIndex++;
        if (nextIndex >= episodes.length) {
          return false;
        }
        cid = episodes[nextIndex].cid!;
      }

      final String rBvid = isPages ? bvid : episodes[nextIndex].bvid;
      final int rAid = isPages ? IdUtils.bv2av(bvid) : episodes[nextIndex].aid!;
      changeSeasonOrbangu(null, rBvid, cid, rAid, null);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool playRelated() {
    RelatedController relatedCtr;
    if (Get.isRegistered<RelatedController>(tag: heroTag)) {
      relatedCtr = Get.find<RelatedController>(tag: heroTag);
    } else {
      relatedCtr = Get.put(RelatedController(false), tag: heroTag)
        ..queryData().whenComplete(() {
          playRelated();
        });
      return false;
    }

    if (relatedCtr.loadingState.value is! Success) {
      return false;
    }

    if (relatedCtr.loadingState.value.data.isNullOrEmpty) {
      SmartDialog.showToast('暂无相关视频，停止连播');
      return false;
    }

    final firstItem = relatedCtr.loadingState.value.data!.first;
    try {
      if (firstItem.cid != null) {
        changeSeasonOrbangu(
          null,
          firstItem.bvid,
          firstItem.cid,
          firstItem.aid,
          firstItem.pic,
        );
      } else {
        SearchHttp.ab2c(aid: firstItem.aid, bvid: firstItem.bvid).then(
          (cid) => changeSeasonOrbangu(
            null,
            firstItem.bvid,
            cid,
            firstItem.aid,
            firstItem.pic,
          ),
        );
      }
    } catch (err) {
      SmartDialog.showToast(err.toString());
    }
    return true;
  }

  // ai总结
  Future aiConclusion() async {
    SmartDialog.showLoading(msg: '正在获取AI总结');
    final res = await VideoHttp.aiConclusion(
      bvid: bvid,
      cid: lastPlayCid.value,
      upMid: videoDetail.value.owner?.mid,
    );
    SmartDialog.dismiss();
    if (res['status']) {
      modelResult = res['data'].modelResult;
    } else {
      SmartDialog.showToast("当前视频可能暂不支持AI视频总结");
    }
    return res;
  }

  // 收藏
  void showFavBottomSheet(BuildContext context, {type = 'tap'}) {
    if (userInfo == null) {
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
