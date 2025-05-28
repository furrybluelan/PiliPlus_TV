import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/member/article.dart';
import 'package:PiliPlus/pages/common/multi_select_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FavNoteController
    extends MultiSelectController<List<FavNoteModel>?, FavNoteModel> {
  FavNoteController(this.isPublish);

  final bool isPublish;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  void onSelect(int index, [bool disableSelect = true]) {
    super.onSelect(index, false);
  }

  @override
  void handleSelect([bool checked = false, bool disableSelect = true]) {
    allSelected.value = checked;
    super.handleSelect(checked, false);
  }

  @override
  Future<LoadingState<List<FavNoteModel>?>> customGetData() {
    return isPublish
        ? VideoHttp.userNoteList(page: page)
        : VideoHttp.noteList(page: page);
  }

  Future<void> onRemove() async {
    List<FavNoteModel> dataList = (loadingState.value as Success).response;
    Set<FavNoteModel> removeList =
        dataList.where((item) => item.checked == true).toSet();
    final res = await VideoHttp.delNote(
      isPublish: isPublish,
      noteIds: removeList
          .map((item) => isPublish ? item.cvid : item.noteId)
          .toList(),
    );
    if (res['status']) {
      List<FavNoteModel> remainList =
          dataList.toSet().difference(removeList).toList();
      loadingState.value = Success(remainList);
      enableMultiSelect.value = false;
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  void onDisable() {
    if (checkedCount.value != 0) {
      handleSelect();
    }
    enableMultiSelect.value = false;
  }
}
