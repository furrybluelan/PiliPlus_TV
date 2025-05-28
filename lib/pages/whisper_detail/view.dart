import 'dart:async';

import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/grpc/bilibili/im/type.pb.dart' show Msg;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/common/publish_panel_type.dart';
import 'package:PiliPlus/pages/common/common_publish_page.dart';
import 'package:PiliPlus/pages/emote/view.dart';
import 'package:PiliPlus/pages/whisper_detail/controller.dart';
import 'package:PiliPlus/pages/whisper_detail/widget/chat_item.dart';
import 'package:PiliPlus/pages/whisper_link_setting/view.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class WhisperDetailPage extends CommonPublishPage {
  const WhisperDetailPage({
    super.key,
    super.autofocus = false,
  });

  @override
  State<WhisperDetailPage> createState() => _WhisperDetailPageState();
}

class _WhisperDetailPageState
    extends CommonPublishPageState<WhisperDetailPage> {
  final _whisperDetailController = Get.put(
    WhisperDetailController(),
    tag: Utils.makeHeroTag(Get.parameters['talkerId']),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Center(
          child: SizedBox(
            width: 34,
            height: 34,
            child: IconButton(
              tooltip: '返回',
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: theme.colorScheme.secondaryContainer,
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
        title: GestureDetector(
          onTap: () {
            if (_whisperDetailController.mid != null) {
              feedBack();
              Get.toNamed(
                '/member?mid=${_whisperDetailController.mid}',
                arguments: {
                  'face': _whisperDetailController.face,
                },
              );
            }
          },
          child: Row(
            children: [
              NetworkImgLayer(
                width: 34,
                height: 34,
                type: ImageType.avatar,
                src: _whisperDetailController.face,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _whisperDetailController.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(WhisperLinkSettingPage(
              talkerUid: _whisperDetailController.talkerId,
            )),
            icon: Icon(
              size: 20,
              Icons.settings,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Listener(
                onPointerDown: (event) {
                  hidePanel();
                },
                behavior: HitTestBehavior.opaque,
                child: refreshIndicator(
                  onRefresh: _whisperDetailController.onRefresh,
                  child: Obx(() =>
                      _buildBody(_whisperDetailController.loadingState.value)),
                ),
              ),
            ),
            if (_whisperDetailController.mid != null) ...[
              _buildInputView(theme),
              buildPanelContainer(theme.colorScheme.onInverseSurface),
            ] else
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<Msg>?> loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success(:var response) => response?.isNotEmpty == true
          ? ListView.separated(
              shrinkWrap: true,
              reverse: true,
              itemCount: response!.length,
              padding: const EdgeInsets.all(14),
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              controller: _whisperDetailController.scrollController,
              itemBuilder: (context, int index) {
                if (index == response.length - 1) {
                  _whisperDetailController.onLoadMore();
                }
                final item = response[index];
                return ChatItem(
                  item: item,
                  eInfos: _whisperDetailController.eInfos,
                  onLongPress:
                      item.senderUid == _whisperDetailController.ownerMid
                          ? () => onLongPress(index, item)
                          : null,
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
            )
          : scrollErrorWidget(
              onReload: _whisperDetailController.onReload,
            ),
      Error(:var errMsg) => scrollErrorWidget(
          errMsg: errMsg,
          onReload: _whisperDetailController.onReload,
        ),
    };
  }

  void onLongPress(int index, Msg item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Get.back();
                  _whisperDetailController.sendMsg(
                    message: '${item.msgKey}',
                    onClearText: editController.clear,
                    msgType: 5,
                    index: index,
                  );
                },
                dense: true,
                title: const Text(
                  '撤回',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputView(theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onInverseSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => updatePanelType(
              panelType.value == PanelType.emoji
                  ? PanelType.keyboard
                  : PanelType.emoji,
            ),
            icon: const Icon(Icons.emoji_emotions),
            tooltip: '表情',
          ),
          Expanded(
            child: Listener(
              onPointerUp: (event) {
                // Currently it may be emojiPanel.
                if (readOnly.value) {
                  updatePanelType(PanelType.keyboard);
                }
              },
              child: Obx(
                () => TextField(
                  readOnly: readOnly.value,
                  focusNode: focusNode,
                  controller: editController,
                  minLines: 1,
                  maxLines: 4,
                  onChanged: (value) {
                    bool isNotEmpty = value.trim().isNotEmpty;
                    if (isNotEmpty && !enablePublish.value) {
                      enablePublish.value = true;
                    } else if (!isNotEmpty && enablePublish.value) {
                      enablePublish.value = false;
                    }
                  },
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: '发个消息聊聊呗~',
                    fillColor: theme.colorScheme.surface,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      gapPadding: 0,
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
              ),
            ),
          ),
          Obx(
            () {
              return IconButton(
                onPressed: () async {
                  if (enablePublish.value) {
                    _whisperDetailController.sendMsg(
                      message: editController.text,
                      onClearText: editController.clear,
                    );
                  } else {
                    try {
                      XFile? pickedFile = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );
                      if (pickedFile != null) {
                        SmartDialog.showLoading(msg: '正在上传图片');
                        final result = await MsgHttp.uploadBfs(
                          path: pickedFile.path,
                          biz: 'im',
                        );
                        if (result['status']) {
                          String mimeType = lookupMimeType(pickedFile.path)
                                  ?.split('/')
                                  .getOrNull(1) ??
                              'jpg';
                          Map picMsg = {
                            'url': result['data']['image_url'],
                            'height': result['data']['image_height'],
                            'width': result['data']['image_width'],
                            'imageType': mimeType,
                            'original': 1,
                            'size': result['data']['img_size'] / 1024,
                          };
                          SmartDialog.showLoading(msg: '正在发送');
                          await _whisperDetailController.sendMsg(
                            picMsg: picMsg,
                            message: editController.text,
                            onClearText: editController.clear,
                          );
                        } else {
                          SmartDialog.dismiss();
                          SmartDialog.showToast(result['msg']);
                          return;
                        }
                      }
                    } catch (e) {
                      SmartDialog.showToast(e.toString());
                    }
                  }
                },
                icon: Icon(enablePublish.value
                    ? Icons.send
                    : Icons.add_photo_alternate_outlined),
                tooltip: enablePublish.value ? '发送' : '图片',
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget? get customPanel => EmotePanel(onChoose: onChooseEmote);

  @override
  Future<void> onCustomPublish({required String message, List? pictures}) {
    throw UnimplementedError();
  }
}
