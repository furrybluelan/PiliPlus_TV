import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/dynamics_repost/view.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActionPanel extends StatefulWidget {
  const ActionPanel({
    super.key,
    required this.item,
  });
  final DynamicItemModel item;

  @override
  State<ActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends State<ActionPanel> {
  bool isProcessing = false;
  Future<void> handleState(Future Function() action) async {
    if (isProcessing.not) {
      isProcessing = true;
      await action();
      isProcessing = false;
    }
  }

  // 动态点赞
  Future<void> onLikeDynamic() async {
    feedBack();
    final item = widget.item;
    String dynamicId = item.idStr!;
    // 1 已点赞 2 不喜欢 0 未操作
    DynamicStat? like = item.modules.moduleStat?.like;
    int count = like?.count ?? 0;
    bool status = like?.status == true;
    int up = status ? 2 : 1;
    var res = await DynamicsHttp.thumbDynamic(dynamicId: dynamicId, up: up);
    if (res['status']) {
      SmartDialog.showToast(!status ? '点赞成功' : '取消赞');
      if (up == 1) {
        item.modules.moduleStat?.like?.count = count + 1;
        item.modules.moduleStat?.like?.status = true;
      } else {
        item.modules.moduleStat?.like?.count = count - 1;
        item.modules.moduleStat?.like?.status = false;
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.outline;
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: TextButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => RepostPanel(
                item: widget.item,
                callback: () {
                  int count =
                      widget.item.modules.moduleStat?.forward?.count ?? 0;
                  widget.item.modules.moduleStat!.forward!.count = count + 1;
                  setState(() {});
                },
              ),
            ),
            icon: Icon(
              FontAwesomeIcons.shareFromSquare,
              size: 16,
              color: color,
              semanticLabel: "转发",
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              foregroundColor: outline,
            ),
            label: Text(
              widget.item.modules.moduleStat!.forward!.count != null
                  ? Utils.numFormat(
                      widget.item.modules.moduleStat!.forward!.count)
                  : '转发',
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextButton.icon(
            onPressed: () =>
                PageUtils.pushDynDetail(widget.item, 1, action: 'comment'),
            icon: Icon(
              FontAwesomeIcons.comment,
              size: 16,
              color: color,
              semanticLabel: "评论",
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              foregroundColor: outline,
            ),
            label: Text(
              widget.item.modules.moduleStat!.comment!.count != null
                  ? Utils.numFormat(
                      widget.item.modules.moduleStat!.comment!.count)
                  : '评论',
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextButton.icon(
            onPressed: () => handleState(onLikeDynamic),
            icon: Icon(
              widget.item.modules.moduleStat!.like!.status!
                  ? FontAwesomeIcons.solidThumbsUp
                  : FontAwesomeIcons.thumbsUp,
              size: 16,
              color: widget.item.modules.moduleStat!.like!.status!
                  ? primary
                  : color,
              semanticLabel:
                  widget.item.modules.moduleStat!.like!.status! ? "已赞" : "点赞",
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              foregroundColor: outline,
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                widget.item.modules.moduleStat!.like!.count != null
                    ? Utils.numFormat(
                        widget.item.modules.moduleStat!.like!.count)
                    : '点赞',
                key: ValueKey<String>(
                    widget.item.modules.moduleStat!.like!.count?.toString() ??
                        '点赞'),
                style: TextStyle(
                  color: widget.item.modules.moduleStat!.like!.status!
                      ? primary
                      : color,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
