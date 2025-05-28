import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/member_ss/season.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';

class SeasonSeriesCard extends StatelessWidget {
  const SeasonSeriesCard({
    super.key,
    required this.item,
    required this.onTap,
  });
  final MemberSsModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => imageSaveDialog(
        title: item.meta!.name,
        cover: item.meta!.cover,
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: StyleString.safeSpace,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: StyleString.aspectRatio,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints boxConstraints) {
                  final double maxWidth = boxConstraints.maxWidth;
                  final double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        src: item.meta!.cover,
                        width: maxWidth,
                        height: maxHeight,
                      ),
                      PBadge(
                        text:
                            '${item.meta!.seasonId != null ? '合集' : '列表'}: ${item.meta!.total}',
                        bottom: 6.0,
                        right: 6.0,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            videoContent(context),
          ],
        ),
      ),
    );
  }

  Widget videoContent(context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.meta!.name!,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: theme.textTheme.bodyMedium!.fontSize,
              height: 1.42,
              letterSpacing: 0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            Utils.dateFormat(item.meta!.ptime),
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              height: 1,
              color: theme.colorScheme.outline,
              overflow: TextOverflow.clip,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
