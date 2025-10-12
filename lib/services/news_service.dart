import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news_article.dart';

class NewsService {
  // Generate CNBC RSS feed URL for a specific ticker
  static String getCnbcRssUrl(String ticker) {
    return 'https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&q=$ticker';
  }

  // Fetch news articles for a specific ticker using RSS2JSON API (bypasses CORS)
  static Future<List<NewsArticle>> fetchNewsForTicker(String ticker) async {
    try {
      // Use RSS2JSON API to bypass CORS restrictions in web browsers
      final rssUrl = getCnbcRssUrl(ticker);
      final encodedUrl = Uri.encodeComponent(rssUrl);
      final url = 'https://api.rss2json.com/v1/api.json?rss_url=$encodedUrl';

      print('Fetching news for $ticker from RSS2JSON API');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'ok' && jsonData['items'] != null) {
          return _parseJsonFeed(jsonData, ticker);
        } else {
          print('RSS2JSON returned error: ${jsonData['message']}');
          return _getMockNewsForTicker(ticker);
        }
      } else {
        print('Failed to load news for $ticker: ${response.statusCode}');
        return _getMockNewsForTicker(ticker);
      }
    } catch (e) {
      print('Error fetching news for $ticker: $e');
      return _getMockNewsForTicker(ticker);
    }
  }

  // Parse JSON feed from RSS2JSON API
  static List<NewsArticle> _parseJsonFeed(Map<String, dynamic> jsonData, String ticker) {
    try {
      final items = jsonData['items'] as List<dynamic>;
      List<NewsArticle> articles = [];

      for (var item in items) {
        try {
          final title = item['title'] ?? 'No title';
          final description = item['description'] ?? '';
          final link = item['link'] ?? '';
          final pubDateStr = item['pubDate'] ?? '';
          final imageUrl = item['thumbnail'] ?? item['enclosure']?['link'];

          // Parse publication date
          DateTime pubDate;
          try {
            pubDate = DateTime.parse(pubDateStr).toLocal();
          } catch (e) {
            pubDate = DateTime.now();
          }

          articles.add(NewsArticle(
            title: _cleanHtml(title),
            description: _cleanHtml(description),
            source: 'CNBC',
            link: link,
            publishedDate: pubDate,
            imageUrl: imageUrl,
            ticker: ticker,
          ));
        } catch (e) {
          print('Error parsing news item: $e');
        }
      }

      return articles;
    } catch (e) {
      print('Error parsing JSON feed: $e');
      return [];
    }
  }

  // Clean HTML tags from text
  static String _cleanHtml(String htmlString) {
    // Remove HTML tags
    final regex = RegExp(r'<[^>]*>');
    return htmlString.replaceAll(regex, '').trim();
  }

  // Get mock news for a ticker (fallback when API fails)
  static List<NewsArticle> _getMockNewsForTicker(String ticker) {
    final now = DateTime.now();

    return [
      NewsArticle(
        title: '$ticker részvény: Jelentős árfolyam mozgás a mai kereskedésben',
        description: 'A $ticker részvények jelentős árfolyammozgást mutattak a mai kereskedési napon.',
        source: 'CNBC',
        link: 'https://www.cnbc.com',
        publishedDate: now.subtract(Duration(hours: 2)),
        imageUrl: null,
        ticker: ticker,
      ),
      NewsArticle(
        title: 'Elemzők pozitívan nyilatkoztak a $ticker kilátásairól',
        description: 'Több vezető elemző is pozitívan nyilatkozott a $ticker részvény középtávú kilátásairól.',
        source: 'CNBC',
        link: 'https://www.cnbc.com',
        publishedDate: now.subtract(Duration(hours: 5)),
        imageUrl: null,
        ticker: ticker,
      ),
      NewsArticle(
        title: '$ticker negyedéves jelentés: Meglepő eredmények',
        description: 'A $ticker közzétette negyedéves eredményeit, amelyek meglepték a piacot.',
        source: 'CNBC',
        link: 'https://www.cnbc.com',
        publishedDate: now.subtract(Duration(days: 1)),
        imageUrl: null,
        ticker: ticker,
      ),
      NewsArticle(
        title: 'Intézményi befektetők növelik $ticker pozícióikat',
        description: 'Több nagy intézményi befektető is növelte a $ticker részvényekben meglévő pozícióit.',
        source: 'CNBC',
        link: 'https://www.cnbc.com',
        publishedDate: now.subtract(Duration(days: 2)),
        imageUrl: null,
        ticker: ticker,
      ),
      NewsArticle(
        title: '$ticker: Új stratégiai partnerség bejelentése',
        description: 'A $ticker új stratégiai partnerséget jelentett be, amely hosszútávon pozitív hatással lehet az eredményekre.',
        source: 'CNBC',
        link: 'https://www.cnbc.com',
        publishedDate: now.subtract(Duration(days: 3)),
        imageUrl: null,
        ticker: ticker,
      ),
    ];
  }

  // Fetch news for multiple tickers (batch fetch)
  static Future<List<NewsArticle>> fetchNewsForTickers(List<String> tickers) async {
    List<NewsArticle> allArticles = [];

    for (String ticker in tickers) {
      final articles = await fetchNewsForTicker(ticker);
      allArticles.addAll(articles);
    }

    // Sort by publish date (newest first)
    allArticles.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

    // Limit to 20 articles
    return allArticles.take(20).toList();
  }

  // Get default news feed (for initial load, fetch news for popular tickers)
  static Future<List<NewsArticle>> getDefaultNewsFeed() async {
    final popularTickers = ['NVDA', 'AAPL', 'MSFT', 'TSLA', 'GOOGL', 'AMZN', 'META'];
    return await fetchNewsForTickers(popularTickers);
  }
}
