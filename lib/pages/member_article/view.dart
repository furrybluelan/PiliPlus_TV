import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_article/item.dart';
import 'package:PiliPlus/pages/member_article/controller.dart';
import 'package:PiliPlus/pages/member_article/widget/item.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberArticle extends StatefulWidget {
  const MemberArticle({
    super.key,
    required this.heroTag,
    required this.mid,
  });

  final String? heroTag;
  final int mid;

  @override
  State<MemberArticle> createState() => _MemberArticleState();
}

class _MemberArticleState extends State<MemberArticle>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _controller = Get.put(
    MemberArticleCtr(mid: widget.mid),
    tag: widget.heroTag,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
              padding: EdgeInsets.only(
                top: 7,
                bottom: MediaQuery.paddingOf(context).bottom + 80,
              ),
              sliver: Obx(() => _buildBody(_controller.loadingState.value)))
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<SpaceArticleItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => SliverGrid(
          gridDelegate: Grid.videoCardHDelegate(context),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return const VideoCardHSkeleton();
            },
            childCount: 10,
          ),
        ),
      Success(:var response) => response?.isNotEmpty == true
          ? SliverGrid(
              gridDelegate: Grid.videoCardHDelegate(context),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return MemberArticleItem(
                    item: response[index],
                  );
                },
                childCount: response!.length,
              ),
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
}
