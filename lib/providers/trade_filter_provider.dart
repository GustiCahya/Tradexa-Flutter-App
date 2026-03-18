import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trade_filter_provider.g.dart';

enum TradeSortField { date, pnl, rr }

class TradeFilter {
  final int limit;
  final String? pair;
  final String? direction;
  final String? session;
  final String? emotion;
  final TradeSortField sortField;
  final bool sortAscending; // false = desc (Newest/Highest)

  const TradeFilter({
    this.limit = 20,
    this.pair,
    this.direction,
    this.session,
    this.emotion,
    this.sortField = TradeSortField.date,
    this.sortAscending = false,
  });

  TradeFilter copyWith({
    int? limit,
    String? pair,
    String? direction,
    String? session,
    String? emotion,
    TradeSortField? sortField,
    bool? sortAscending,
    bool clearPair = false,
    bool clearDirection = false,
    bool clearSession = false,
    bool clearEmotion = false,
  }) {
    return TradeFilter(
      limit: limit ?? this.limit,
      pair: clearPair ? null : (pair ?? this.pair),
      direction: clearDirection ? null : (direction ?? this.direction),
      session: clearSession ? null : (session ?? this.session),
      emotion: clearEmotion ? null : (emotion ?? this.emotion),
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

@riverpod
class TradeFilterNotifier extends _$TradeFilterNotifier {
  @override
  TradeFilter build() => const TradeFilter();

  void updateFilter({
    int? limit,
    String? pair,
    String? direction,
    String? session,
    String? emotion,
    TradeSortField? sortField,
    bool? sortAscending,
  }) {
    state = state.copyWith(
      limit: limit,
      pair: pair,
      clearPair: pair == 'All',
      direction: direction,
      clearDirection: direction == 'All',
      session: session,
      clearSession: session == 'All',
      emotion: emotion,
      clearEmotion: emotion == 'All',
      sortField: sortField,
      sortAscending: sortAscending,
    );
  }

  void loadMore() {
    state = state.copyWith(limit: state.limit + 20);
  }

  void resetLimit() {
    state = state.copyWith(limit: 20);
  }

  void reset() {
    state = const TradeFilter();
  }
}
