import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/models/user/fav_folder.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavPanel extends StatefulWidget {
  const FavPanel({
    super.key,
    this.ctr,
    this.scrollController,
  });

  final dynamic ctr;
  final ScrollController? scrollController;

  @override
  State<FavPanel> createState() => _FavPanelState();
}

class _FavPanelState extends State<FavPanel> {
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = widget.ctr.queryVideoInFolder();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            tooltip: '关闭',
            onPressed: Get.back,
            icon: const Icon(Icons.close_outlined),
          ),
          title: const Text('添加到收藏夹'),
          actions: [
            TextButton.icon(
              onPressed: () => Get.toNamed('/createFav')?.then((data) {
                if (data != null) {
                  (widget.ctr?.favFolderData.value as FavFolderData?)
                      ?.list
                      ?.insert(1, data);
                  widget.ctr?.favFolderData.refresh();
                }
              }),
              icon: Icon(
                Icons.add,
                color: theme.colorScheme.primary,
              ),
              label: const Text('新建收藏夹'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Expanded(
          child: FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // TODO: refactor
                if (snapshot.data is! Map) {
                  return HttpError(
                    isSliver: false,
                    onReload: () => setState(() {
                      _futureBuilderFuture = widget.ctr.queryVideoInFolder();
                    }),
                  );
                }
                Map data = snapshot.data as Map;
                if (data['status']) {
                  return Obx(
                    () => Material(
                      color: Colors.transparent,
                      child: ListView.builder(
                        controller: widget.scrollController,
                        itemCount: widget.ctr.favFolderData.value.list.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => widget.ctr.onChoose(
                                widget.ctr.favFolderData.value.list[index]
                                        .favState !=
                                    1,
                                index),
                            dense: true,
                            leading: Utils.isPublicFav(widget
                                    .ctr.favFolderData.value.list[index].attr)
                                ? const Icon(Icons.folder_outlined)
                                : const Icon(Icons.lock_outline),
                            minLeadingWidth: 0,
                            title: Text(widget
                                .ctr.favFolderData.value.list[index].title!),
                            subtitle: Text(
                              '${widget.ctr.favFolderData.value.list[index].mediaCount}个内容 . ${Utils.isPublicFavText(widget.ctr.favFolderData.value.list[index].attr)}',
                            ),
                            trailing: Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: widget.ctr.favFolderData.value
                                        .list[index].favState ==
                                    1,
                                onChanged: (bool? checkValue) =>
                                    widget.ctr.onChoose(checkValue!, index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return CustomScrollView(
                    controller: widget.scrollController,
                    slivers: [
                      HttpError(
                        errMsg: data['msg'],
                        onReload: () => setState(() {
                          _futureBuilderFuture =
                              widget.ctr.queryVideoInFolder();
                        }),
                      )
                    ],
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        Divider(
          height: 1,
          color: theme.disabledColor.withValues(alpha: 0.08),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  visualDensity: const VisualDensity(
                    horizontal: -1,
                    vertical: -2,
                  ),
                  foregroundColor: theme.colorScheme.outline,
                  backgroundColor: theme.colorScheme.onInverseSurface,
                ),
                child: const Text('取消'),
              ),
              const SizedBox(width: 25),
              FilledButton.tonal(
                onPressed: () {
                  feedBack();
                  widget.ctr.actionFavVideo();
                },
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  visualDensity: const VisualDensity(
                    horizontal: -1,
                    vertical: -2,
                  ),
                ),
                child: const Text('完成'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
