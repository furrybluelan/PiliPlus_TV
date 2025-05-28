import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/video/note_list/data.dart';
import 'package:PiliPlus/models/video/note_list/list.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class NoteListPageCtr
    extends CommonListController<NoteListData, NoteListItemModel> {
  NoteListPageCtr({this.oid, this.upperMid});
  final dynamic oid;
  final dynamic upperMid;

  RxInt count = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<NoteListItemModel>? getDataList(NoteListData response) {
    count.value = response.page?.total ?? -1;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (count.value != -1 && length >= count.value) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<NoteListData>> customGetData() =>
      VideoHttp.getVideoNoteList(
        oid: oid,
        uperMid: upperMid,
        page: page,
      );
}
