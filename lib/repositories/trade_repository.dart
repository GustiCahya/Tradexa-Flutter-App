import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/trade.dart';
import '../providers/isar_provider.dart';
import '../providers/trade_filter_provider.dart';

part 'trade_repository.g.dart';

class TradeRepository {
  final Isar _isar;

  TradeRepository(this._isar);

  /// Build the base filter query from state
  QueryBuilder<Trade, Trade, QAfterSortBy> _buildFilterQuery(
    TradeFilter filter,
  ) {
    var query = _isar.trades.where().filter().isarIdGreaterThan(-1);

    if (filter.pair != null) {
      query = query.and().pairEqualTo(filter.pair!);
    }
    if (filter.direction != null) {
      query = query.and().directionEqualTo(filter.direction!);
    }
    if (filter.session != null) {
      query = query.and().sessionEqualTo(filter.session!);
    }
    if (filter.emotion != null) {
      query = query.and().emotionEqualTo(filter.emotion!);
    }

    switch (filter.sortField) {
      case TradeSortField.date:
        return filter.sortAscending
            ? query.sortByDate()
            : query.sortByDateDesc();
      case TradeSortField.pnl:
        return filter.sortAscending ? query.sortByPnl() : query.sortByPnlDesc();
      case TradeSortField.rr:
        return filter.sortAscending ? query.sortByRr() : query.sortByRrDesc();
    }
  }

  /// Exposes a stream of trades from Isar DB matching the filter and paginated limit.
  Stream<List<Trade>> watchFilteredTrades(TradeFilter filter) {
    return _buildFilterQuery(
      filter,
    ).limit(filter.limit).watch(fireImmediately: true);
  }

  /// Exposes a stream of all trades matching the filter (no limit) for calculating total stats
  Stream<List<Trade>> watchFilteredStats(TradeFilter filter) {
    return _buildFilterQuery(filter).watch(fireImmediately: true);
  }

  /// Create a trade locally
  Future<void> createTrade(Trade trade) async {
    await _isar.writeTxn(() async {
      await _isar.trades.put(trade);
    });
  }

  /// Update a trade locally
  Future<void> updateTrade(Trade trade) async {
    await _isar.writeTxn(() async {
      await _isar.trades.put(trade);
    });
  }

  /// Delete a trade locally
  Future<void> deleteTrade(String id) async {
    await _isar.writeTxn(() async {
      final trade = await _isar.trades.filter().idEqualTo(id).findFirst();
      if (trade != null) {
        await _isar.trades.delete(trade.isarId);
      }
    });
  }
}

@riverpod
Future<TradeRepository> tradeRepository(TradeRepositoryRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  return TradeRepository(isar);
}
