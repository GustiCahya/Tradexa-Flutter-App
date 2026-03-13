import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/trade.dart';
import '../repositories/trade_repository.dart';

part 'trade_provider.g.dart';

@riverpod
class Trades extends _$Trades {
  @override
  Stream<List<Trade>> build() async* {
    final repository = await ref.watch(tradeRepositoryProvider.future);

    // Fire and forget background sync to ensure data is fresh
    _silentSync(repository);

    // Yield the Isar stream
    yield* repository.watchTrades();
  }

  Future<void> _silentSync(TradeRepository repository) async {
    try {
      await repository.syncWithRemote();
    } catch (e) {
      debugPrint('Background silent sync failed: $e');
    }
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
    final repository = await ref.read(tradeRepositoryProvider.future);
    await repository.syncWithRemote();
  }
}
