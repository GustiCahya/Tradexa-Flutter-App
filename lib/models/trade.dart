class Trade {
  final String id;
  final String userId;
  final String pair;
  final DateTime date;
  final String session;
  final String entryTF;
  final String direction;
  final double pnl;
  final double rr;
  final String day;
  final String emotion;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trade({
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
    return Trade(
      id: json['id'],
      userId: json['userId'],
      pair: json['pair'],
      date: DateTime.parse(json['date']).toLocal(),
      session: json['session'],
      entryTF: json['entryTF'],
      direction: json['direction'],
      pnl: (json['pnl'] as num).toDouble(),
      rr: (json['rr'] as num).toDouble(),
      day: json['day'],
      emotion: json['emotion'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
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
