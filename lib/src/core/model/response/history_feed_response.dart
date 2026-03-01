class HistoryFeedResponse {
  const HistoryFeedResponse({
    required this.items,
    required this.nextCursor,
  });

  final List<Map<String, dynamic>> items;
  final DateTime? nextCursor;

  factory HistoryFeedResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = json['items'] as List<dynamic>? ?? <dynamic>[];
    return HistoryFeedResponse(
      items: rawItems
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(growable: false),
      nextCursor: DateTime.tryParse(json['next_cursor'] as String? ?? ''),
    );
  }
}

