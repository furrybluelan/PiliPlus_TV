import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/models/pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index/condition.dart';
import 'package:PiliPlus/models/pgc/pgc_index_item/data.dart';
import 'package:PiliPlus/models/pgc/pgc_review/data.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/pgc_timeline.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';
import 'package:PiliPlus/utils/storage.dart' show Accounts;
import 'package:dio/dio.dart';

class BangumiHttp {
  static Future<LoadingState<PgcIndexItemData>> pgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    seasonType,
    type,
    indexType,
  }) async {
    dynamic res = await Request().get(
      Api.pgcIndexResult,
      queryParameters: {
        ...params,
        if (seasonType != null) 'season_type': seasonType,
        if (type != null) 'type': type,
        if (indexType != null) 'index_type': indexType,
        'page': page,
        'pagesize': 21,
      },
    );
    if (res.data['code'] == 0) {
      return Success(PgcIndexItemData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<PgcIndexCondition>> pgcIndexCondition({
    seasonType,
    type,
    indexType,
  }) async {
    dynamic res = await Request().get(
      Api.pgcIndexCondition,
      queryParameters: {
        if (seasonType != null) 'season_type': seasonType,
        if (type != null) 'type': type,
        if (indexType != null) 'index_type': indexType,
      },
    );
    if (res.data['code'] == 0) {
      return Success(PgcIndexCondition.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<List<BangumiListItemModel>?>> bangumiList({
    int? page,
    int? indexType,
  }) async {
    var res = await Request().get(Api.bangumiList, queryParameters: {
      'page': page,
      if (indexType != null) 'index_type': indexType,
    });
    if (res.data['code'] == 0) {
      BangumiListDataModel data =
          BangumiListDataModel.fromJson(res.data['data']);
      return Success(data.list);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<BangumiListDataModel>> bangumiFollowList({
    required dynamic mid,
    required int type,
    required int pn,
    int? followStatus,
  }) async {
    var res = await Request().get(Api.bangumiFollowList, queryParameters: {
      'vmid': mid,
      'type': type,
      if (followStatus != null) 'follow_status': followStatus,
      'pn': pn,
    });
    if (res.data['code'] == 0) {
      return Success(BangumiListDataModel.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<List<Result>?>> pgcTimeline({
    int types = 1, // 1：`番剧`<br />3：`电影`<br />4：`国创` |
    required int before,
    required int after,
  }) async {
    var res = await Request().get(
      Api.pgcTimeline,
      queryParameters: {
        'types': types,
        'before': before,
        'after': after,
      },
    );
    if (res.data['code'] == 0) {
      return Success(PgcTimeline.fromJson(res.data).result);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<PgcReviewData>> pgcReview({
    required PgcReviewType type,
    required mediaId,
    int sort = 0,
    String? next,
  }) async {
    var res = await Request().get(
      type.api,
      queryParameters: {
        'media_id': mediaId,
        'ps': 20,
        'sort': sort,
        if (next != null) 'cursor': next,
        'web_location': 666.19,
      },
    );
    if (res.data['code'] == 0) {
      return Success(PgcReviewData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future pgcReviewLike({
    required mediaId,
    required reviewId,
  }) async {
    var res = await Request().post(
      Api.pgcReviewLike,
      data: {
        'media_id': mediaId,
        'review_type': 2,
        'review_id': reviewId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future pgcReviewDislike({
    required mediaId,
    required reviewId,
  }) async {
    var res = await Request().post(
      Api.pgcReviewDislike,
      data: {
        'media_id': mediaId,
        'review_type': 2,
        'review_id': reviewId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future pgcReviewPost({
    required mediaId,
    required int score,
    required String content,
    bool shareFeed = false,
  }) async {
    var res = await Request().post(
      Api.pgcReviewPost,
      data: {
        'media_id': mediaId,
        'score': score,
        'content': content,
        if (shareFeed) 'share_feed': 1,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future pgcReviewMod({
    required mediaId,
    required int score,
    required String content,
    required reviewId,
  }) async {
    var res = await Request().post(
      Api.pgcReviewMod,
      data: {
        'media_id': mediaId,
        'score': score,
        'content': content,
        'review_id': reviewId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future pgcReviewDel({
    required mediaId,
    required reviewId,
  }) async {
    var res = await Request().post(
      Api.pgcReviewDel,
      data: {
        'media_id': mediaId,
        'review_id': reviewId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }
}
