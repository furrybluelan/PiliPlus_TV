// 转发
import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/dynamics/widgets/additional_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/blocked_item.dart';
import 'package:PiliPlus/pages/dynamics/widgets/content_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/live_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/live_panel_sub.dart';
import 'package:PiliPlus/pages/dynamics/widgets/live_rcmd_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/video_panel.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

Widget module(
  ThemeData theme,
  bool isSave,
  DynamicItemModel item,
  BuildContext context,
  String? source,
  Function(List<String>, int)? callback, {
  floor = 1,
}) {
  switch (item.type) {
    // 图文
    case 'DYNAMIC_TYPE_DRAW':
    // 文章
    case 'DYNAMIC_TYPE_ARTICLE':
    case 'DYNAMIC_TYPE_WORD':
      return const SizedBox.shrink();
    // 视频
    case 'DYNAMIC_TYPE_AV':
      return videoSeasonWidget(
          theme, isSave, source, item, context, 'archive', callback,
          floor: floor);
    // 转发
    case 'DYNAMIC_TYPE_FORWARD':
      final orig = item.orig!;
      final isNoneMajor =
          orig.modules.moduleDynamic?.major?.type == 'MAJOR_TYPE_NONE';
      late final isNormalAuth =
          orig.modules.moduleAuthor!.type == 'AUTHOR_TYPE_NORMAL';
      return InkWell(
        onTap:
            isNoneMajor ? null : () => PageUtils.pushDynDetail(orig, floor + 1),
        onLongPress: isNoneMajor
            ? null
            : () {
                late String? title, cover;
                late var origMajor = orig.modules.moduleDynamic?.major;
                late var major = item.modules.moduleDynamic?.major;
                switch (orig.type) {
                  case 'DYNAMIC_TYPE_AV':
                    title = origMajor?.archive?.title;
                    cover = origMajor?.archive?.cover;
                    break;
                  case 'DYNAMIC_TYPE_UGC_SEASON':
                    title = origMajor?.ugcSeason?.title;
                    cover = origMajor?.ugcSeason?.cover;
                    break;
                  case 'DYNAMIC_TYPE_PGC' || 'DYNAMIC_TYPE_PGC_UNION':
                    title = origMajor?.pgc?.title;
                    cover = origMajor?.pgc?.cover;
                    break;
                  case 'DYNAMIC_TYPE_LIVE_RCMD':
                    title = major?.liveRcmd?.title;
                    cover = major?.liveRcmd?.cover;
                    break;
                  case 'DYNAMIC_TYPE_LIVE':
                    title = major?.live?.title;
                    cover = major?.live?.cover;
                    break;
                  default:
                    return;
                }
                imageSaveDialog(
                  title: title,
                  cover: cover,
                );
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          color: theme.dividerColor.withValues(alpha: 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (orig.type != 'DYNAMIC_TYPE_NONE') ...[
                Row(
                  children: [
                    GestureDetector(
                      onTap: isNormalAuth
                          ? () => Get.toNamed(
                                '/member?mid=${orig.modules.moduleAuthor!.mid}',
                                arguments: {
                                  'face': orig.modules.moduleAuthor!.face
                                },
                              )
                          : null,
                      child: Text(
                        '${isNormalAuth ? '@' : ''}${orig.modules.moduleAuthor!.name}',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Utils.dateFormat(orig.modules.moduleAuthor!.pubTs),
                      style: TextStyle(
                          color: theme.colorScheme.outline,
                          fontSize: theme.textTheme.labelSmall!.fontSize),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                content(theme, isSave, context, orig, source, callback,
                    floor: floor + 1),
              ],
              module(theme, isSave, orig, context, source, callback,
                  floor: floor + 1),
              if (orig.modules.moduleDynamic?.additional != null)
                addWidget(theme, orig, context, floor: floor + 1),
              if (orig.modules.moduleDynamic?.major?.blocked != null)
                blockedItem(theme, orig.modules.moduleDynamic!.major!.blocked!),
            ],
          ),
        ),
      );
    // 直播
    case 'DYNAMIC_TYPE_LIVE_RCMD':
      return liveRcmdPanel(theme, source, item, context, floor: floor);
    // 直播
    case 'DYNAMIC_TYPE_LIVE':
      return livePanel(theme, source, item, context, floor: floor);
    // 合集
    case 'DYNAMIC_TYPE_UGC_SEASON':
      return videoSeasonWidget(
          theme, isSave, source, item, context, 'ugcSeason', callback);
    case 'DYNAMIC_TYPE_PGC':
      return videoSeasonWidget(
          theme, isSave, source, item, context, 'pgc', callback,
          floor: floor);
    case 'DYNAMIC_TYPE_PGC_UNION':
      return videoSeasonWidget(
          theme, isSave, source, item, context, 'pgc', callback,
          floor: floor);
    case 'DYNAMIC_TYPE_NONE':
      return Row(
        spacing: 4,
        children: [
          const Icon(FontAwesomeIcons.ghost, size: 14),
          Text(item.modules.moduleDynamic!.major!.none!.tips!)
        ],
      );
    // 课堂
    case 'DYNAMIC_TYPE_COURSES_SEASON':
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: floor == 1
              ? const EdgeInsets.symmetric(horizontal: 12)
              : EdgeInsets.zero,
          child: Text(
            "课堂：${item.modules.moduleDynamic!.major!.courses!['title']}",
          ),
        ),
      );
    // 活动
    case 'DYNAMIC_TYPE_COMMON_SQUARE':
      return Material(
        color: floor == 1
            ? theme.dividerColor.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        shape: floor == 1
            ? null
            : const RoundedRectangleBorder(borderRadius: StyleString.mdRadius),
        child: InkWell(
          borderRadius: floor == 1 ? null : StyleString.mdRadius,
          onTap: () {
            try {
              String url =
                  item.modules.moduleDynamic!.major!.common!['jump_url'];
              if (url.contains('bangumi/play') &&
                  PageUtils.viewPgcFromUri(url)) {
                return;
              }
              PageUtils.handleWebview(url, inApp: true);
            } catch (_) {}
          },
          child: Padding(
            padding:
                const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 10),
            child: Row(
              children: [
                NetworkImgLayer(
                  radius: 8,
                  width: 45,
                  height: 45,
                  src: item.modules.moduleDynamic!.major!.common!['cover'],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.modules.moduleDynamic!.major!.common!['title'],
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.modules.moduleDynamic!.major!.common!['desc'],
                        style: TextStyle(
                          color: theme.colorScheme.outline,
                          fontSize: theme.textTheme.labelMedium!.fontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    case 'DYNAMIC_TYPE_MUSIC':
      final Map music = item.modules.moduleDynamic!.major!.music!;
      return InkWell(
        onTap: () => PageUtils.handleWebview("https:${music['jump_url']}"),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 10),
          color: theme.dividerColor.withValues(alpha: 0.08),
          child: Row(
            children: [
              NetworkImgLayer(
                radius: 8,
                width: 45,
                height: 45,
                src: music['cover'],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    music['title'],
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    music['label'],
                    style: TextStyle(
                      color: theme.colorScheme.outline,
                      fontSize: theme.textTheme.labelMedium!.fontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        ),
      );
    case 'DYNAMIC_TYPE_MEDIALIST':
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (floor == 1) const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Hero(
                tag: item.modules.moduleDynamic!.major!.medialist!['cover'],
                child: NetworkImgLayer(
                  width: 180,
                  height: 110,
                  src: item.modules.moduleDynamic!.major!.medialist!['cover'],
                ),
              ),
              PBadge(
                right: 6,
                top: 6,
                text: item.modules.moduleDynamic!.major!.medialist!['badge']
                    ?['text'],
              )
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 110,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item.modules.moduleDynamic!.major!.medialist!['title'],
                    style: TextStyle(
                        fontSize: theme.textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  if (item.modules.moduleDynamic?.major
                          ?.medialist?['sub_title'] !=
                      null) ...[
                    const Spacer(),
                    Text(
                      item.modules.moduleDynamic!.major!
                          .medialist!['sub_title'],
                      style: TextStyle(
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          color: theme.colorScheme.outline),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (floor == 1) const SizedBox(width: 12),
        ],
      );

    case 'DYNAMIC_TYPE_SUBSCRIPTION_NEW'
        when item.modules.moduleDynamic?.major?.type ==
            'MAJOR_TYPE_SUBSCRIPTION_NEW':
      return livePanelSub(theme, source, item, context, floor: floor);

    default:
      return Padding(
        padding: floor == 1
            ? const EdgeInsets.symmetric(horizontal: 12)
            : EdgeInsets.zero,
        child: Text('暂未支持的类型: \n${item.idStr}\n${item.type}'),
      );
  }
}
