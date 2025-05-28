import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/skeleton/space_opus.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_opus/item.dart';
import 'package:PiliPlus/pages/member_opus/controller.dart';
import 'package:PiliPlus/pages/member_opus/widgets/space_opus_item.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class MemberOpus extends StatefulWidget {
  const MemberOpus({
    super.key,
    this.isSingle = false,
    required this.heroTag,
    required this.mid,
  });

  final bool isSingle;
  final String? heroTag;
  final int mid;

  @override
  State<MemberOpus> createState() => _MemberOpusState();
}

class _MemberOpusState extends State<MemberOpus>
    with AutomaticKeepAliveClientMixin {
  late final _controller = Get.put(
    MemberOpusController(
      mid: widget.mid,
      heroTag: widget.heroTag,
    ),
    tag: widget.heroTag,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        refreshIndicator(
          onRefresh: _controller.onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: widget.isSingle ? 12 : 0,
                  left: StyleString.safeSpace,
                  right: StyleString.safeSpace,
                  bottom: MediaQuery.paddingOf(context).bottom + 90,
                ),
                sliver: Obx(() => _buildBody(_controller.loadingState.value)),
              ),
            ],
          ),
        ),
        if (_controller.filter?.isNotEmpty == true)
          Positioned(
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    clipBehavior: Clip.hardEdge,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _controller.filter!
                          .map(
                            (e) => ListTile(
                              onTap: () {
                                if (e == _controller.type.value) {
                                  return;
                                }
                                Get.back();
                                _controller
                                  ..type.value = e
                                  ..onReload();
                              },
                              tileColor: e == _controller.type.value
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface
                                  : null,
                              dense: true,
                              title: Text(
                                e.text ?? e.tabName!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
              icon: const Icon(size: 20, Icons.sort),
              label: Obx(
                () => Text(_controller.type.value.text ??
                    _controller.type.value.tabName!),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(LoadingState<List<SpaceOpusItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => SliverWaterfallFlow.extent(
          maxCrossAxisExtent: Grid.smallCardWidth,
          mainAxisSpacing: StyleString.safeSpace,
          crossAxisSpacing: StyleString.safeSpace,
          children: List.generate(10, (_) => const SpaceOpusSkeleton()),
        ),
      Success(:var response) => response?.isNotEmpty == true
          ? SliverWaterfallFlow.extent(
              maxCrossAxisExtent: Grid.smallCardWidth,
              mainAxisSpacing: StyleString.safeSpace,
              crossAxisSpacing: StyleString.safeSpace,
              lastChildLayoutTypeBuilder: (index) {
                if (index == response.length - 1) {
                  _controller.onLoadMore();
                }
                return index == response.length
                    ? LastChildLayoutType.foot
                    : LastChildLayoutType.none;
              },
              children:
                  response!.map((item) => SpaceOpusItem(item: item)).toList(),
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
