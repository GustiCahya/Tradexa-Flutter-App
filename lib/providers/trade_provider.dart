import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/trade.dart';
import '../repositories/trade_repository.dart';

part 'trade_provider.g.dart';

@riverpod
class Trades extends _$Trades {
  @override
  Stream<List<Trade>> build() async* {
    final repository = await ref.watch(tradeRepositoryProvider.future);

    // Yield the Isar stream directly. No background sync.
    yield* repository.watchTrades();
  }

  Future<void> addTrade(Trade trade) async {
    final repository = await ref.read(tradeRepositoryProvider.future);
    await repository.createTrade(trade);
  }

  Future<void> updateTrade(Trade trade) async {
    final repository = await ref.read(tradeRepositoryProvider.future);
    await repository.updateTrade(trade);
  }

  Future<void> deleteTrade(String id) async {
    final repository = await ref.read(tradeRepositoryProvider.future);
    await repository.deleteTrade(id);
  }

  Future<void> forceRefresh() async {
    // No-op for 100% offline mode
  }
}
