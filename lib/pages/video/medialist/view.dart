import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/video/later.dart';
import 'package:PiliPlus/pages/common/common_collapse_slide_page.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MediaListPanel extends CommonCollapseSlidePage {
  const MediaListPanel({
    super.key,
    required this.mediaList,
    this.changeMediaList,
    this.panelTitle,
    required this.getBvId,
    required this.loadMoreMedia,
    required this.count,
    required this.desc,
    required this.onReverse,
    required this.loadPrevious,
    this.onDelete,
  });

  final List<MediaVideoItemModel> mediaList;
  final Function? changeMediaList;
  final String? panelTitle;
  final Function getBvId;
  final VoidCallback loadMoreMedia;
  final int? count;
  final bool desc;
  final VoidCallback onReverse;
  final RefreshCallback? loadPrevious;
  final ValueChanged<int>? onDelete;

  @override
  State<MediaListPanel> createState() => _MediaListPanelState();
}

class _MediaListPanelState
    extends CommonCollapseSlidePageState<MediaListPanel> {
  final _scrollController = ItemScrollController();
  late RxBool desc;

  @override
  void initState() {
    super.initState();
    desc = widget.desc.obs;
  }

  @override
  void init() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        int index = widget.mediaList
            .indexWhere((item) => item.bvid == widget.getBvId());
        if (index > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              _scrollController.jumpTo(index: index);
            } catch (_) {}
          });
        }
        setState(() {
          isInit = false;
        });
      }
    });
  }

  @override
  Widget buildPage(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          AppBar(
            toolbarHeight: 45,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Text(widget.panelTitle ?? '稍后再看'),
            actions: [
              Obx(
                () => mediumButton(
                  tooltip: desc.value ? '顺序播放' : '倒序播放',
                  icon: desc.value
                      ? MdiIcons.sortAscending
                      : MdiIcons.sortDescending,
                  onPressed: () {
                    widget.onReverse();
                    desc.value = !desc.value;
                  },
                ),
              ),
              mediumButton(
                tooltip: '关闭',
                icon: Icons.close,
                onPressed: Get.back,
              ),
              const SizedBox(width: 14),
            ],
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          Expanded(
            child: enableSlide ? slideList(theme) : buildList(theme),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildList(ThemeData theme) {
    return widget.loadPrevious != null
        ? refreshIndicator(
            onRefresh: widget.loadPrevious!,
            child: _buildList(theme),
          )
        : _buildList(theme);
  }

  Widget _buildList(ThemeData theme) => Obx(
        () {
          final showDelBtn =
              widget.onDelete != null && widget.mediaList.length > 1;
          return ScrollablePositionedList.separated(
            itemScrollController: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.mediaList.length,
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.paddingOf(context).bottom + 80,
            ),
            itemBuilder: ((context, index) {
              var item = widget.mediaList[index];
              if (index == widget.mediaList.length - 1 &&
                  (widget.count == null ||
                      widget.mediaList.length < widget.count!)) {
                widget.loadMoreMedia();
              }
              return SizedBox(
                // key: ValueKey('${item.aid}'),
                height: 98,
                child: InkWell(
                  onTap: () async {
                    if (item.type != 2) {
                      SmartDialog.showToast('不支持播放该类型视频');
                      return;
                    }
                    Get.back();
                    String bvid = item.bvid!;
                    int? aid = item.id;
                    String cover = item.cover ?? '';
                    final int cid =
                        item.cid ?? await SearchHttp.ab2c(aid: aid, bvid: bvid);
                    widget.changeMediaList?.call(bvid, cid, aid, cover);
                  },
                  onLongPress: () => imageSaveDialog(
                    title: item.title,
                    cover: item.cover,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: StyleString.aspectRatio,
                              child: LayoutBuilder(
                                builder: (context, boxConstraints) {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      NetworkImgLayer(
                                        src: item.cover,
                                        width: boxConstraints.maxWidth,
                                        height: boxConstraints.maxHeight,
                                      ),
                                      PBadge(
                                        text: Utils.timeFormat(item.duration!),
                                        right: 6.0,
                                        bottom: 6.0,
                                        type: PBadgeType.gray,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title!,
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: item.bvid == widget.getBvId()
                                          ? FontWeight.bold
                                          : null,
                                      color: item.bvid == widget.getBvId()
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.upper!.name!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      StatView(
                                        context: context,
                                        theme: 'gray',
                                        value: Utils.numFormat(
                                            item.cntInfo!['play']!),
                                      ),
                                      const SizedBox(width: 8),
                                      StatDanMu(
                                        context: context,
                                        theme: 'gray',
                                        value: Utils.numFormat(
                                            item.cntInfo!['danmaku']!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showDelBtn && item.bvid != widget.getBvId())
                        Positioned(
                          right: 12,
                          bottom: -6,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => showConfirmDialog(
                              context: context,
                              title: '确定移除该视频？',
                              onConfirm: () => widget.onDelete!(index),
                            ),
                            onLongPress: () => widget.onDelete!(index),
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: Icon(
                                Icons.clear,
                                size: 18,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            separatorBuilder: (context, index) => const SizedBox(height: 2),
          );
        },
      );
}
