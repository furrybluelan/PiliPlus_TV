import 'dart:convert';

import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/search_type.dart';
import 'package:PiliPlus/models/pgc/info.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/models/search/search_trending/trending_data.dart';
import 'package:PiliPlus/models/search/suggest.dart';
import 'package:PiliPlus/models/topic_pub_search/data.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SearchHttp {
  // 获取搜索建议
  static Future searchSuggest({required term}) async {
    var res = await Request().get(Api.searchSuggest,
        queryParameters: {'term': term, 'main_ver': 'v1', 'highlight': term});
    if (res.data is String) {
      Map<String, dynamic> resultMap = json.decode(res.data);
      if (resultMap['code'] == 0) {
        if (resultMap['result'] is Map) {
          resultMap['result']['term'] = term;
        }
        return {
          'status': true,
          'data': resultMap['result'] is Map
              ? SearchSuggestModel.fromJson(resultMap['result'])
              : null,
        };
      } else {
        return {
          'status': false,
          'msg': '请求错误 🙅',
        };
      }
    } else {
      return {
        'status': false,
        'msg': '请求错误 🙅',
      };
    }
  }

  // 分类搜索
  static Future<LoadingState<R>> searchByType<R>({
    required SearchType searchType,
    required String keyword,
    required page,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
  }) async {
    var params = {
      'search_type': searchType.name,
      'keyword': keyword,
      'page': page,
      if (order?.isNotEmpty == true) 'order': order,
      if (duration != null) 'duration': duration,
      if (tids != null) 'tids': tids,
      if (orderSort != null) 'order_sort': orderSort,
      if (userType != null) 'user_type': userType,
      if (categoryId != null) 'category_id': categoryId,
      if (pubBegin != null) 'pubtime_begin_s': pubBegin,
      if (pubEnd != null) 'pubtime_end_s': pubEnd,
    };
    var res = await Request().get(
      Api.searchByType,
      queryParameters: params,
    );
    if (res.data is! Map) {
      return const Error('没有相关数据');
    }
    if (res.data['code'] == 0) {
      dynamic data;
      try {
        switch (searchType) {
          case SearchType.video:
            Set<int> blackMids = GStorage.blackMids;
            if (res.data['data']['result'] != null) {
              for (var i in res.data['data']['result']) {
                // 屏蔽推广和拉黑用户
                i['available'] = !blackMids.contains(i['mid']);
              }
            }
            data = SearchVideoModel.fromJson(res.data['data']);
            break;
          case SearchType.live_room:
            data = SearchLiveModel.fromJson(res.data['data']);
            break;
          case SearchType.bili_user:
            data = SearchUserModel.fromJson(res.data['data']);
            break;
          case SearchType.media_bangumi || SearchType.media_ft:
            data = SearchMBangumiModel.fromJson(res.data['data']);
            break;
          case SearchType.article:
            data = SearchArticleModel.fromJson(res.data['data']);
            break;
        }
        return Success(data);
      } catch (err) {
        debugPrint(err.toString());
        return Error(err.toString());
      }
    } else {
      return Error(res.data['message'] ?? '没有相关数据');
    }
  }

  static Future<LoadingState<SearchAllModel>> searchAll({
    required String keyword,
    required page,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
  }) async {
    var params = {
      'keyword': keyword,
      'page': page,
      if (order?.isNotEmpty == true) 'order': order,
      if (duration != null) 'duration': duration,
      if (tids != null) 'tids': tids,
      if (orderSort != null) 'order_sort': orderSort,
      if (userType != null) 'user_type': userType,
      if (categoryId != null) 'category_id': categoryId,
      if (pubBegin != null) 'pubtime_begin_s': pubBegin,
      if (pubEnd != null) 'pubtime_end_s': pubEnd,
    };
    var res = await Request().get(
      Api.searchAll,
      queryParameters: params,
    );
    if (res.data is! Map) {
      return const Error('没有相关数据');
    }
    if (res.data['code'] == 0) {
      try {
        return Success(SearchAllModel.fromJson(res.data['data']));
      } catch (err) {
        debugPrint(err.toString());
        return Error(err.toString());
      }
    } else {
      return Error(res.data['message'] ?? '没有相关数据');
    }
  }

  static Future<int> ab2c({dynamic aid, dynamic bvid, int? part}) async {
    Map<String, dynamic> data = {};
    if (aid != null) {
      data['aid'] = aid;
    } else if (bvid != null) {
      data['bvid'] = bvid;
    }
    final dynamic res = await Request().get(Api.ab2c, queryParameters: data);
    if (res.data['code'] == 0) {
      return part != null
          ? ((res.data['data'] as List).getOrNull(part - 1)?['cid'] ??
              res.data['data'].first['cid'])
          : res.data['data'].first['cid'];
    } else {
      SmartDialog.showToast("ab2c error: ${res.data['message']}");
      return -1;
    }
  }

  static Future<LoadingState<BangumiInfoModel>> bangumiInfoNew(
      {int? seasonId, int? epId}) async {
    final dynamic res = await Request().get(
      Api.bangumiInfo,
      queryParameters: {
        if (seasonId != null) 'season_id': seasonId,
        if (epId != null) 'ep_id': epId,
      },
    );
    if (res.data['code'] == 0) {
      return Success(BangumiInfoModel.fromJson(res.data['result']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState> episodeInfo({int? epId}) async {
    final dynamic res = await Request().get(
      Api.episodeInfo,
      queryParameters: {
        if (epId != null) 'ep_id': epId,
      },
    );
    if (res.data['code'] == 0) {
      return Success(res.data['data']);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<Map<String, dynamic>> bangumiInfo({
    dynamic seasonId,
    dynamic epId,
  }) async {
    final Map<String, dynamic> data = {};
    if (seasonId != null) {
      data['season_id'] = seasonId;
    } else if (epId != null) {
      data['ep_id'] = epId;
    }
    final dynamic res =
        await Request().get(Api.bangumiInfo, queryParameters: data);

    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': BangumiInfoModel.fromJson(res.data['result']),
      };
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<TrendingData>> searchTrending(
      {int limit = 30}) async {
    final res = await Request().get(
      Api.searchTrending,
      queryParameters: {
        'limit': limit,
      },
    );
    if (res.data['code'] == 0) {
      return Success(TrendingData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<SearchKeywordData>> searchRecommend() async {
    final res = await Request().get(Api.searchRecommend, queryParameters: {
      'build': '8350200',
      'c_locale': 'zh_CN',
      'mobi_app': 'android',
      'platform': 'android',
      's_locale': 'zh_CN',
    });
    if (res.data['code'] == 0) {
      return Success(SearchKeywordData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<TopicPubSearchData>> topicPubSearch({
    required String keywords,
    String content = '',
    required int pageNum,
  }) async {
    final res = await Request().get(
      Api.topicPubSearch,
      queryParameters: {
        'keywords': keywords,
        'content': content,
        if (pageNum == 1) ...{
          'page_size': 20,
          'page_num': 1,
        } else
          'offset': 20 * (pageNum - 1),
        'web_location': 333.1365,
      },
    );
    if (res.data['code'] == 0) {
      return Success(TopicPubSearchData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }
}
