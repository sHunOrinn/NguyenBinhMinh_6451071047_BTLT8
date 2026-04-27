import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word.dart';
import 'database_service.dart';

class DictionaryService {
  final DatabaseService _db = DatabaseService();

  /// Gọi khi app khởi động: nếu DB chưa có data thì đọc JSON và insert
  Future<void> initializeIfNeeded() async {
    try {
      final populated = await _db.isPopulated();
      if (!populated) {
        await _loadFromJson();
      }
    } catch (e) {
      // Nếu lỗi (vd: bảng chưa tồn tại), thử load lại
      await _loadFromJson();
    }
  }

  Future<void> _loadFromJson() async {
    final jsonString =
    await rootBundle.loadString('assets/words.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final words = jsonList
        .map((e) => Word.fromJson(e as Map<String, dynamic>))
        .toList();
    await _db.insertWords(words);
  }

  Future<List<Word>> search(String query) => _db.searchWords(query);

  Future<int> totalWords() => _db.totalWords();
}