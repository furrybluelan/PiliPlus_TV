import 'package:PiliPlus/common/widgets/image/image_view.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/dynamics/widgets/vote.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

// 富文本
TextSpan? richNode(
  ThemeData theme,
  DynamicItemModel item,
  BuildContext context,
) {
  try {
    late final style = TextStyle(color: theme.colorScheme.primary);
    List<InlineSpan> spanChildren = [];

    List<RichTextNodeItem>? richTextNodes;
    if (item.modules.moduleDynamic?.desc != null) {
      richTextNodes = item.modules.moduleDynamic!.desc!.richTextNodes;
    } else if (item.modules.moduleDynamic?.major != null) {
      // 动态页面 richTextNodes 层级可能与主页动态层级不同
      richTextNodes =
          item.modules.moduleDynamic!.major!.opus?.summary?.richTextNodes;
      if (item.modules.moduleDynamic?.major?.opus?.title != null) {
        spanChildren.add(
          TextSpan(
            text: '${item.modules.moduleDynamic!.major!.opus!.title!}\n',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
    }
    if (richTextNodes == null || richTextNodes.isEmpty) {
      return null;
    } else {
      for (var i in richTextNodes) {
        switch (i.type) {
          case 'RICH_TEXT_NODE_TYPE_TEXT':
            spanChildren.add(
              TextSpan(
                text: i.origText,
                style: const TextStyle(height: 1.65),
              ),
            );
            break;
          // @用户
          case 'RICH_TEXT_NODE_TYPE_AT':
            spanChildren.add(
              TextSpan(
                text: ' ${i.text}',
                style: style,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.toNamed('/member?mid=${i.rid}'),
              ),
            );
            break;
          // 话题
          case 'RICH_TEXT_NODE_TYPE_TOPIC':
            spanChildren.add(
              TextSpan(
                text: i.origText!,
                style: style,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.toNamed(
                        '/searchResult',
                        parameters: {
                          'keyword':
                              i.origText!.substring(1, i.origText!.length - 1),
                        },
                      ),
              ),
            );
            break;
          // 网页链接
          case 'RICH_TEXT_NODE_TYPE_WEB':
            spanChildren
              ..add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.link,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
              ..add(
                TextSpan(
                  text: i.text,
                  style: style,
                  recognizer: i.origText == null
                      ? null
                      : (TapGestureRecognizer()
                        ..onTap =
                            () => PiliScheme.routePushFromUrl(i.origText!)),
                ),
              );
            break;
          // 投票
          case 'RICH_TEXT_NODE_TYPE_VOTE':
            spanChildren
              ..add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    size: 20,
                    Icons.bar_chart_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
              ..add(
                TextSpan(
                  text: '投票：${i.text}',
                  style: style,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      final dynIdStr = item.basic?.commentIdStr;
                      final dynId =
                          dynIdStr != null ? int.tryParse(dynIdStr) : null;
                      showVoteDialog(context, int.parse(i.rid!), dynId);
                    },
                ),
              );
            break;
          // 表情
          case 'RICH_TEXT_NODE_TYPE_EMOJI' when (i.emoji != null):
            final size = i.emoji!.size * 20.0;
            spanChildren.add(
              WidgetSpan(
                child: NetworkImgLayer(
                  src: i.emoji!.url,
                  type: ImageType.emote,
                  width: size,
                  height: size,
                ),
              ),
            );
            break;
          // 抽奖
          case 'RICH_TEXT_NODE_TYPE_LOTTERY':
            spanChildren
              ..add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.redeem_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
              ..add(
                TextSpan(
                  text: '${i.origText} ',
                  style: style,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.toNamed(
                          '/webview',
                          parameters: {
                            'url':
                                'https://www.bilibili.com/h5/lottery/result?business_id=${item.idStr}'
                          },
                        ),
                ),
              );
            break;

          case 'RICH_TEXT_NODE_TYPE_GOODS':
            spanChildren
              ..add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
              ..add(
                TextSpan(
                  text: '${i.text} ',
                  style: style,
                  recognizer: i.jumpUrl == null
                      ? null
                      : (TapGestureRecognizer()
                        ..onTap =
                            () => PiliScheme.routePushFromUrl(i.jumpUrl!)),
                ),
              );
            break;
          // 投稿
          case 'RICH_TEXT_NODE_TYPE_BV':
            spanChildren
              ..add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.play_circle_outline_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
              ..add(
                TextSpan(
                  text: '${i.text} ',
                  style: style,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      try {
                        int cid = await SearchHttp.ab2c(bvid: i.rid);
                        PageUtils.toVideoPage(
                          'bvid=${i.rid}&cid=$cid',
                          arguments: {
                            'heroTag': Utils.makeHeroTag(i.rid),
                          },
                        );
                      } catch (err) {
                        SmartDialog.showToast(err.toString());
                      }
                    },
                ),
              );
            break;
          case 'RICH_TEXT_NODE_TYPE_VIEW_PICTURE'
              when (i.pics?.isNotEmpty == true):
            spanChildren
              ..add(const TextSpan(text: '\n'))
              ..add(
                WidgetSpan(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return imageView(
                        constraints.maxWidth,
                        i.pics!
                            .map((item) => ImageModel(
                                  url: item.src ?? '',
                                  width: item.width,
                                  height: item.height,
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              );
            break;
          default:
            spanChildren.add(
              TextSpan(text: i.text, style: style),
            );
            break;
        }
      }
      return TextSpan(children: spanChildren);
    }
  } catch (err) {
    debugPrint('❌rich_node_panel err: $err');
    return null;
  }
}
