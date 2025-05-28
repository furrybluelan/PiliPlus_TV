import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/common/widgets/keep_alive_wrapper.dart';
import 'package:PiliPlus/common/widgets/page/tabs.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/models/pgc/info.dart';
import 'package:PiliPlus/models/video_tag/data.dart';
import 'package:PiliPlus/pages/common/common_collapse_slide_page.dart';
import 'package:PiliPlus/pages/pgc_review/view.dart';
import 'package:PiliPlus/pages/search/widgets/search_text.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart' hide TabBarView;
import 'package:get/get.dart';

class IntroDetail extends CommonCollapseSlidePage {
  final BangumiInfoModel bangumiDetail;
  final List<VideoTagItem>? videoTags;

  const IntroDetail({
    super.key,
    required this.bangumiDetail,
    super.enableSlide = false,
    this.videoTags,
  });

  @override
  State<IntroDetail> createState() => _IntroDetailState();
}

class _IntroDetailState extends CommonCollapseSlidePageState<IntroDetail> {
  late final _tabController = TabController(length: 2, vsync: this);
  final _controller = ScrollController();

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(ThemeData theme) {
    return CustomTabBarView(
      controller: _tabController,
      physics: const CustomTabBarViewScrollPhysics(),
      bgColor: theme.colorScheme.surface,
      header: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              dividerHeight: 0,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: '详情'), Tab(text: '点评')],
              onTap: (index) {
                if (!_tabController.indexIsChanging) {
                  if (index == 0) {
                    _controller.animToTop();
                  }
                }
              },
            ),
          ),
          iconButton(
            context: context,
            icon: Icons.clear,
            onPressed: Get.back,
            iconSize: 22,
            bgColor: Colors.transparent,
          ),
          const SizedBox(width: 12),
        ],
      ),
      children: [
        KeepAliveWrapper(builder: (context) => buildList(theme)),
        PgcReviewPage(
          name: widget.bangumiDetail.title!,
          mediaId: widget.bangumiDetail.mediaId,
        ),
      ],
    );
  }

  @override
  Widget buildList(ThemeData theme) {
    final TextStyle smallTitle = TextStyle(
      fontSize: 12,
      color: theme.colorScheme.onSurface,
    );
    return ListView(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 14,
        bottom: MediaQuery.paddingOf(context).bottom + 80,
      ),
      children: [
        SelectableText(
          widget.bangumiDetail.title!,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            StatView(
              context: context,
              theme: 'gray',
              value: Utils.numFormat(widget.bangumiDetail.stat!['views']),
            ),
            const SizedBox(width: 6),
            StatDanMu(
              context: context,
              theme: 'gray',
              value: Utils.numFormat(widget.bangumiDetail.stat!['danmakus']),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              widget.bangumiDetail.areas!.first['name'],
              style: smallTitle,
            ),
            const SizedBox(width: 6),
            Text(
              widget.bangumiDetail.publish!['pub_time_show'],
              style: smallTitle,
            ),
            const SizedBox(width: 6),
            Text(
              widget.bangumiDetail.newEp!['desc'],
              style: smallTitle,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '简介：',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        SelectableText(
          widget.bangumiDetail.evaluate!,
          style: smallTitle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 20),
        Text(
          '声优：',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        SelectableText(
          widget.bangumiDetail.actors!,
          style: smallTitle.copyWith(fontSize: 14),
        ),
        if (widget.videoTags?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.videoTags!
                .map(
                  (item) => SearchText(
                    fontSize: 13,
                    text: item.tagName!,
                    onTap: (tagName) => Get.toNamed(
                      '/searchResult',
                      parameters: {'keyword': tagName},
                    ),
                    onLongPress: (tagName) => Utils.copyText(tagName),
                  ),
                )
                .toList(),
          )
        ],
      ],
    );
  }
}
