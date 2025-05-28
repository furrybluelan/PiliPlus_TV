import 'package:PiliPlus/common/widgets/draggable_sheet/draggable_scrollable_sheet_dyn.dart'
    show DraggableScrollableSheet;
import 'package:PiliPlus/common/widgets/scroll_physics.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/common/dynamic/up_panel_position.dart';
import 'package:PiliPlus/pages/dynamics/controller.dart';
import 'package:PiliPlus/pages/dynamics/widgets/up_panel.dart';
import 'package:PiliPlus/pages/dynamics_create/view.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart' hide DraggableScrollableSheet;
import 'package:get/get.dart';

class DynamicsPage extends StatefulWidget {
  const DynamicsPage({super.key});

  @override
  State<DynamicsPage> createState() => _DynamicsPageState();
}

class _DynamicsPageState extends State<DynamicsPage>
    with AutomaticKeepAliveClientMixin {
  final DynamicsController _dynamicsController = Get.put(DynamicsController());
  UpPanelPosition get upPanelPosition => _dynamicsController.upPanelPosition;

  @override
  bool get wantKeepAlive => true;

  Widget _createDynamicBtn(ThemeData theme, [bool isRight = true]) => Center(
        child: Container(
          width: 34,
          height: 34,
          margin:
              EdgeInsets.only(left: !isRight ? 16 : 0, right: isRight ? 16 : 0),
          child: IconButton(
            tooltip: '发布动态',
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return theme.colorScheme.secondaryContainer;
              }),
            ),
            onPressed: () {
              if (_dynamicsController.isLogin.value) {
                showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  builder: (context) => DraggableScrollableSheet(
                    snap: true,
                    expand: false,
                    initialChildSize: 1,
                    minChildSize: 0,
                    maxChildSize: 1,
                    snapSizes: const [1],
                    builder: (context, scrollController) =>
                        CreateDynPanel(scrollController: scrollController),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.add,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    if (GStorage.setting
        .get(SettingBoxKey.dynamicsShowAllFollowedUp, defaultValue: false)) {
      _dynamicsController.scrollController.addListener(listener);
    }
  }

  void listener() {
    if (_dynamicsController.scrollController.position.pixels >=
        _dynamicsController.scrollController.position.maxScrollExtent - 300) {
      EasyThrottle.throttle('following', const Duration(seconds: 1), () {
        _dynamicsController.queryFollowing2();
      });
    }
  }

  @override
  void dispose() {
    _dynamicsController.scrollController.removeListener(listener);
    super.dispose();
  }

  Widget upPanelPart(ThemeData theme) {
    bool isTop = upPanelPosition == UpPanelPosition.top;
    return Material(
      //抽屉模式增加底色
      color: isTop || upPanelPosition.index > 1
          ? theme.colorScheme.surface
          : Colors.transparent,
      child: SizedBox(
        width: isTop ? null : 64,
        height: isTop ? 76 : null,
        child: Obx(
          () {
            if (_dynamicsController.upData.value.upList == null &&
                _dynamicsController.upData.value.liveUsers == null) {
              return const SizedBox.shrink();
            } else if (_dynamicsController.upData.value.errMsg != null) {
              return Center(
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _dynamicsController.queryFollowUp,
                ),
              );
            } else {
              return UpPanel(
                dynamicsController: _dynamicsController,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: upPanelPosition == UpPanelPosition.rightDrawer
            ? _createDynamicBtn(theme, false)
            : null,
        leadingWidth: 50,
        toolbarHeight: 50,
        title: SizedBox(
          height: 50,
          child: TabBar(
            controller: _dynamicsController.tabController,
            isScrollable: true,
            dividerColor: Colors.transparent,
            dividerHeight: 0,
            tabAlignment: TabAlignment.center,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface,
            labelStyle:
                TabBarTheme.of(context).labelStyle?.copyWith(fontSize: 13) ??
                    const TextStyle(fontSize: 13),
            tabs:
                DynamicsTabType.values.map((e) => Tab(text: e.labels)).toList(),
            onTap: (index) {
              if (!_dynamicsController.tabController.indexIsChanging) {
                _dynamicsController.animateToTop();
              }
            },
          ),
        ),
        actions: upPanelPosition == UpPanelPosition.rightDrawer
            ? null
            : [_createDynamicBtn(theme)],
      ),
      drawer: upPanelPosition == UpPanelPosition.leftDrawer
          ? SafeArea(child: upPanelPart(theme))
          : null,
      drawerEnableOpenDragGesture: true,
      endDrawer: upPanelPosition == UpPanelPosition.rightDrawer
          ? SafeArea(child: upPanelPart(theme))
          : null,
      endDrawerEnableOpenDragGesture: true,
      body: Row(
        children: [
          if (upPanelPosition == UpPanelPosition.leftFixed) upPanelPart(theme),
          Expanded(
            child: Column(
              children: [
                if (upPanelPosition == UpPanelPosition.top) upPanelPart(theme),
                Expanded(
                  child: videoTabBarView(
                    controller: _dynamicsController.tabController,
                    children: _dynamicsController.tabsPageList,
                  ),
                ),
              ],
            ),
          ),
          if (upPanelPosition == UpPanelPosition.rightFixed) upPanelPart(theme),
        ],
      ),
    );
  }
}
