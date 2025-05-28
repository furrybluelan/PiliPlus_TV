import 'package:PiliPlus/models/model_avatar.dart';
import 'package:PiliPlus/models/model_owner.dart';

class Author extends Owner {
  int? level;
  int? isSeniorMember;
  Vip? vipInfo;
  Pendant? pendant;
  BaseOfficialVerify? official;

  Author({
    super.mid,
    super.face,
    super.name,
    this.level,
    this.isSeniorMember,
    this.vipInfo,
    this.pendant,
    this.official,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        mid: json['mid'] as int?,
        name: json['name'] as String?,
        face: json['face'] as String?,
        level: json['level'] as int?,
        isSeniorMember: json['is_senior_member'] as int?,
        vipInfo: json['vip_info'] == null
            ? null
            : Vip.fromJson(json['vip_info'] as Map<String, dynamic>),
        pendant: json['pendant'] == null
            ? null
            : Pendant.fromJson(json['pendant'] as Map<String, dynamic>),
        official: json['official'] == null
            ? null
            : BaseOfficialVerify.fromJson(
                json['official'] as Map<String, dynamic>),
      );
}
