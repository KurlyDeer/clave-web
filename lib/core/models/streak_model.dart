import 'package:hive/hive.dart';

class StreakData {
  const StreakData({
    required this.lastPracticeDate,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// Date of last practice in 'YYYY-MM-DD' format.
  final String lastPracticeDate;
  final int currentStreak;
  final int longestStreak;
}

class StreakDataAdapter extends TypeAdapter<StreakData> {
  @override
  final int typeId = 1;

  @override
  StreakData read(BinaryReader r) => StreakData(
        lastPracticeDate: r.readString(),
        currentStreak: r.readInt(),
        longestStreak: r.readInt(),
      );

  @override
  void write(BinaryWriter w, StreakData obj) {
    w.writeString(obj.lastPracticeDate);
    w.writeInt(obj.currentStreak);
    w.writeInt(obj.longestStreak);
  }
}
