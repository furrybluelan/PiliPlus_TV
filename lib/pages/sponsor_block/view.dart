import 'dart:math';

import 'package:PiliPlus/common/widgets/pair.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models/common/sponsor_block/segment_type.dart';
import 'package:PiliPlus/models/common/sponsor_block/skip_type.dart';
import 'package:PiliPlus/pages/setting/slide_color_picker.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:uuid/uuid.dart';

class SponsorBlockPage extends StatefulWidget {
  const SponsorBlockPage({super.key});

  @override
  State<SponsorBlockPage> createState() => _SponsorBlockPageState();
}

class _SponsorBlockPageState extends State<SponsorBlockPage> {
  final _url = 'https://github.com/hanydd/BilibiliSponsorBlock';
  final _textController = TextEditingController();
  late double _blockLimit;
  late List<Pair<SegmentType, SkipType>> _blockSettings;
  late List<Color> _blockColor;
  late String _userId;
  late bool _blockToast;
  late String _blockServer;
  late bool _blockTrack;
  bool? _serverStatus;

  Box get setting => GStorage.setting;

  @override
  void initState() {
    super.initState();
    _blockLimit = GStorage.blockLimit;
    _blockSettings = GStorage.blockSettings;
    _blockColor = GStorage.blockColor;
    _userId = GStorage.blockUserID;
    _blockToast = GStorage.blockToast;
    _blockServer = GStorage.blockServer;
    _blockTrack = GStorage.blockTrack;
    _checkServerStatus();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _checkServerStatus() {
    Request()
        .get(
      '$_blockServer/api/status/uptime',
    )
        .then((res) {
      if (mounted) {
        setState(() {
          _serverStatus = res.statusCode == 200 &&
              res.data is String &&
              Utils.isStringNumeric(res.data);
        });
      }
    });
  }

  Widget _blockLimitItem(
          ThemeData theme, TextStyle titleStyle, TextStyle subTitleStyle) =>
      ListTile(
        dense: true,
        onTap: () {
          _textController.text = _blockLimit.toString();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('最短片段时长', style: titleStyle),
                content: TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _textController,
                  autofocus: true,
                  decoration: const InputDecoration(suffixText: 's'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\.]+')),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _blockLimit = max(
                          0.0, double.tryParse(_textController.text) ?? 0.0);
                      setting.put(SettingBoxKey.blockLimit, _blockLimit);
                      setState(() {});
                    },
                    child: const Text('确定'),
                  )
                ],
              );
            },
          );
        },
        title: Text('最短片段时长', style: titleStyle),
        subtitle: Text(
          '忽略短于此时长的片段',
          style: subTitleStyle,
        ),
        trailing: Text(
          '${_blockLimit}s',
          style: const TextStyle(fontSize: 13),
        ),
      );

  Widget _aboudItem(TextStyle titleStyle, TextStyle subTitleStyle) => ListTile(
        dense: true,
        title: Text('关于空降助手', style: titleStyle),
        subtitle: Text(_url, style: subTitleStyle),
        onTap: () => PageUtils.launchURL(_url),
      );

  Widget _userIdItem(
          ThemeData theme, TextStyle titleStyle, TextStyle subTitleStyle) =>
      ListTile(
        dense: true,
        title: Text('用户ID', style: titleStyle),
        subtitle: Text(_userId, style: subTitleStyle),
        onTap: () {
          final key = GlobalKey<FormState>();
          _textController.text = _userId;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('用户ID', style: titleStyle),
                content: Form(
                  key: key,
                  child: TextFormField(
                    minLines: 1,
                    maxLines: 4,
                    autofocus: true,
                    controller: _textController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d]+')),
                    ],
                    validator: (value) {
                      if ((value?.length ?? -1) < 30) {
                        return '用户ID要求至少为30个字符长度的纯字符串';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _userId = const Uuid().v4().replaceAll('-', '');
                      setting.put(SettingBoxKey.blockUserID, _userId);
                      setState(() {});
                    },
                    child: const Text('随机'),
                  ),
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (key.currentState?.validate() == true) {
                        Get.back();
                        _userId = _textController.text;
                        setting.put(SettingBoxKey.blockUserID, _userId);
                        setState(() {});
                      }
                    },
                    child: const Text('确定'),
                  )
                ],
              );
            },
          );
        },
      );

  void _updateBlockToast() {
    _blockToast = !_blockToast;
    setting.put(SettingBoxKey.blockToast, _blockToast);
    setState(() {});
  }

  void _updateBlockTrack() {
    _blockTrack = !_blockTrack;
    setting.put(SettingBoxKey.blockTrack, _blockTrack);
    setState(() {});
  }

  Widget _blockToastItem(TextStyle titleStyle) => ListTile(
      dense: true,
      onTap: _updateBlockToast,
      title: Text(
        '显示跳过Toast',
        style: titleStyle,
      ),
      trailing: Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.8,
        child: Switch(
          thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
            if (states.isNotEmpty && states.first == WidgetState.selected) {
              return const Icon(Icons.done);
            }
            return null;
          }),
          value: _blockToast,
          onChanged: (val) {
            _updateBlockToast();
          },
        ),
      ));

  Widget _blockTrackItem(TextStyle titleStyle, TextStyle subTitleStyle) =>
      ListTile(
          dense: true,
          onTap: _updateBlockTrack,
          title: Text(
            '跳过次数统计跟踪',
            style: titleStyle,
          ),
          subtitle: Text(
            // from origin extension
            '此功能追踪您跳过了哪些片段，让用户知道他们提交的片段帮助了多少人。同时点赞会作为依据，确保垃圾信息不会污染数据库。在您每次跳过片段时，我们都会向服务器发送一条消息。希望大家开启此项设置，以便得到更准确的统计数据。:)',
            style: subTitleStyle,
          ),
          trailing: Transform.scale(
            alignment: Alignment.centerRight,
            scale: 0.8,
            child: Switch(
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (states.isNotEmpty && states.first == WidgetState.selected) {
                  return const Icon(Icons.done);
                }
                return null;
              }),
              value: _blockTrack,
              onChanged: (val) {
                _updateBlockTrack();
              },
            ),
          ));

  Widget _blockServerItem(
          ThemeData theme, TextStyle titleStyle, TextStyle subTitleStyle) =>
      ListTile(
        dense: true,
        onTap: () {
          _textController.text = _blockServer;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('服务器地址', style: titleStyle),
                content: TextFormField(
                  keyboardType: TextInputType.url,
                  controller: _textController,
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _blockServer = HttpString.sponsorBlockBaseUrl;
                      setting.put(SettingBoxKey.blockServer, _blockServer);
                      Request.accountManager.blockServer = _blockServer;
                      setState(() {});
                    },
                    child: const Text('重置'),
                  ),
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _blockServer = _textController.text;
                      setting.put(SettingBoxKey.blockServer, _blockServer);
                      Request.accountManager.blockServer = _blockServer;
                      setState(() {});
                    },
                    child: const Text('确定'),
                  )
                ],
              );
            },
          );
        },
        title: Text(
          '服务器地址',
          style: titleStyle,
        ),
        subtitle: Text(
          _blockServer,
          style: subTitleStyle,
        ),
      );

  Widget _serverStatusItem(ThemeData theme, TextStyle titleStyle) => ListTile(
        dense: true,
        onTap: () {
          setState(() {
            _serverStatus = null;
          });
          _checkServerStatus();
        },
        title: Text('服务器状态', style: titleStyle),
        trailing: Text(
          _serverStatus == null
              ? '——'
              : _serverStatus == true
                  ? '正常'
                  : '错误',
          style: TextStyle(
            fontSize: 13,
            color: _serverStatus == null
                ? null
                : _serverStatus == true
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
          ),
        ),
      );

  void onSelectColor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Color Picker ',
                style: TextStyle(fontSize: 15),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _blockColor[index],
                  ),
                ),
                style: const TextStyle(fontSize: 13, height: 1),
              ),
              TextSpan(
                text: ' ${_blockSettings[index].first.title}',
                style: const TextStyle(fontSize: 13, height: 1),
              ),
            ],
          ),
        ),
        content: SlideColorPicker(
          color: _blockColor[index],
          callback: (Color? color) {
            _blockColor[index] = color ?? _blockSettings[index].first.color;
            setting.put(
                SettingBoxKey.blockColor,
                _blockColor
                    .map((item) => item.value.toRadixString(16).substring(2))
                    .toList());
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const titleStyle = TextStyle(fontSize: 15);

    final subTitleStyle = TextStyle(
      fontSize: 13,
      color: theme.colorScheme.outline,
    );

    final divider = SliverToBoxAdapter(
      child: Divider(
        height: 1,
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
      ),
    );

    final dividerL = SliverToBoxAdapter(
      child: Divider(
        thickness: 16,
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('空降助手')),
      body: CustomScrollView(
        slivers: [
          dividerL,
          SliverToBoxAdapter(child: _serverStatusItem(theme, titleStyle)),
          dividerL,
          SliverToBoxAdapter(
              child: _blockLimitItem(theme, titleStyle, subTitleStyle)),
          divider,
          SliverToBoxAdapter(child: _blockToastItem(titleStyle)),
          divider,
          SliverToBoxAdapter(child: _blockTrackItem(titleStyle, titleStyle)),
          dividerL,
          SliverList.separated(
            itemCount: _blockSettings.length,
            itemBuilder: (context, index) => ListTile(
              dense: true,
              enabled: _blockSettings[index].second != SkipType.disable,
              onTap: () => onSelectColor(index),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _blockColor[index],
                            ),
                          ),
                          style: const TextStyle(fontSize: 14, height: 1),
                        ),
                        TextSpan(
                          text: ' ${_blockSettings[index].first.title}',
                          style: const TextStyle(fontSize: 14, height: 1),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    initialValue: _blockSettings[index].second,
                    onSelected: (item) {
                      _blockSettings[index].second = item;
                      setting.put(
                          SettingBoxKey.blockSettings,
                          _blockSettings
                              .map((item) => item.second.index)
                              .toList());
                      setState(() {});
                    },
                    itemBuilder: (context) => SkipType.values
                        .map((item) => PopupMenuItem<SkipType>(
                              value: item,
                              child: Text(item.title),
                            ))
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _blockSettings[index].second.title,
                            style: TextStyle(
                              height: 1,
                              fontSize: 14,
                              color: _blockSettings[index].second ==
                                      SkipType.disable
                                  ? theme.colorScheme.outline
                                      .withValues(alpha: 0.7)
                                  : theme.colorScheme.secondary,
                            ),
                            strutStyle: const StrutStyle(height: 1, leading: 0),
                          ),
                          Icon(
                            MdiIcons.unfoldMoreHorizontal,
                            size: MediaQuery.textScalerOf(context).scale(14),
                            color:
                                _blockSettings[index].second == SkipType.disable
                                    ? theme.colorScheme.outline
                                        .withValues(alpha: 0.7)
                                    : theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                _blockSettings[index].first.description,
                style: TextStyle(
                  fontSize: 12,
                  color: _blockSettings[index].second == SkipType.disable
                      ? null
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          dividerL,
          SliverToBoxAdapter(
              child: _userIdItem(theme, titleStyle, subTitleStyle)),
          divider,
          SliverToBoxAdapter(
              child: _blockServerItem(theme, titleStyle, subTitleStyle)),
          dividerL,
          SliverToBoxAdapter(child: _aboudItem(titleStyle, subTitleStyle)),
          dividerL,
          SliverToBoxAdapter(
              child: SizedBox(
            height: 55 + MediaQuery.paddingOf(context).bottom,
          )),
        ],
      ),
    );
  }
}
