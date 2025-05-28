import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/common/image_preview_type.dart';
import 'package:PiliPlus/models/common/publish_panel_type.dart';
import 'package:PiliPlus/models/live/live_emoticons/emoticon.dart';
import 'package:PiliPlus/models/video/reply/emote.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:chat_bottom_container/chat_bottom_container.dart';
import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

abstract class CommonPublishPage extends StatefulWidget {
  const CommonPublishPage({
    super.key,
    this.initialValue,
    this.imageLengthLimit,
    this.onSave,
    this.autofocus = true,
  });

  final String? initialValue;
  final int? imageLengthLimit;
  final ValueChanged<String>? onSave;
  final bool autofocus;
}

abstract class CommonPublishPageState<T extends CommonPublishPage>
    extends State<T> with WidgetsBindingObserver {
  late final focusNode = FocusNode();
  late final controller = ChatBottomPanelContainerController<PanelType>();
  late final editController = TextEditingController(text: widget.initialValue);

  Rx<PanelType> panelType = PanelType.none.obs;
  late final RxBool readOnly = false.obs;
  late final RxBool enablePublish = false.obs;

  late final imagePicker = ImagePicker();
  late final RxList<String> pathList = <String>[].obs;
  int get limit => widget.imageLengthLimit ?? 9;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.initialValue.isNullOrEmpty.not) {
      enablePublish.value = true;
    }

    if (widget.autofocus) {
      Future.delayed(const Duration(milliseconds: 300)).whenComplete(() {
        if (mounted) {
          focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    editController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _requestFocus() async {
    await Future.delayed(const Duration(microseconds: 200));
    focusNode.requestFocus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted &&
          widget.autofocus &&
          panelType.value == PanelType.keyboard) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusNode.hasFocus) {
            focusNode.unfocus();
            _requestFocus();
          } else {
            _requestFocus();
          }
        });
      }
    } else if (state == AppLifecycleState.paused) {
      controller.keepChatPanel();
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
    }
  }

  void updatePanelType(PanelType type) {
    final isSwitchToKeyboard = PanelType.keyboard == type;
    final isSwitchToEmojiPanel = PanelType.emoji == type;
    bool isUpdated = false;
    switch (type) {
      case PanelType.keyboard:
        updateInputView(isReadOnly: false);
        break;
      case PanelType.emoji:
        isUpdated = updateInputView(isReadOnly: true);
        break;
      default:
        break;
    }

    void updatePanelTypeFunc() {
      controller.updatePanelType(
        isSwitchToKeyboard
            ? ChatBottomPanelType.keyboard
            : ChatBottomPanelType.other,
        data: type,
        forceHandleFocus: isSwitchToEmojiPanel
            ? ChatBottomHandleFocus.requestFocus
            : ChatBottomHandleFocus.none,
      );
    }

    if (isUpdated) {
      // Waiting for the input view to update.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        updatePanelTypeFunc();
      });
    } else {
      updatePanelTypeFunc();
    }
  }

  Future<void> hidePanel() async {
    if (focusNode.hasFocus) {
      await Future.delayed(const Duration(milliseconds: 100));
      focusNode.unfocus();
    }
    updateInputView(isReadOnly: false);
    if (ChatBottomPanelType.none == controller.currentPanelType) return;
    controller.updatePanelType(ChatBottomPanelType.none);
  }

  bool updateInputView({
    required bool isReadOnly,
  }) {
    if (readOnly.value != isReadOnly) {
      readOnly.value = isReadOnly;
      return true;
    }
    return false;
  }

  Future<void> onPublish() async {
    feedBack();
    List<Map<String, dynamic>>? pictures;
    if (pathList.isNotEmpty) {
      SmartDialog.showLoading(msg: '正在上传图片...');
      final cancelToken = CancelToken();
      try {
        pictures = await Future.wait<Map<String, dynamic>>(
            pathList.map((path) async {
              Map result = await MsgHttp.uploadBfs(
                path: path,
                category: 'daily',
                biz: 'new_dyn',
                cancelToken: cancelToken,
              );
              if (!result['status']) throw HttpException(result['msg']);
              return {
                'img_width': result['data']['image_width'],
                'img_height': result['data']['image_height'],
                'img_size': result['data']['img_size'] / 1024,
                'img_src': result['data']['image_url'],
              };
            }).toList(),
            eagerError: true);
        SmartDialog.dismiss();
      } on HttpException catch (e) {
        cancelToken.cancel();
        SmartDialog.dismiss();
        SmartDialog.showToast(e.message);
        return;
      }
    }
    onCustomPublish(message: editController.text, pictures: pictures);
  }

  Future<void> onCustomPublish({required String message, List? pictures});

  void onChooseEmote(emote) {
    enablePublish.value = true;
    final int cursorPosition = editController.selection.baseOffset;
    final String currentText = editController.text;
    if (emote is Emote) {
      final String newText = currentText.substring(0, cursorPosition) +
          emote.text! +
          currentText.substring(cursorPosition);
      editController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: cursorPosition + emote.text!.length),
      );
    } else if (emote is LiveEmoticon) {
      final String newText = currentText.substring(0, cursorPosition) +
          emote.emoji! +
          currentText.substring(cursorPosition);
      editController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: cursorPosition + emote.emoji!.length),
      );
    }
    widget.onSave?.call(editController.text);
  }

  Widget? get customPanel => null;

  Widget buildEmojiPickerPanel() {
    double height = 170;
    final keyboardHeight = controller.keyboardHeight;
    if (keyboardHeight != 0) {
      height = max(height, keyboardHeight);
    }
    return SizedBox(
      height: height,
      child: customPanel,
    );
  }

  Widget buildPanelContainer([Color? panelBgColor]) {
    return ChatBottomPanelContainer<PanelType>(
      controller: controller,
      inputFocusNode: focusNode,
      otherPanelWidget: (type) {
        if (type == null) return const SizedBox.shrink();
        switch (type) {
          case PanelType.emoji:
            return buildEmojiPickerPanel();
          default:
            return const SizedBox.shrink();
        }
      },
      onPanelTypeChange: (panelType, data) {
        // debugPrint('panelType: $panelType');
        switch (panelType) {
          case ChatBottomPanelType.none:
            this.panelType.value = PanelType.none;
            break;
          case ChatBottomPanelType.keyboard:
            this.panelType.value = PanelType.keyboard;
            break;
          case ChatBottomPanelType.other:
            if (data == null) return;
            switch (data) {
              case PanelType.emoji:
                this.panelType.value = PanelType.emoji;
                break;
              default:
                this.panelType.value = PanelType.none;
                break;
            }
            break;
        }
      },
      panelBgColor: panelBgColor ?? Theme.of(context).colorScheme.surface,
    );
  }

  Widget buildImage(int index, double height) {
    final color =
        Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5);

    void onClear() {
      pathList.removeAt(index);
      if (pathList.isEmpty && editController.text.trim().isEmpty) {
        enablePublish.value = false;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            controller.keepChatPanel();
            context.imageView(
              imgList: pathList
                  .map((path) => SourceModel(
                        url: path,
                        sourceType: SourceType.fileImage,
                      ))
                  .toList(),
              initialPage: index,
            );
          },
          onLongPress: onClear,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: Image(
              height: height,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.low,
              image: FileImage(File(pathList[index])),
            ),
          ),
        ),
        Positioned(
          top: 34,
          right: 5,
          child: iconButton(
            context: context,
            icon: Icons.edit,
            onPressed: () => onCropImage(index),
            size: 24,
            iconSize: 14,
            bgColor: color,
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: iconButton(
            context: context,
            icon: Icons.clear,
            onPressed: onClear,
            size: 24,
            iconSize: 14,
            bgColor: color,
          ),
        ),
      ],
    );
  }

  Future<void> onCropImage(int index) async {
    final theme = Theme.of(context);
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pathList[index],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪',
          toolbarColor: theme.colorScheme.secondaryContainer,
          toolbarWidgetColor: theme.colorScheme.onSecondaryContainer,
        ),
        IOSUiSettings(
          title: '裁剪',
        ),
      ],
    );
    if (croppedFile != null) {
      pathList[index] = croppedFile.path;
    }
  }

  void onPickImage([VoidCallback? callback]) {
    EasyThrottle.throttle('imagePicker', const Duration(milliseconds: 500),
        () async {
      try {
        List<XFile> pickedFiles = await imagePicker.pickMultiImage(
          limit: limit,
          imageQuality: 100,
        );
        if (pickedFiles.isNotEmpty) {
          for (int i = 0; i < pickedFiles.length; i++) {
            if (pathList.length == limit) {
              SmartDialog.showToast('最多选择$limit张图片');
              break;
            } else {
              pathList.add(pickedFiles[i].path);
            }
          }
          callback?.call();
        }
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    });
  }
}
