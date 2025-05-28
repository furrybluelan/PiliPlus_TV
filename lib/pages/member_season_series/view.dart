import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/member_ss/season.dart' show MemberSsModel;
import 'package:PiliPlus/pages/member_season_series/controller.dart';
import 'package:PiliPlus/pages/member_season_series/widget/season_series_card.dart';
import 'package:PiliPlus/pages/member_video/view.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeasonSeriesPage extends StatefulWidget {
  const SeasonSeriesPage({
    super.key,
    required this.mid,
    this.heroTag,
  });

  final int mid;
  final String? heroTag;

  @override
  State<SeasonSeriesPage> createState() => _SeasonSeriesPageState();
}

class _SeasonSeriesPageState extends State<SeasonSeriesPage>
    with AutomaticKeepAliveClientMixin {
  late final _controller = Get.put(
    SeasonSeriesController(widget.mid),
    tag: widget.heroTag,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            top: StyleString.safeSpace - 5,
            bottom: MediaQuery.paddingOf(context).bottom + 80,
          ),
          sliver: Obx(
            () => _buildBody(_controller.loadingState.value),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(LoadingState<List<MemberSsModel>?> loadingState) {
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
                  MemberSsModel item = response[index];
                  return SeasonSeriesCard(
                    item: item,
                    onTap: () {
                      bool isSeason = item.meta!.seasonId != null;
                      dynamic id =
                          isSeason ? item.meta!.seasonId : item.meta!.seriesId;
                      Get.to(
                        Scaffold(
                          appBar: AppBar(
                            title: Text(item.meta!.name!),
                          ),
                          body: SafeArea(
                            top: false,
                            bottom: false,
                            child: MemberVideo(
                              type: isSeason
                                  ? ContributeType.season
                                  : ContributeType.series,
                              heroTag: widget.heroTag,
                              mid: widget.mid,
                              seasonId: isSeason ? id : null,
                              seriesId: isSeason ? null : id,
                              title: item.meta!.name,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: response!.length,
              ),
            )
          : HttpError(onReload: _controller.onReload),
      Error(:var errMsg) => HttpError(
          errMsg: errMsg,
          onReload: _controller.onReload,
        ),
    };
  }
}
