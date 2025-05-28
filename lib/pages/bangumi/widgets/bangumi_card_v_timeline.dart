import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/episode.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';

// 视频卡片 - 垂直布局
class BangumiCardVTimeline extends StatelessWidget {
  const BangumiCardVTimeline({
    super.key,
    required this.item,
  });

  final Episode item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onLongPress: () => imageSaveDialog(
          title: item.title,
          cover: item.cover,
        ),
        onTap: () => PageUtils.viewBangumi(
            seasonId: item.seasonId, epId: item.episodeId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.75,
              child: LayoutBuilder(builder: (context, boxConstraints) {
                final double maxWidth = boxConstraints.maxWidth;
                final double maxHeight = boxConstraints.maxHeight;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    NetworkImgLayer(
                      src: item.cover,
                      width: maxWidth,
                      height: maxHeight,
                    ),
                    if (item.follow == 1)
                      const PBadge(
                        text: '已追番',
                        right: 6,
                        top: 6,
                      ),
                    PBadge(
                      text: '${item.pubTime}',
                      left: 6,
                      bottom: 6,
                      type: PBadgeType.gray,
                    ),
                  ],
                );
              }),
            ),
            bagumiContent(context)
          ],
        ),
      ),
    );
  }

  Widget bagumiContent(context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 5, 0, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? '',
              textAlign: TextAlign.start,
              style: const TextStyle(
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.pubIndex ?? '',
              maxLines: 1,
              style: TextStyle(
                fontSize: theme.textTheme.labelMedium!.fontSize,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
