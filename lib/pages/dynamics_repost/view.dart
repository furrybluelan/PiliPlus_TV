import 'package:PiliPlus/common/widgets/button/toolbar_icon_button.dart';
import 'package:PiliPlus/common/widgets/draggable_sheet/draggable_scrollable_sheet_dyn.dart'
    show DraggableScrollableSheet;
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/models/common/publish_panel_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/common/common_publish_page.dart';
import 'package:PiliPlus/pages/emote/controller.dart';
import 'package:PiliPlus/pages/emote/view.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart' hide DraggableScrollableSheet;
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class RepostPanel extends CommonPublishPage {
  const RepostPanel({
    super.key,
    this.item,
    this.dynIdStr,
    this.callback,
    // video
    this.rid,
    this.dynType,
    this.pic,
    this.title,
    this.uname,
    this.isMax,
  });

  // video
  final int? rid;
  final int? dynType;
  final String? pic;
  final String? title;
  final String? uname;
  final bool? isMax;

  final DynamicItemModel? item;
  final String? dynIdStr;
  final VoidCallback? callback;

  @override
  State<RepostPanel> createState() => _RepostPanelState();
}

class _RepostPanelState extends CommonPublishPageState<RepostPanel> {
  late bool _isMax = widget.isMax ?? false;
  bool? _isExpanded;

  late final _key = GlobalKey();

  late final _pic = widget.pic ??
      widget.item?.modules.moduleDynamic?.major?.archive?.cover ??
      widget.item?.modules.moduleDynamic?.major?.pgc?.cover ??
      widget.item?.modules.moduleDynamic?.major?.opus?.pics?.firstOrNull?.url;

  late final _text = widget.title ??
      widget.item?.modules.moduleDynamic?.major?.opus?.summary?.text ??
      widget.item?.modules.moduleDynamic?.desc?.text ??
      widget.item?.modules.moduleDynamic?.major?.archive?.title ??
      widget.item?.modules.moduleDynamic?.major?.pgc?.title ??
      '';

  late final _uname = widget.uname ?? widget.item?.modules.moduleAuthor?.name;

  @override
  void dispose() {
    try {
      Get.delete<EmotePanelController>();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget page([ScrollController? scrollController]) => Column(
          key: _isMax ? _key : null,
          mainAxisSize: _isMax ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isMax ? const SizedBox(height: 16) : const SizedBox(height: 10),
            _buildAppBar(theme),
            if (_isMax) ...[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  children: _buildEditPanel(theme),
                ),
              ),
              _buildToolbar,
              buildPanelContainer(Colors.transparent),
            ] else ...[
              ..._buildEditPanel(theme),
              ..._biuldDismiss(theme),
            ],
          ],
        );

    Widget child() => _isMax
        ? DraggableScrollableSheet(
            snap: true,
            expand: false,
            initialChildSize: 1,
            minChildSize: 0,
            maxChildSize: 1,
            snapSizes: const [1],
            builder: (context, scrollController) => page(scrollController),
          )
        : page();

    return _isExpanded == true
        ? child()
        : AnimatedSize(
            alignment: Alignment.topCenter,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            child: child(),
          );
  }

  List<Widget> _buildEditPanel(ThemeData theme) => [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _isMax
              ? _buildEditWidget(theme)
              : DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        width: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  child: _buildEditPlaceHolder(theme),
                ),
        ),
        const SizedBox(height: 10),
        _buildRefWidget(theme),
      ];

  Widget _buildRefWidget(ThemeData theme) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (_pic != null) ...[
                NetworkImgLayer(
                  radius: 6,
                  width: 40,
                  height: 40,
                  src: _pic,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_uname?.isNotEmpty == true)
                      Text(
                        '@$_uname',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      _text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildEditPlaceHolder(ThemeData theme) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _isMax = true);
          Future.delayed(const Duration(milliseconds: 300), () {
            _isExpanded = true;
            if (mounted) {
              focusNode.requestFocus();
            }
          });
        },
        child: SizedBox(
          width: double.infinity,
          child: Text(
            '说点什么吧',
            style: TextStyle(
              height: 1.75,
              fontSize: 15,
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );

  Widget _buildEditWidget(ThemeData theme) => Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Listener(
          onPointerUp: (event) {
            if (readOnly.value) {
              updatePanelType(PanelType.keyboard);
            }
          },
          child: Obx(
            () => TextField(
              controller: editController,
              minLines: 4,
              maxLines: null,
              focusNode: focusNode,
              readOnly: readOnly.value,
              decoration: InputDecoration(
                hintText: '说点什么吧',
                hintStyle: TextStyle(color: theme.colorScheme.outline),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  gapPadding: 0,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(1000)],
            ),
          ),
        ),
      );

  Widget _buildAppBar(ThemeData theme) => _isMax.not
      ? Row(
          children: [
            const SizedBox(width: 16),
            Text(
              widget.rid != null ? '分享至动态' : '转发动态',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: onPublish,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(widget.rid != null ? '立即发布' : '立即转发'),
            ),
            const SizedBox(width: 16),
          ],
        )
      : Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: IconButton(
                    tooltip: '返回',
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      backgroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        return theme.colorScheme.secondaryContainer;
                      }),
                    ),
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.arrow_back_outlined,
                      size: 18,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.rid != null ? '分享至动态' : '转发动态',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onPublish,
                  style: FilledButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(widget.rid != null ? '发布' : '转发'),
                ),
              ),
            ],
          ),
        );

  Widget get _buildToolbar => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Obx(
          () => ToolbarIconButton(
            onPressed: () {
              updatePanelType(
                panelType.value == PanelType.emoji
                    ? PanelType.keyboard
                    : PanelType.emoji,
              );
            },
            icon: const Icon(Icons.emoji_emotions, size: 22),
            tooltip: '表情',
            selected: panelType.value == PanelType.emoji,
          ),
        ),
      );

  List<Widget> _biuldDismiss(ThemeData theme) => [
        const SizedBox(height: 10),
        Divider(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        ListTile(
          dense: true,
          onTap: Get.back,
          title: Center(
            child: Text(
              '取消',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
        ),
        SizedBox(height: 10 + MediaQuery.of(context).padding.bottom),
      ];

  @override
  Widget? get customPanel => EmotePanel(onChoose: onChooseEmote);

  List<Map<String, dynamic>>? extraContent(DynamicItemModel item) {
    try {
      return [
        {"raw_text": "//", "type": 1, "biz_id": ""},
        {
          "raw_text": "@${item.modules.moduleAuthor!.name}",
          "type": 2,
          "biz_id": item.modules.moduleAuthor!.mid.toString(),
        },
        {"raw_text": ":", "type": 1, "biz_id": ""},
        ...item.modules.moduleDynamic!.desc!.richTextNodes!.map(
          (e) {
            int? type;
            String? bizId;
            switch (e.type) {
              case 'RICH_TEXT_NODE_TYPE_EMOJI':
                type = 9;
                bizId = '';
              case 'RICH_TEXT_NODE_TYPE_AT':
                type = 2;
                bizId = e.rid;
              case 'RICH_TEXT_NODE_TYPE_TEXT':
              default:
                type = 1;
                bizId = '';
            }
            return {
              "raw_text": e.origText,
              "type": type,
              "biz_id": bizId,
            };
          },
        ),
      ];
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> onCustomPublish(
      {required String message, List? pictures}) async {
    var result = await DynamicsHttp.createDynamic(
      mid: Accounts.main.mid,
      dynIdStr: widget.item?.idStr ?? widget.dynIdStr,
      rid: widget.rid,
      dynType: widget.dynType,
      rawText: editController.text,
      extraContent:
          widget.item?.orig != null ? extraContent(widget.item!) : null,
    );
    if (result['status']) {
      Get.back();
      SmartDialog.showToast('转发成功');
      widget.callback?.call();
      RequestUtils.insertCreatedDyn(result);
      RequestUtils.checkCreatedDyn(
        id: result['data']?['dyn_id'],
        dynText: editController.text,
      );
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }
}
