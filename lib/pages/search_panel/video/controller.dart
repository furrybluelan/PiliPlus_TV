import 'dart:math';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/search_type.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/pages/search/widgets/search_text.dart';
import 'package:PiliPlus/pages/search_panel/controller.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SearchVideoController
    extends SearchPanelController<SearchVideoModel, SearchVideoItemModel> {
  SearchVideoController({
    required super.keyword,
    required super.searchType,
    required super.tag,
  });

  bool? hasJump2Video;

  @override
  void onInit() {
    super.onInit();
    DateTime now = DateTime.now();
    pubBeginDate = DateTime(
      now.year,
      now.month,
      1,
      0,
      0,
      0,
    );
    pubEndDate = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    jump2Video();
  }

  @override
  List<SearchVideoItemModel>? getDataList(SearchVideoModel response) {
    return response.list;
  }

  @override
  bool customHandleResponse(
      bool isRefresh, Success<SearchVideoModel> response) {
    searchResultController?.count[searchType.index] =
        response.response.numResults ?? 0;
    if (searchType == SearchType.video && hasJump2Video != true && isRefresh) {
      hasJump2Video = true;
      onPushDetail(response.response.list);
    }
    return false;
  }

  void onPushDetail(resultList) {
    try {
      int? aid = int.tryParse(keyword);
      if (aid != null && resultList.first.aid == aid) {
        PiliScheme.videoPush(aid, null, showDialog: false);
      }
    } catch (_) {}
  }

  void jump2Video() {
    if (RegExp(r'^av\d+$', caseSensitive: false).hasMatch(keyword)) {
      hasJump2Video = true;
      PiliScheme.videoPush(
        int.parse(keyword.substring(2)),
        null,
        showDialog: false,
      );
    } else if (RegExp(r'^bv[a-z\d]{10}$', caseSensitive: false)
        .hasMatch(keyword)) {
      hasJump2Video = true;
      PiliScheme.videoPush(null, keyword, showDialog: false);
    }
  }

  // sort
  late final List<Map> filterList = ArchiveFilterType.values
      .map((type) => {
            'label': type.description,
            'type': type,
          })
      .toList();
  late final Rx<ArchiveFilterType> selectedType =
      ArchiveFilterType.values.first.obs;
  late final List pubTimeFiltersList = [
    {'label': '不限', 'value': 0},
    {'label': '最近一天', 'value': 1},
    {'label': '最近一周', 'value': 2},
    {'label': '最近半年', 'value': 3},
  ];
  late final List timeFiltersList = [
    {'label': '全部时长', 'value': 0},
    {'label': '0-10分钟', 'value': 1},
    {'label': '10-30分钟', 'value': 2},
    {'label': '30-60分钟', 'value': 3},
    {'label': '60分钟+', 'value': 4},
  ];
  late final List zoneFiltersList = [
    {'label': '全部', 'value': 0},
    {'label': '动画', 'value': 1, 'tids': 1},
    {'label': '番剧', 'value': 2, 'tids': 13},
    {'label': '国创', 'value': 3, 'tids': 167},
    {'label': '音乐', 'value': 4, 'tids': 3},
    {'label': '舞蹈', 'value': 5, 'tids': 129},
    {'label': '游戏', 'value': 6, 'tids': 4},
    {'label': '知识', 'value': 7, 'tids': 36},
    {'label': '科技', 'value': 8, 'tids': 188},
    {'label': '运动', 'value': 9, 'tids': 234},
    {'label': '汽车', 'value': 10, 'tids': 223},
    {'label': '生活', 'value': 11, 'tids': 160},
    {'label': '美食', 'value': 12, 'tids': 221},
    {'label': '动物', 'value': 13, 'tids': 217},
    {'label': '鬼畜', 'value': 14, 'tids': 119},
    {'label': '时尚', 'value': 15, 'tids': 155},
    {'label': '资讯', 'value': 16, 'tids': 202},
    {'label': '娱乐', 'value': 17, 'tids': 5},
    {'label': '影视', 'value': 18, 'tids': 181},
    {'label': '记录', 'value': 19, 'tids': 177},
    {'label': '电影', 'value': 20, 'tids': 23},
    {'label': '电视', 'value': 21, 'tids': 11},
  ];
  int currentPubTimeFilter = 0;
  late DateTime pubBeginDate;
  late DateTime pubEndDate;
  bool customPubBeginDate = false;
  bool customPubEndDate = false;
  int currentTimeFilter = 0;
  int currentZoneFilter = 0;

  void onShowFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(
        maxWidth: min(640, context.mediaQueryShortestSide),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          Widget dateWidget([bool isFirst = true]) {
            return SearchText(
              text: DateFormat('yyyy-MM-dd')
                  .format(isFirst ? pubBeginDate : pubEndDate),
              textAlign: TextAlign.center,
              onTap: (text) {
                showDatePicker(
                  context: context,
                  initialDate: isFirst ? pubBeginDate : pubEndDate,
                  firstDate: isFirst ? DateTime(2009, 6, 26) : pubBeginDate,
                  lastDate: isFirst ? pubEndDate : DateTime.now(),
                ).then((selectedDate) async {
                  if (selectedDate != null) {
                    if (isFirst) {
                      customPubBeginDate = true;
                      pubBeginDate = selectedDate;
                    } else {
                      customPubEndDate = true;
                      pubEndDate = selectedDate;
                    }
                    currentPubTimeFilter = -1;
                    SmartDialog.dismiss();
                    pubBegin = DateTime(
                          pubBeginDate.year,
                          pubBeginDate.month,
                          pubBeginDate.day,
                          0,
                          0,
                          0,
                        ).millisecondsSinceEpoch ~/
                        1000;
                    pubEnd = DateTime(
                          pubEndDate.year,
                          pubEndDate.month,
                          pubEndDate.day,
                          23,
                          59,
                          59,
                        ).millisecondsSinceEpoch ~/
                        1000;
                    setState(() {});
                    SmartDialog.showLoading(msg: 'loading');
                    await onReload();
                    SmartDialog.dismiss();
                  }
                });
              },
              bgColor: currentPubTimeFilter == -1 &&
                      (isFirst ? customPubBeginDate : customPubEndDate)
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              textColor: currentPubTimeFilter == -1 &&
                      (isFirst ? customPubBeginDate : customPubEndDate)
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.outline.withValues(alpha: 0.8),
            );
          }

          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: 80 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text('发布时间', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pubTimeFiltersList
                        .map(
                          (item) => SearchText(
                            text: item['label'],
                            onTap: (text) async {
                              Get.back();
                              currentPubTimeFilter = item['value'];
                              SmartDialog.dismiss();
                              SmartDialog.showToast("「${item['label']}」的筛选结果");
                              DateTime now = DateTime.now();
                              if (item['value'] == 0) {
                                pubBegin = null;
                                pubEnd = null;
                              } else {
                                pubBegin = DateTime(
                                      now.year,
                                      now.month,
                                      now.day -
                                          (item['value'] == 0
                                              ? 0
                                              : item['value'] == 1
                                                  ? 6
                                                  : 179),
                                      0,
                                      0,
                                      0,
                                    ).millisecondsSinceEpoch ~/
                                    1000;
                                pubEnd = DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      23,
                                      59,
                                      59,
                                    ).millisecondsSinceEpoch ~/
                                    1000;
                              }
                              SmartDialog.showLoading(msg: 'loading');
                              await onReload();
                              SmartDialog.dismiss();
                            },
                            bgColor: item['value'] == currentPubTimeFilter
                                ? theme.colorScheme.secondaryContainer
                                : null,
                            textColor: item['value'] == currentPubTimeFilter
                                ? theme.colorScheme.onSecondaryContainer
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: dateWidget()),
                      const SizedBox(width: 8),
                      const Text(
                        '至',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: dateWidget(false)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('内容时长', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timeFiltersList
                        .map(
                          (item) => SearchText(
                            text: item['label'],
                            onTap: (text) async {
                              Get.back();
                              currentTimeFilter = item['value'];
                              SmartDialog.dismiss();
                              SmartDialog.showToast("「${item['label']}」的筛选结果");
                              duration.value = item['value'];
                              SmartDialog.showLoading(msg: 'loading');
                              await onReload();
                              SmartDialog.dismiss();
                            },
                            bgColor: item['value'] == currentTimeFilter
                                ? theme.colorScheme.secondaryContainer
                                : null,
                            textColor: item['value'] == currentTimeFilter
                                ? theme.colorScheme.onSecondaryContainer
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('内容分区', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: zoneFiltersList
                        .map(
                          (item) => SearchText(
                            text: item['label'],
                            onTap: (text) async {
                              Get.back();
                              currentZoneFilter = item['value'];
                              SmartDialog.dismiss();
                              SmartDialog.showToast("「${item['label']}」的筛选结果");
                              tids = item['tids'];
                              SmartDialog.showLoading(msg: 'loading');
                              await onReload();
                              SmartDialog.dismiss();
                            },
                            bgColor: item['value'] == currentZoneFilter
                                ? theme.colorScheme.secondaryContainer
                                : null,
                            textColor: item['value'] == currentZoneFilter
                                ? theme.colorScheme.onSecondaryContainer
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
