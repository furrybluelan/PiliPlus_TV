import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/pgc/pgc_index_item/list.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';

// 视频卡片 - 垂直布局
class BangumiCardVPgcIndex extends StatelessWidget {
  const BangumiCardVPgcIndex({
    super.key,
    required this.bangumiItem,
  });

  final PgcIndexItemModel bangumiItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onLongPress: () => imageSaveDialog(
          title: bangumiItem.title,
          cover: bangumiItem.cover,
        ),
        onTap: () => PageUtils.viewBangumi(seasonId: bangumiItem.seasonId),
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
                      src: bangumiItem.cover,
                      width: maxWidth,
                      height: maxHeight,
                    ),
                    PBadge(
                      text: bangumiItem.badge,
                      top: 6,
                      right: 6,
                      bottom: null,
                      left: null,
                    ),
                    PBadge(
                      text: bangumiItem.order,
                      top: null,
                      right: null,
                      bottom: 6,
                      left: 6,
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
              bangumiItem.title!,
              textAlign: TextAlign.start,
              style: const TextStyle(
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            if (bangumiItem.indexShow != null)
              Text(
                bangumiItem.indexShow!,
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
