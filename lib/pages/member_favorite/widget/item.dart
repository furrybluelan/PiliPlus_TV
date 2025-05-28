import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/space_fav/list.dart';
import 'package:PiliPlus/models/user/sub_folder.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberFavItem extends StatelessWidget {
  const MemberFavItem({super.key, required this.item, this.callback});

  final SpaceFavItemModel item;
  final ValueChanged<bool?>? callback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (item.state == 1) {
            // invalid
            return;
          }

          if (item.type == 0) {
            dynamic res = await Get.toNamed(
              '/favDetail',
              parameters: {
                'mediaId': item.id.toString(),
                'heroTag': Utils.makeHeroTag(item.id),
              },
            );
            callback?.call(res);
          } else {
            Get.toNamed(
              '/subDetail',
              arguments: SubFolderItemData(
                type: item.type,
                title: item.title,
                cover: item.cover,
                upper: Upper(
                  mid: item.upper?.mid,
                  name: item.upper?.name,
                  face: item.upper?.face,
                ),
                mediaCount: item.mediaCount,
                viewCount: item.viewCount,
              ),
              parameters: {
                'id': item.id.toString(),
                'heroTag': Utils.makeHeroTag(item.id),
              },
            );
          }
        },
        onLongPress: () => imageSaveDialog(
          title: item.title,
          cover: item.cover,
        ),
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
                  builder: (context, boxConstraints) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        NetworkImgLayer(
                          src: item.cover,
                          width: boxConstraints.maxWidth,
                          height: boxConstraints.maxHeight,
                        ),
                        if (item.type == 21)
                          const PBadge(
                            right: 3,
                            bottom: 3,
                            text: '合集',
                            isBold: false,
                            size: PBadgeSize.small,
                          )
                        else if (item.type == 0 || item.type == 11)
                          Positioned(
                            right: 3,
                            bottom: 3,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                              ),
                              child: Icon(
                                Icons.video_library_outlined,
                                size: 12,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      item.type == 0
                          ? '${item.mediaCount}个内容 · ${Utils.isPublicFavText(item.attr ?? 0)}'
                          : item.type == 11
                              ? '${item.mediaCount}个内容 · ${item.upper?.name}'
                              : item.type == 21
                                  ? '创建者: ${item.upper?.name}\n${item.mediaCount}个视频 · ${Utils.numFormat(item.viewCount)}播放'
                                  : '${item.mediaCount}个内容',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
