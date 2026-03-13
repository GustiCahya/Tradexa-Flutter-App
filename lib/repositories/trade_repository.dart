import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/trade.dart';
import '../services/api_service.dart';
import '../providers/api_provider.dart';
import '../providers/isar_provider.dart';

part 'trade_repository.g.dart';

class TradeRepository {
  final ApiService _api;
  final Isar _isar;

  TradeRepository(this._api, this._isar);

  /// Exposes a continuous stream of trades from Isar DB.
  Stream<List<Trade>> watchTrades() {
    return _isar.trades.where().sortByDateDesc().watch(fireImmediately: true);
  }

  /// Performs a remote fetch via API and updates the Isar DB on success.
  Future<void> syncWithRemote() async {
    try {
      final response = await _api.get('/trades');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List tradesList = decoded['trades'] ?? [];

        final remoteTrades = tradesList
            .whereType<Map<String, dynamic>>()
            .map((e) => Trade.fromJson(e))
            .toList();

        await _isar.writeTxn(() async {
          await _isar.trades.putAll(remoteTrades);
        });
      }
    } catch (e) {
      // Background sync failed, ignore or log
    }
  }

  /// Create a trade locally immediately, then sync to server
  Future<void> createTrade(Trade trade) async {
    // 1. Save locally for instant UI update
    await _isar.writeTxn(() async {
      await _isar.trades.put(trade);
    });

    // 2. Sync to backend silently
    try {
      await _api.post('/trades', trade.toJson());
      await syncWithRemote(); // Refresh to get proper ID and createdAt from backend
    } catch (e) {
      // Depending on requirements, we could flag it as "pending sync" in Isar
    }
  }

  /// Update a trade locally immediately, then sync to server
  Future<void> updateTrade(Trade trade) async {
    await _isar.writeTxn(() async {
      await _isar.trades.put(trade);
    });

    try {
      await _api.put('/trades', trade.toJson());
      await syncWithRemote();
    } catch (e) {
      // Error handling
    }
  }

  /// Delete a trade locally immediately, then sync
  Future<void> deleteTrade(String id) async {
    await _isar.writeTxn(() async {
      // Find the trade by its string ID index to get its integer isarId
      final trade = await _isar.trades.filter().idEqualTo(id).findFirst();
      if (trade != null) {
        await _isar.trades.delete(trade.isarId);
      }
    });

    try {
      await _api.delete('/trades/$id');
    } catch (e) {
      // Error handling
    }
  }
}

@riverpod
Future<TradeRepository> tradeRepository(TradeRepositoryRef ref) async {
  final api = ref.watch(apiServiceProvider);
  final isar = await ref.watch(isarProvider.future);
  return TradeRepository(api, isar);
}
