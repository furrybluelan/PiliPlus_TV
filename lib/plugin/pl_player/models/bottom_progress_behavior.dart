enum BtmProgressBehavior {
  alwaysShow,
  alwaysHide,
  onlyShowFullScreen,
  onlyHideFullScreen,
}

extension BtmProgresBehaviorDesc on BtmProgressBehavior {
  String get description => const ['始终展示', '始终隐藏', '仅全屏时展示', '仅全屏时隐藏'][index];
}

extension BtmProgresBehaviorCode on BtmProgressBehavior {
  int get code => index;

  static BtmProgressBehavior fromCode(int code) {
    return BtmProgressBehavior.values[code];
  }
}
