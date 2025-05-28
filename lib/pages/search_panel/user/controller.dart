import 'dart:math';

import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/pages/search/widgets/search_text.dart';
import 'package:PiliPlus/pages/search_panel/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class SearchUserController
    extends SearchPanelController<SearchUserModel, SearchUserItemModel> {
  SearchUserController({
    required super.keyword,
    required super.searchType,
    required super.tag,
  });

  // sort
  late final List orderFiltersList = [
    {'label': '默认排序', 'value': 0, 'orderSort': 0, 'order': ''},
    {'label': '粉丝数由高到低', 'value': 1, 'orderSort': 0, 'order': 'fans'},
    {'label': '粉丝数由低到高', 'value': 2, 'orderSort': 1, 'order': 'fans'},
    {'label': 'Lv等级由高到低', 'value': 3, 'orderSort': 0, 'order': 'level'},
    {'label': 'Lv等级由低到高', 'value': 4, 'orderSort': 1, 'order': 'level'},
  ];
  late final List userTypeFiltersList = [
    {'label': '全部用户', 'value': 0, 'userType': 0},
    {'label': 'UP主', 'value': 1, 'userType': 1},
    {'label': '普通用户', 'value': 2, 'userType': 2},
    {'label': '认证用户', 'value': 3, 'userType': 3},
  ];
  RxInt currentOrderFilterval = 0.obs;
  RxInt currentUserTypeFilterval = 0.obs;

  void onShowFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(
        maxWidth: min(640, context.mediaQueryShortestSide),
      ),
      builder: (context) {
        final theme = Theme.of(context);
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
                const Text('用户粉丝数及等级排序顺序', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: orderFiltersList
                      .map(
                        (item) => SearchText(
                          text: item['label'],
                          onTap: (_) async {
                            Get.back();
                            currentOrderFilterval.value = item['value'];
                            SmartDialog.dismiss();
                            SmartDialog.showToast("「${item['label']}」的筛选结果");
                            orderSort = item['orderSort'];
                            order.value = item['order'];
                            SmartDialog.showLoading(msg: 'loading');
                            await onReload();
                            SmartDialog.dismiss();
                          },
                          bgColor: item['value'] == currentOrderFilterval.value
                              ? theme.colorScheme.secondaryContainer
                              : null,
                          textColor:
                              item['value'] == currentOrderFilterval.value
                                  ? theme.colorScheme.onSecondaryContainer
                                  : null,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                const Text('用户分类', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: userTypeFiltersList
                      .map(
                        (item) => SearchText(
                          text: item['label'],
                          onTap: (_) async {
                            Get.back();
                            currentUserTypeFilterval.value = item['value'];
                            SmartDialog.dismiss();
                            SmartDialog.showToast("「${item['label']}」的筛选结果");
                            userType = item['userType'];
                            SmartDialog.showLoading(msg: 'loading');
                            await onReload();
                            SmartDialog.dismiss();
                          },
                          bgColor:
                              item['value'] == currentUserTypeFilterval.value
                                  ? theme.colorScheme.secondaryContainer
                                  : null,
                          textColor:
                              item['value'] == currentUserTypeFilterval.value
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
    );
  }
}
