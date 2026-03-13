import 'package:isar/isar.dart';

part 'trade.g.dart';

@collection
class Trade {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;
  late String userId;

  @Index(type: IndexType.value)
  late String pair;

  @Index(type: IndexType.value)
  late DateTime date;

  late String session;
  late String entryTF;
  late String direction;
  late double pnl;
  late double rr;
  late String day;
  late String emotion;
  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;

  // Empty constructor for Isar
  Trade();

  // Convenience constructor to ease migration
  Trade.create({
    required this.id,
    required this.userId,
    required this.pair,
    required this.date,
    required this.session,
    required this.entryTF,
    required this.direction,
    required this.pnl,
    required this.rr,
    required this.day,
    required this.emotion,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade.create(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      pair: json['pair']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date']).toLocal()
          : DateTime.now(),
      session: json['session']?.toString() ?? '',
      entryTF: json['entryTF']?.toString() ?? '',
      direction: json['direction']?.toString() ?? '',
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      rr: (json['rr'] as num?)?.toDouble() ?? 0.0,
      day: json['day']?.toString() ?? '',
      emotion: json['emotion']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pair': pair,
      'date': date.toUtc().toIso8601String(),
      'session': session,
      'entryTF': entryTF,
      'direction': direction,
      'pnl': pnl,
      'rr': rr,
      'day': day,
      'emotion': emotion,
      'notes': notes,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
