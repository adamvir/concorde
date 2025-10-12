import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';
import '../data/market_stocks_data.dart';

// Widget a teljes hírek oldalhoz
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: NewsContent(),
      ),
    );
  }
}

// Hírek tartalom widget (ezt használjuk a main navigation-ben)
class NewsContent extends StatefulWidget {
  const NewsContent({super.key});

  @override
  _NewsContentState createState() => _NewsContentState();
}

class _NewsContentState extends State<NewsContent> {
  String _selectedNewsletter = 'Concorde napi hírlevél';
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _currentTicker;

  @override
  void initState() {
    super.initState();
    _loadDefaultNews();
  }

  // Load default news feed
  Future<void> _loadDefaultNews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articles = await NewsService.getDefaultNewsFeed();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading default news: $e');
    }
  }

  // Load news for a specific ticker
  Future<void> _loadNewsForTicker(String ticker) async {
    setState(() {
      _isLoading = true;
      _currentTicker = ticker;
    });

    try {
      final articles = await NewsService.fetchNewsForTicker(ticker);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading news for $ticker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with logo, title, search and notification icons
        _buildHeader(),

        // Newsletter dropdown selector
        _buildNewsletterSelector(),

        const SizedBox(height: 8),

        // News feed
        Expanded(
          child: _buildNewsFeed(),
        ),
      ],
    );
  }

  // Build header with Concorde logo, title, search and bell icons
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          // Concorde logo
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(4),
            child: SvgPicture.asset(
              'lib/assets/images/concorde.svg',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Hírek',
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.27,
                ),
              ),
            ),
          ),
          // Search icon
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(
                TablerIcons.search,
                color: const Color(0xFF45556C),
                size: 24,
              ),
              onPressed: () {
                _showTickerSearch();
              },
            ),
          ),
          // Notification bell icon
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(
                TablerIcons.bell,
                color: const Color(0xFF45556C),
                size: 24,
              ),
              onPressed: () {
                // TODO: Show notifications/announcements
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build newsletter dropdown selector
  Widget _buildNewsletterSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: const Color(0xFFCAD5E2),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showNewsletterPicker();
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedNewsletter,
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                  Icon(
                    TablerIcons.chevron_down,
                    color: const Color(0xFF45556C),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show newsletter picker dialog
  void _showNewsletterPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Válassz hírlevelet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Concorde napi hírlevél'),
                onTap: () {
                  setState(() {
                    _selectedNewsletter = 'Concorde napi hírlevél';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Tech hírek'),
                onTap: () {
                  setState(() {
                    _selectedNewsletter = 'Tech hírek';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Piaci elemzések'),
                onTap: () {
                  setState(() {
                    _selectedNewsletter = 'Piaci elemzések';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show ticker search dialog
  void _showTickerSearch() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Keresés ticker alapján',
                        style: TextStyle(
                          color: const Color(0xFF1D293D),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(TablerIcons.x, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Írd be a ticker kódot (pl. NVDA, AAPL)',
                    prefixIcon: Icon(TablerIcons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: const Color(0xFFCAD5E2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: const Color(0xFFE17100), width: 2),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.pop(context);
                      _loadNewsForTicker(value.trim().toUpperCase());
                    }
                  },
                ),
              ),
              // Stock list
              Expanded(
                child: ListView.builder(
                  itemCount: MarketStocksData.allStocks.length,
                  itemBuilder: (context, index) {
                    final stock = MarketStocksData.allStocks[index];
                    return ListTile(
                      title: Text(
                        stock.ticker,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      subtitle: Text(
                        stock.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _loadNewsForTicker(stock.ticker);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build news feed with article cards
  Widget _buildNewsFeed() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFFE17100),
        ),
      );
    }

    if (_articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.news_off,
              size: 64,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              _currentTicker != null
                  ? 'Nincs elérhető hír a $_currentTicker tickerhez'
                  : 'Nincs elérhető hír',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDefaultNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE17100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Újratöltés',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: ListView.builder(
        itemCount: _articles.length + 1,
        itemBuilder: (context, index) {
          if (index == _articles.length) {
            return Column(
              children: [
                const SizedBox(height: 16),
                _buildLoadMoreButton(),
              ],
            );
          }

          final article = _articles[index];
          return _buildNewsArticleFromModel(
            article: article,
            isLast: index == _articles.length - 1,
          );
        },
      ),
    );
  }

  // Build individual news article card
  Widget _buildNewsArticle({
    required String title,
    required String source,
    required String date,
    String? time,
    required String imageUrl,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: isLast ? 0 : 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to article detail page
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Source and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          source,
                          style: TextStyle(
                            color: const Color(0xFFE17100),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                            if (time != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Article image
              Container(
                width: 80,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build news article card from NewsArticle model
  Widget _buildNewsArticleFromModel({
    required NewsArticle article,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: isLast ? 0 : 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Open article link in browser or webview
            // TODO: Implement article detail page navigation
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      article.title,
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Source and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            article.source,
                            style: TextStyle(
                              color: const Color(0xFFE17100),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.43,
                              letterSpacing: 0.10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              article.getFormattedDate(),
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                            if (article.getFormattedTime() != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                article.getFormattedTime()!,
                                style: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Article image
              Container(
                width: 80,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  image: article.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(article.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: article.imageUrl == null
                    ? Icon(
                        TablerIcons.news,
                        color: const Color(0xFF94A3B8),
                        size: 32,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build "Még több hír" (Load more) button
  Widget _buildLoadMoreButton() {
    return Container(
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Load more news articles
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  TablerIcons.arrow_right,
                  color: const Color(0xFF45556C),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Még több hír',
                  style: TextStyle(
                    color: const Color(0xFF45556C),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
