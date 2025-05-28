import 'dart:async';

import 'package:PiliPlus/common/widgets/button/toolbar_icon_button.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/models/common/publish_panel_type.dart';
import 'package:PiliPlus/pages/common/common_publish_page.dart';
import 'package:PiliPlus/pages/live_emote/controller.dart';
import 'package:PiliPlus/pages/live_emote/view.dart';
import 'package:PiliPlus/pages/live_room/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide MultipartFile;

class LiveSendDmPanel extends CommonPublishPage {
  final bool fromEmote;
  final LiveRoomController liveRoomController;

  const LiveSendDmPanel({
    super.key,
    super.initialValue,
    super.onSave,
    this.fromEmote = false,
    required this.liveRoomController,
  });

  @override
  State<LiveSendDmPanel> createState() => _ReplyPageState();
}

class _ReplyPageState extends CommonPublishPageState<LiveSendDmPanel> {
  LiveRoomController get liveRoomController => widget.liveRoomController;

  @override
  void initState() {
    super.initState();
    if (widget.fromEmote) {
      updatePanelType(PanelType.emoji);
    }
  }

  @override
  void dispose() {
    Get.delete<LiveEmotePanelController>(
        tag: liveRoomController.roomId.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: theme.colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...buildInputView(theme),
              buildPanelContainer(Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget? get customPanel => LiveEmotePanel(
        onChoose: onChooseEmote,
        roomId: liveRoomController.roomId,
        onSendEmoticonUnique: (emote) {
          onCustomPublish(
            message: emote.emoticonUnique!,
            dmType: 1,
            emoticonOptions: '[object Object]',
            emoticonUnique: emote.emoji,
          );
        },
      );

  List<Widget> buildInputView(ThemeData theme) {
    return [
      Container(
        padding:
            const EdgeInsets.only(top: 12, right: 15, left: 15, bottom: 10),
        child: Form(
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
                minLines: 1,
                maxLines: 2,
                autofocus: false,
                readOnly: readOnly.value,
                onChanged: (value) {
                  bool isEmpty = value.trim().isEmpty;
                  if (!isEmpty && !enablePublish.value) {
                    enablePublish.value = true;
                  } else if (isEmpty && enablePublish.value) {
                    enablePublish.value = false;
                  }
                  liveRoomController.savedDanmaku = value;
                },
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: "输入弹幕内容",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14),
                ),
                style: theme.textTheme.bodyLarge,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
              ),
            ),
          ),
        ),
      ),
      Divider(
        height: 1,
        color: theme.dividerColor.withValues(alpha: 0.1),
      ),
      Container(
        height: 52,
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => ToolbarIconButton(
                tooltip: '输入',
                onPressed: () {
                  if (panelType.value != PanelType.keyboard) {
                    updatePanelType(PanelType.keyboard);
                  }
                },
                icon: const Icon(Icons.keyboard, size: 22),
                selected: panelType.value == PanelType.keyboard,
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () => ToolbarIconButton(
                tooltip: '表情',
                onPressed: () {
                  if (panelType.value != PanelType.emoji) {
                    updatePanelType(PanelType.emoji);
                  }
                },
                icon: const Icon(Icons.emoji_emotions, size: 22),
                selected: panelType.value == PanelType.emoji,
              ),
            ),
            const Spacer(),
            Obx(
              () => FilledButton.tonal(
                onPressed: enablePublish.value ? onPublish : null,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('发送'),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Future<void> onCustomPublish({
    required String message,
    List? pictures,
    int? dmType,
    emoticonOptions,
    emoticonUnique,
  }) async {
    final res = await LiveHttp.sendLiveMsg(
      roomId: liveRoomController.roomId,
      msg: message,
      dmType: dmType,
      emoticonOptions: emoticonOptions,
    );
    if (res['status']) {
      Get.back();
      liveRoomController.savedDanmaku = null;
      SmartDialog.showToast('发送成功');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }
}
