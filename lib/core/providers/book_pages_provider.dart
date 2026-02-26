import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/book_page_model.dart';

// ── Box provider (overridden in main.dart) ────────────────────────────────────

final bookPagesBoxProvider = Provider<Box<BookPage>>((ref) {
  throw UnimplementedError('bookPagesBoxProvider must be overridden in main.dart');
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class BookPagesNotifier extends StateNotifier<List<BookPage>> {
  BookPagesNotifier(this._box) : super(_sorted(_box.values.toList()));

  final Box<BookPage> _box;

  static List<BookPage> _sorted(List<BookPage> pages) {
    final list = List<BookPage>.from(pages);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> savePage(BookPage page) async {
    await _box.put(page.id, page);
    state = _sorted(_box.values.toList());
  }

  Future<void> updatePage(BookPage page) async {
    await _box.put(page.id, page);
    state = _sorted(_box.values.toList());
  }

  Future<void> deletePage(String id) async {
    await _box.delete(id);
    state = _sorted(_box.values.toList());
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final bookPagesProvider =
    StateNotifierProvider<BookPagesNotifier, List<BookPage>>((ref) {
  final box = ref.watch(bookPagesBoxProvider);
  return BookPagesNotifier(box);
});

final bookPageCountProvider = Provider<int>((ref) {
  return ref.watch(bookPagesProvider).length;
});
