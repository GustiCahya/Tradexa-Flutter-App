import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/trade.dart';
import '../repositories/trade_repository.dart';
import 'trade_filter_provider.dart';

part 'trade_provider.g.dart';

@riverpod
class Trades extends _$Trades {
  @override
  Stream<List<Trade>> build() async* {
    final filter = ref.watch(tradeFilterNotifierProvider);
    final repository = await ref.watch(tradeRepositoryProvider.future);

    // Yield the Isar stream with apply limit and filters
    yield* repository.watchFilteredTrades(filter);
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

@riverpod
Stream<List<Trade>> tradeStats(TradeStatsRef ref) async* {
  final filter = ref.watch(tradeFilterNotifierProvider);
  final repository = await ref.watch(tradeRepositoryProvider.future);
  yield* repository.watchFilteredStats(filter);
}
