import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/trade.dart';
import '../providers/isar_provider.dart';

part 'trade_repository.g.dart';

class TradeRepository {
  final Isar _isar;

  TradeRepository(this._isar);

  /// Exposes a continuous stream of trades from Isar DB.
  Stream<List<Trade>> watchTrades() {
    return _isar.trades.where().sortByDateDesc().watch(fireImmediately: true);
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
