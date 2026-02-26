import 'package:hive/hive.dart';

class BookPage {
  BookPage({
    required this.id,
    required this.promptEs,
    required this.promptEn,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.isReviewed = false,
  });

  final String id;
  final String promptEs;
  final String promptEn;
  final String text;

  /// ISO 8601 timestamps.
  final String createdAt;
  final String updatedAt;
  final bool isReviewed;

  BookPage copyWith({
    String? text,
    String? updatedAt,
    bool? isReviewed,
  }) {
    return BookPage(
      id: id,
      promptEs: promptEs,
      promptEn: promptEn,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}

class BookPageAdapter extends TypeAdapter<BookPage> {
  @override
  final int typeId = 2;

  @override
  BookPage read(BinaryReader r) => BookPage(
        id: r.readString(),
        promptEs: r.readString(),
        promptEn: r.readString(),
        text: r.readString(),
        createdAt: r.readString(),
        updatedAt: r.readString(),
        isReviewed: r.readBool(),
      );

  @override
  void write(BinaryWriter w, BookPage obj) {
    w.writeString(obj.id);
    w.writeString(obj.promptEs);
    w.writeString(obj.promptEn);
    w.writeString(obj.text);
    w.writeString(obj.createdAt);
    w.writeString(obj.updatedAt);
    w.writeBool(obj.isReviewed);
  }
}
