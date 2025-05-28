import 'package:PiliPlus/common/widgets/radio_widget.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class MemberReportPanel extends StatefulWidget {
  const MemberReportPanel({
    super.key,
    required this.name,
    required this.mid,
  });

  final dynamic name;
  final dynamic mid;

  @override
  State<MemberReportPanel> createState() => _MemberReportPanelState();
}

class _MemberReportPanelState extends State<MemberReportPanel> {
  final List<bool> _reasonList = List.generate(3, (_) => false);
  final Set<int> _reason = {};
  int? _reasonV2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '举报: ${widget.name}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text('uid: ${widget.mid}'),
          const SizedBox(height: 10),
          const Text('举报内容（必选，可多选）'),
          ...List.generate(
            3,
            (index) => _checkBoxWidget(
              _reasonList[index],
              (value) {
                setState(() => _reasonList[index] = value);
                if (value) {
                  _reason.add(index + 1);
                } else {
                  _reason.remove(index + 1);
                }
              },
              ['头像违规', '昵称违规', '签名违规'][index],
            ),
          ),
          const Text('举报理由（单选，非必选）'),
          ...List.generate(
            5,
            (index) => RadioWidget<int>(
              value: index,
              groupValue: _reasonV2,
              onChanged: (value) {
                setState(() => _reasonV2 = value);
              },
              title: const ['色情低俗', '不实信息', '违禁', '人身攻击', '赌博诈骗'][index],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: Get.back,
                child: Text(
                  '取消',
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (_reason.isEmpty) {
                    SmartDialog.showToast('至少选择一项作为举报内容');
                  } else {
                    Get.back();
                    dynamic result = await MemberHttp.reportMember(
                      widget.mid,
                      reason: _reason.join(','),
                      reasonV2: _reasonV2 != null ? _reasonV2! + 1 : null,
                    );
                    if (result['msg'] is String && result['msg'].isNotEmpty) {
                      SmartDialog.showToast(result['msg']);
                    } else {
                      SmartDialog.showToast('举报失败');
                    }
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _checkBoxWidget(
  bool defValue,
  ValueChanged onChanged,
  String title,
) {
  return InkWell(
    onTap: () => onChanged(!defValue),
    child: Row(
      children: [
        Checkbox(
          value: defValue,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(title),
      ],
    ),
  );
}
