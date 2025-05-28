import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/live_search_type.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';
import 'package:PiliPlus/models/live/live_emoticons/data.dart';
import 'package:PiliPlus/models/live/live_emoticons/datum.dart';
import 'package:PiliPlus/models/live/live_feed_index/data.dart';
import 'package:PiliPlus/models/live/live_follow/data.dart';
import 'package:PiliPlus/models/live/live_room/danmu_info.dart';
import 'package:PiliPlus/models/live/live_room/item.dart';
import 'package:PiliPlus/models/live/live_room/room_info.dart';
import 'package:PiliPlus/models/live/live_room/room_info_h5.dart';
import 'package:PiliPlus/models/live/live_search/data.dart';
import 'package:PiliPlus/models/live/live_second_list/data.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';

class LiveHttp {
  static Future<LoadingState<List<LiveItemModel>?>> liveList({
    int? vmid,
    int? pn,
    int? ps,
    String? orderType,
    String? gaiaVtoken,
  }) async {
    var res = await Request().get(
      Api.liveList,
      queryParameters: await WbiSign.makSign({
        'page': pn,
        'page_size': 30,
        'platform': 'web',
        'web_location': 0.0,
        if (gaiaVtoken != null) 'gaia_vtoken': gaiaVtoken,
      }),
      options: Options(
        headers: {
          'origin': 'https://live.bilibili.com',
          'referer': 'https://live.bilibili.com/',
          'user-agent': Request.headerUa(type: 'pc'),
          if (gaiaVtoken != null) 'cookie': 'x-bili-gaia-vtoken=$gaiaVtoken'
        },
      ),
    );
    if (res.data['code'] == 0) {
      List<LiveItemModel>? list = (res.data['data']?['list'] as List?)
          ?.map<LiveItemModel>((e) => LiveItemModel.fromJson(e))
          .toList();
      return Success(list);
    } else {
      String? vVoucher;
      if (gaiaVtoken == null && res.data['code'] == -352) {
        vVoucher = res.headers['x-bili-gaia-vvoucher']?.firstOrNull;
      }
      return Error(vVoucher ?? res.data['message']);
    }
  }

  static Future sendLiveMsg({roomId, msg, dmType, emoticonOptions}) async {
    String csrf = Accounts.main.csrf;
    var res = await Request().post(
      Api.sendLiveMsg,
      data: FormData.fromMap({
        'bubble': 0,
        'msg': msg,
        'color': 16777215,
        'mode': 1,
        if (dmType != null) 'dm_type': dmType,
        if (emoticonOptions != null)
          'emoticonOptions': emoticonOptions
        else ...{
          'room_type': 0,
          'jumpfrom': 0,
          'reply_mid': 0,
          'reply_attr': 0,
          'replay_dmid': '',
          'statistics': Constants.statistics,
          'reply_type': 0,
          'reply_uname': '',
        },
        'fontsize': 25,
        'rnd': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'roomid': roomId,
        'csrf': csrf,
        'csrf_token': csrf,
      }),
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future liveRoomInfo({roomId, qn}) async {
    var res = await Request().get(Api.liveRoomInfo, queryParameters: {
      'room_id': roomId,
      'protocol': '0, 1',
      'format': '0, 1, 2',
      'codec': '0, 1',
      'qn': qn,
      'platform': 'web',
      'ptype': 8,
      'dolby': 5,
      'panorama': 1,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': RoomInfoModel.fromJson(res.data['data'])};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future liveRoomInfoH5({roomId, qn}) async {
    var res = await Request().get(Api.liveRoomInfoH5, queryParameters: {
      'room_id': roomId,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': RoomInfoH5Model.fromJson(res.data['data'])
      };
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future liveRoomDanmaPrefetch({roomId}) async {
    var res = await Request().get(Api.liveRoomDmPrefetch, queryParameters: {
      'roomid': roomId,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']['room']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future liveRoomGetDanmakuToken({roomId}) async {
    var res = await Request().get(
      Api.liveRoomDmToken,
      queryParameters: await WbiSign.makSign({
        'id': roomId,
        'web_location': 444.8,
      }),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': LiveDanmakuInfo.fromJson(res.data)};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<List<LiveEmoteDatum>?>> getLiveEmoticons(
      {required int roomId}) async {
    var res = await Request().get(
      Api.getLiveEmoticons,
      queryParameters: {
        'platform': 'pc',
        'room_id': roomId,
      },
    );
    if (res.data['code'] == 0) {
      return Success(LiveEmoteData.fromJson(res.data['data']).data);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<LiveIndexData>> liveFeedIndex({
    required int pn,
    required bool isLogin,
    bool? moduleSelect,
  }) async {
    final params = {
      if (isLogin) 'access_key': Accounts.main.accessKey,
      'appkey': Constants.appKey,
      'actionKey': 'appkey',
      'build': '8350200',
      'c_locale': 'zh_CN',
      'device': 'pad',
      'device_name': 'vivo',
      'device_type': '0',
      'fnval': '912',
      'disable_rcmd': '0',
      'https_url_req': '1',
      if (moduleSelect == true) 'module_select': '1',
      'mobi_app': 'android_hd',
      'network': 'wifi',
      'page': pn,
      'platform': 'android',
      if (isLogin) 'relation_page': '1',
      's_locale': 'zh_CN',
      'scale': '2',
      'statistics': Constants.statistics,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().get(
      Api.liveFeedIndex,
      queryParameters: params,
    );
    if (res.data['code'] == 0) {
      return Success(LiveIndexData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<LiveFollowData>> liveFollow(int page) async {
    var res = await Request().get(
      Api.liveFollow,
      queryParameters: {
        'page': page,
        'page_size': 9,
        'ignoreRecord': 1,
        'hit_ab': true,
      },
    );
    if (res.data['code'] == 0) {
      return Success(LiveFollowData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<LiveSecondData>> liveSecondList({
    required int pn,
    required bool isLogin,
    required areaId,
    required parentAreaId,
    String? sortType,
  }) async {
    final params = {
      if (isLogin) 'access_key': Accounts.main.accessKey,
      'appkey': Constants.appKey,
      'actionKey': 'appkey',
      if (areaId != null) 'area_id': areaId,
      if (parentAreaId != null) 'parent_area_id': parentAreaId,
      'build': '8350200',
      'c_locale': 'zh_CN',
      'device': 'pad',
      'device_name': 'vivo',
      'device_type': '0',
      'fnval': '912',
      'disable_rcmd': '0',
      'https_url_req': '1',
      'mobi_app': 'android_hd',
      'module_select': '0',
      'network': 'wifi',
      'page': pn,
      'page_size': '20',
      'platform': 'android',
      'qn': '0',
      if (sortType != null) 'sort_type': sortType,
      'tag_version': '1',
      's_locale': 'zh_CN',
      'scale': '2',
      'statistics': Constants.statistics,
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    };
    Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().get(
      Api.liveSecondList,
      queryParameters: params,
    );
    if (res.data['code'] == 0) {
      return Success(LiveSecondData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<List<AreaList>?>> liveAreaList({
    required bool isLogin,
  }) async {
    final params = {
      if (isLogin) 'access_key': Accounts.main.accessKey,
      'appkey': Constants.appKey,
      'actionKey': 'appkey',
      'build': '8350200',
      'c_locale': 'zh_CN',
      'device': 'pad',
      'disable_rcmd': '0',
      'mobi_app': 'android_hd',
      'platform': 'android',
      's_locale': 'zh_CN',
      'statistics': Constants.statistics,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().get(
      Api.liveAreaList,
      queryParameters: params,
    );
    if (res.data['code'] == 0) {
      return Success((res.data['data']?['list'] as List?)
          ?.map((e) => AreaList.fromJson(e))
          .toList());
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<List<AreaItem>>> getLiveFavTag({
    required bool isLogin,
  }) async {
    final params = {
      if (isLogin) 'access_key': Accounts.main.accessKey,
      'appkey': Constants.appKey,
      'actionKey': 'appkey',
      'build': '8350200',
      'c_locale': 'zh_CN',
      'device': 'pad',
      'disable_rcmd': '0',
      'mobi_app': 'android_hd',
      'platform': 'android',
      's_locale': 'zh_CN',
      'statistics': Constants.statistics,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().get(
      Api.getLiveFavTag,
      queryParameters: params,
    );

    if (res.data['code'] == 0) {
      return Success((res.data['data']?['tags'] as List?)
              ?.map((e) => AreaItem.fromJson(e))
              .toList() ??
          <AreaItem>[]);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future setLiveFavTag({
    required List ids,
  }) async {
    final data = {
      'tags': ids.join(','),
      'access_key': Accounts.main.accessKey,
      'appkey': Constants.appKey,
      'actionKey': 'appkey',
      'build': '8350200',
      'c_locale': 'zh_CN',
      'device': 'pad',
      'disable_rcmd': '0',
      'mobi_app': 'android_hd',
      'platform': 'android',
      's_locale': 'zh_CN',
      'statistics': Constants.statistics,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    Utils.appSign(
      data,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().post(
      Api.setLiveFavTag,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<List<AreaItem>?>> liveRoomAreaList({
    required bool isLogin,
    required parentid,
  }) async {
    final params = {
      if (isLogin) 'access_key': Accounts.main.accessKey,
      'appkey': Constants.appKey,
      'actionKey': 'appkey',
      'build': '8350200',
      'c_locale': 'zh_CN',
      'device': 'pad',
      'disable_rcmd': '0',
      'need_entrance': 1,
      'parent_id': parentid,
      'source_id': 2,
      'mobi_app': 'android_hd',
      'platform': 'android',
      's_locale': 'zh_CN',
      'statistics': Constants.statistics,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().get(
      Api.liveRoomAreaList,
      queryParameters: params,
    );
    if (res.data['code'] == 0) {
      return Success((res.data['data'] as List?)
          ?.map((e) => AreaItem.fromJson(e))
          .toList());
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<LiveSearchData>> liveSearch({
    required bool isLogin,
    required int page,
    required String keyword,
    required LiveSearchType type,
  }) async {
    final params = {
      if (isLogin) 'access_key': Accounts.main.accessKey,
      'appkey': Constants.appKey,
      'actionKey': 'appkey',
      'build': '8350200',
      'c_locale': 'zh_CN',
      'device': 'pad',
      'page': page,
      'pagesize': 30,
      'keyword': keyword,
      'disable_rcmd': '0',
      'mobi_app': 'android_hd',
      'platform': 'android',
      's_locale': 'zh_CN',
      'statistics': Constants.statistics,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'type': type.name,
    };
    Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().get(
      Api.liveSearch,
      queryParameters: params,
    );
    if (res.data['code'] == 0) {
      return Success(LiveSearchData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }
}
