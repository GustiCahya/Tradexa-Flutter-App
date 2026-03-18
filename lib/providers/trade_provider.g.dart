// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tradeStatsHash() => r'170a124dbcd41b69e8f0bd9183dcae6431b2f96d';

/// See also [tradeStats].
@ProviderFor(tradeStats)
final tradeStatsProvider = AutoDisposeStreamProvider<List<Trade>>.internal(
  tradeStats,
  name: r'tradeStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tradeStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TradeStatsRef = AutoDisposeStreamProviderRef<List<Trade>>;
String _$tradesHash() => r'0cdd9997c5a04a484376e1324004aeb8dc2c82d6';

/// See also [Trades].
@ProviderFor(Trades)
final tradesProvider =
    AutoDisposeStreamNotifierProvider<Trades, List<Trade>>.internal(
  Trades.new,
  name: r'tradesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tradesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Trades = AutoDisposeStreamNotifier<List<Trade>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
