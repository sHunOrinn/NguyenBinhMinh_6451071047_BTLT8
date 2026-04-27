import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/dictionary_service.dart';
import '../utils/debouncer.dart';
import '../widget/search_bar_widget.dart';
import '../widget/word_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = DictionaryService();
  final _controller = TextEditingController();
  final _debouncer = Debouncer();

  List<Word> _results = [];
  bool _isLoading = true;
  bool _isSearching = false;
  int _totalWords = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Lần đầu: load JSON → insert SQLite nếu chưa có
    await _service.initializeIfNeeded();
    final total = await _service.totalWords();
    final initial = await _service.search('');
    setState(() {
      _totalWords = total;
      _results = initial;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _isSearching = true;
    });
    _debouncer.run(() async {
      final results = await _service.search(value);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    });
  }

  void _onClear() {
    _controller.clear();
    _onSearchChanged('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              '📖 Từ Điển Offline',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (!_isLoading)
              Text(
                '$_totalWords từ trong từ điển',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : Column(
        children: [
          // Search bar
          SearchBarWidget(
            controller: _controller,
            onChanged: _onSearchChanged,
            onClear: _onClear,
          ),
          Text('Nguyễn Bình Minh - 6451071047',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              )
          ),

          // Result count
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _isSearching
                    ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
                    : Icon(Icons.format_list_bulleted,
                    size: 16, color: colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  _query.isEmpty
                      ? 'Hiển thị 50 từ đầu tiên'
                      : 'Tìm thấy ${_results.length} kết quả cho "$_query"',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Results
          Expanded(
            child: _results.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
              itemCount: _results.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) => WordListItem(
                word: _results[index],
                highlight: _query,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Đang tải từ điển...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy từ "$_query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}