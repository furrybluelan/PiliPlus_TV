import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/member/search_type.dart';
import 'package:PiliPlus/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:PiliPlus/pages/dynamics_tab/view.dart';
import 'package:PiliPlus/pages/member_search/child/controller.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class MemberSearchChildPage extends StatefulWidget {
  const MemberSearchChildPage({
    super.key,
    required this.controller,
    required this.searchType,
  });

  final MemberSearchChildController controller;
  final MemberSearchType searchType;

  @override
  State<MemberSearchChildPage> createState() => _MemberSearchChildPageState();
}

class _MemberSearchChildPageState extends State<MemberSearchChildPage>
    with AutomaticKeepAliveClientMixin {
  late final bool dynamicsWaterfallFlow = GStorage.setting
      .get(SettingBoxKey.dynamicsWaterfallFlow, defaultValue: true);
  MemberSearchChildController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: widget.searchType == MemberSearchType.archive ? 7 : 0,
              bottom: MediaQuery.paddingOf(context).bottom + 80,
            ),
            sliver: Obx(() => _buildBody(_controller.loadingState.value)),
          ),
        ],
      ),
    );
  }

  Widget get _buildLoading {
    return switch (widget.searchType) {
      MemberSearchType.archive => SliverGrid(
          gridDelegate: Grid.videoCardHDelegate(context),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return const VideoCardHSkeleton();
            },
            childCount: 10,
          ),
        ),
      MemberSearchType.dynamic =>
        DynamicsTabPage.dynSkeleton(dynamicsWaterfallFlow),
    };
  }

  Widget _buildBody(LoadingState<List?> loadingState) {
    return switch (loadingState) {
      Loading() => _buildLoading,
      Success(:var response) => response?.isNotEmpty == true
          ? Builder(
              builder: (context) {
                return switch (widget.searchType) {
                  MemberSearchType.archive => SliverGrid(
                      gridDelegate: Grid.videoCardHDelegate(context),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == response.length - 1) {
                            _controller.onLoadMore();
                          }
                          return VideoCardH(
                            videoItem: response[index],
                          );
                        },
                        childCount: response!.length,
                      ),
                    ),
                  MemberSearchType.dynamic => dynamicsWaterfallFlow
                      ? SliverWaterfallFlow.extent(
                          maxCrossAxisExtent: Grid.smallCardWidth * 2,
                          crossAxisSpacing: StyleString.safeSpace,
                          mainAxisSpacing: StyleString.safeSpace,
                          lastChildLayoutTypeBuilder: (index) {
                            if (index == response.length - 1) {
                              _controller.onLoadMore();
                            }
                            return index == response.length
                                ? LastChildLayoutType.foot
                                : LastChildLayoutType.none;
                          },
                          children: response!
                              .map((item) => DynamicPanel(item: item))
                              .toList(),
                        )
                      : SliverCrossAxisGroup(
                          slivers: [
                            const SliverFillRemaining(),
                            SliverConstrainedCrossAxis(
                              maxExtent: Grid.smallCardWidth * 2,
                              sliver: SliverList.builder(
                                itemBuilder: (context, index) {
                                  if (index == response.length - 1) {
                                    _controller.onLoadMore();
                                  }
                                  return DynamicPanel(
                                    item: response[index],
                                  );
                                },
                                itemCount: response!.length,
                              ),
                            ),
                            const SliverFillRemaining(),
                          ],
                        ),
                };
              },
            )
          : HttpError(
              onReload: _controller.onReload,
            ),
      Error(:var errMsg) => HttpError(
          errMsg: errMsg,
          onReload: _controller.onReload,
        ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
