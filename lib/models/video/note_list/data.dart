import 'package:PiliPlus/models/video/note_list/list.dart';
import 'package:PiliPlus/models/video/note_list/page.dart';

class NoteListData {
  List<NoteListItemModel>? list;
  Page? page;
  bool? showPublicNote;
  String? message;

  NoteListData({this.list, this.page, this.showPublicNote, this.message});

  factory NoteListData.fromJson(Map<String, dynamic> json) => NoteListData(
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => NoteListItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: json['page'] == null
            ? null
            : Page.fromJson(json['page'] as Map<String, dynamic>),
        showPublicNote: json['show_public_note'] as bool?,
        message: json['message'] as String?,
      );
}
