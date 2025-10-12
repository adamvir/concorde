// News article model for RSS feed data
class NewsArticle {
  final String title;
  final String description;
  final String source;
  final String link;
  final DateTime publishedDate;
  final String? imageUrl;
  final String ticker;

  NewsArticle({
    required this.title,
    required this.description,
    required this.source,
    required this.link,
    required this.publishedDate,
    this.imageUrl,
    required this.ticker,
  });

  // Format date for display (e.g., "Ma 18:36" or "2025.03.14.")
  String getFormattedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final articleDate = DateTime(publishedDate.year, publishedDate.month, publishedDate.day);

    if (articleDate == today) {
      return 'Ma';
    } else {
      return '${publishedDate.year}.${publishedDate.month.toString().padLeft(2, '0')}.${publishedDate.day.toString().padLeft(2, '0')}.';
    }
  }

  // Format time for display (e.g., "18:36")
  String? getFormattedTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final articleDate = DateTime(publishedDate.year, publishedDate.month, publishedDate.day);

    if (articleDate == today) {
      return '${publishedDate.hour.toString().padLeft(2, '0')}:${publishedDate.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  // Factory method to create from RSS XML item
  factory NewsArticle.fromRssItem(Map<String, dynamic> item, String ticker) {
    return NewsArticle(
      title: item['title'] ?? 'No title',
      description: item['description'] ?? '',
      source: item['source'] ?? 'CNBC',
      link: item['link'] ?? '',
      publishedDate: item['pubDate'] != null
          ? DateTime.parse(item['pubDate'])
          : DateTime.now(),
      imageUrl: item['imageUrl'],
      ticker: ticker,
    );
  }
}
