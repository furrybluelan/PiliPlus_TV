import 'dart:async';

import 'package:PiliPlus/models/pgc/info.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class BangumiPanel extends StatefulWidget {
  const BangumiPanel({
    super.key,
    required this.pages,
    this.cid,
    required this.changeFuc,
    required this.showEpisodes,
    required this.heroTag,
    this.newEp,
  });

  final List<EpisodeItem> pages;
  final int? cid;
  final Function changeFuc;
  final Function showEpisodes;
  final String heroTag;
  final dynamic newEp;

  @override
  State<BangumiPanel> createState() => _BangumiPanelState();
}

class _BangumiPanelState extends State<BangumiPanel> {
  late int currentIndex;
  final ScrollController listViewScrollCtr = ScrollController();
  dynamic userInfo;
  // 默认未开通
  int vipStatus = 0;
  late int cid;
  late final VideoDetailController videoDetailCtr;
  StreamSubscription? _listener;

  @override
  void initState() {
    super.initState();
    cid = widget.cid!;
    currentIndex = widget.pages.indexWhere((e) => e.cid == cid);
    scrollToIndex();
    userInfo = GStorage.userInfo.get('userInfoCache');
    if (userInfo != null) {
      vipStatus = userInfo.vipStatus;
    }
    videoDetailCtr = Get.find<VideoDetailController>(tag: widget.heroTag);

    _listener = videoDetailCtr.cid.listen((int p0) {
      cid = p0;
      currentIndex = widget.pages.indexWhere((EpisodeItem e) => e.cid == cid);
      if (!mounted) return;
      setState(() {});
      scrollToIndex();
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    listViewScrollCtr.dispose();
    super.dispose();
  }

  void scrollToIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listViewScrollCtr.animateTo(
        (currentIndex * 150.0).clamp(listViewScrollCtr.position.minScrollExtent,
            listViewScrollCtr.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('合集 '),
              Expanded(
                child: Text(
                  ' 正在播放：${widget.pages[currentIndex].longTitle}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 34,
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () => widget.showEpisodes(
                    null,
                    null,
                    widget.pages,
                    widget.pages[currentIndex].bvid,
                    widget.pages[currentIndex].aid,
                    cid,
                  ),
                  child: Text(
                    widget.newEp?['desc']?.contains('连载') == true
                        ? '连载中，更新至${Utils.isStringNumeric(widget.newEp['title']) ? '第${widget.newEp?['title']}话' : '${widget.newEp?['title']}'}'
                        : widget.newEp?['desc'],
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            controller: listViewScrollCtr,
            scrollDirection: Axis.horizontal,
            itemCount: widget.pages.length,
            itemExtent: 150,
            itemBuilder: (BuildContext context, int index) {
              final item = widget.pages[index];
              return Container(
                width: 150,
                margin: EdgeInsets.only(
                  right: index == widget.pages.length - 1 ? 0 : 10,
                ),
                child: Material(
                  color: theme.colorScheme.onInverseSurface,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      if (item.badge != null &&
                          item.badge == '会员' &&
                          vipStatus != 1) {
                        SmartDialog.showToast('需要大会员');
                      }
                      widget.changeFuc(
                        item.epId,
                        item.bvid,
                        item.cid,
                        item.aid,
                        item.cover,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              if (index == currentIndex) ...<Widget>[
                                Image.asset(
                                  'assets/images/live.png',
                                  color: theme.colorScheme.primary,
                                  height: 12,
                                  semanticLabel: "正在播放：",
                                ),
                                const SizedBox(width: 6)
                              ],
                              Expanded(
                                  child: Text(
                                item.title ?? '第${index + 1}话',
                                maxLines: (item.longTitle != null &&
                                        item.longTitle != '')
                                    ? 1
                                    : 2,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: index == currentIndex
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface),
                              )),
                              const SizedBox(width: 2),
                              if (item.badge != null) ...[
                                const Spacer(),
                                if (item.badge == '会员') ...[
                                  Image.asset(
                                    'assets/images/big-vip.png',
                                    height: 16,
                                    semanticLabel: "大会员",
                                  ),
                                ],
                                if (item.badge != '会员') ...[
                                  Text(
                                    item.badge!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ]
                            ],
                          ),
                          if (item.longTitle != null &&
                              item.longTitle != '') ...[
                            const SizedBox(height: 3),
                            Text(
                              item.longTitle!,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: index == currentIndex
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis,
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
