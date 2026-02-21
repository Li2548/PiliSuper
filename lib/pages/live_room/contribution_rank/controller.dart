import 'package:PiliSuper/http/live.dart';
import 'package:PiliSuper/http/loading_state.dart';
import 'package:PiliSuper/models/common/live/live_contribution_rank_type.dart';
import 'package:PiliSuper/models_new/live/live_contribution_rank/data.dart';
import 'package:PiliSuper/models_new/live/live_contribution_rank/item.dart';
import 'package:PiliSuper/pages/common/common_list_controller.dart';

class ContributionRankController
    extends
        CommonListController<
          LiveContributionRankData,
          LiveContributionRankItem
        > {
  final Object ruid;
  final Object roomId;
  final LiveContributionRankType type;

  ContributionRankController({
    required this.ruid,
    required this.roomId,
    required this.type,
  });

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<LiveContributionRankItem>? getDataList(
    LiveContributionRankData response,
  ) {
    return response.item;
  }

  @override
  Future<LoadingState<LiveContributionRankData>> customGetData() =>
      LiveHttp.liveContributionRank(
        ruid: ruid,
        roomId: roomId,
        page: page,
        type: type,
      );
}
