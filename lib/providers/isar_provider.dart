import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/trade.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();

  if (Isar.instanceNames.isNotEmpty) {
    return Isar.getInstance()!;
  }

  return await Isar.open([TradeSchema], directory: dir.path);
}
