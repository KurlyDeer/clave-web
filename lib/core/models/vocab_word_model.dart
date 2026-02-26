import 'package:hive/hive.dart';

class VocabWord {
  VocabWord({
    required this.id,
    required this.wordEn,
    required this.wordEs,
    required this.source,
    required this.createdAt,
    this.isKnown = false,
  });

  /// Hive key: normalized (lowercase, trimmed) English text for deduplication.
  final String id;
  final String wordEn;
  final String wordEs;

  /// 'sos' | 'libro'
  final String source;
  final String createdAt;
  final bool isKnown;

  VocabWord copyWith({bool? isKnown}) => VocabWord(
        id: id,
        wordEn: wordEn,
        wordEs: wordEs,
        source: source,
        createdAt: createdAt,
        isKnown: isKnown ?? this.isKnown,
      );
}

class VocabWordAdapter extends TypeAdapter<VocabWord> {
  @override
  final int typeId = 3;

  @override
  VocabWord read(BinaryReader r) => VocabWord(
        id: r.readString(),
        wordEn: r.readString(),
        wordEs: r.readString(),
        source: r.readString(),
        createdAt: r.readString(),
        isKnown: r.readBool(),
      );

  @override
  void write(BinaryWriter w, VocabWord obj) {
    w.writeString(obj.id);
    w.writeString(obj.wordEn);
    w.writeString(obj.wordEs);
    w.writeString(obj.source);
    w.writeString(obj.createdAt);
    w.writeBool(obj.isKnown);
  }
}
