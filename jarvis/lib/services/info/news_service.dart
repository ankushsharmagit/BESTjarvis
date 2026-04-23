// lib/services/info/news_service.dart
// News Service with NewsAPI Integration

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();
  
  final String _apiKey = AppConstants.newsApiKey;
  List<NewsArticle> _cachedNews = [];
  DateTime? _lastFetch;
  final Duration _cacheDuration = const Duration(hours: 1);
  
  Future<List<NewsArticle>> getTopHeadlines({
    String? category,
    String? country = 'in',
    int pageSize = 10,
  }) async {
    try {
      // Check cache
      if (_cachedNews.isNotEmpty && _lastFetch != null) {
        if (DateTime.now().difference(_lastFetch!) < _cacheDuration) {
          Logger().info('Returning cached news', tag: 'NEWS');
          return _cachedNews;
        }
      }
      
      final url = Uri.parse('${ApiEndpoints.newsTop}?country=$country&pageSize=$pageSize&apiKey=$_apiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = <NewsArticle>[];
        
        for (var article in data['articles']) {
          articles.add(NewsArticle.fromJson(article));
        }
        
        _cachedNews = articles;
        _lastFetch = DateTime.now();
        Logger().info('Fetched ${articles.length} news articles', tag: 'NEWS');
        return articles;
      } else {
        throw Exception('Failed to load news');
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'News Service');
      return [];
    }
  }
  
  Future<List<NewsArticle>> searchNews(String query, {int pageSize = 10}) async {
    try {
      final url = Uri.parse('${ApiEndpoints.newsEverything}?q=$query&pageSize=$pageSize&apiKey=$_apiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = <NewsArticle>[];
        
        for (var article in data['articles']) {
          articles.add(NewsArticle.fromJson(article));
        }
        
        Logger().info('Found ${articles.length} articles for: $query', tag: 'NEWS');
        return articles;
      } else {
        return [];
      }
      
    } catch (e) {
      Logger().error('Search news error', tag: 'NEWS', error: e);
      return [];
    }
  }
  
  Future<List<NewsArticle>> getNewsByCategory(String category, {int pageSize = 10}) async {
    return await getTopHeadlines(category: category, pageSize: pageSize);
  }
  
  Future<String> getNewsSummary({int count = 5}) async {
    try {
      final news = await getTopHeadlines(pageSize: count);
      if (news.isEmpty) {
        return 'Sir, abhi koi breaking news nahi hai. 📰';
      }
      
      String summary = 'Sir, top $count news headlines:\n\n';
      for (int i = 0; i < news.length; i++) {
        summary += '${i + 1}. ${news[i].title}\n';
        if (news[i].description != null && news[i].description!.isNotEmpty) {
          summary += '   ${news[i].description!.substring(0, news[i].description!.length > 80 ? 80 : news[i].description!.length)}...\n';
        }
        summary += '\n';
      }
      
      return summary;
      
    } catch (e) {
      return 'Sir, news lene mein problem hai. Thodi der mein try karo. 📰';
    }
  }
  
  Future<String> getNewsByCategorySummary(String category) async {
    try {
      final news = await getNewsByCategory(category);
      if (news.isEmpty) {
        return 'Sir, $category category mein koi news nahi hai.';
      }
      
      String summary = 'Sir, $category category ki top news:\n\n';
      for (int i = 0; i < news.length && i < 5; i++) {
        summary += '${i + 1}. ${news[i].title}\n';
      }
      
      return summary;
      
    } catch (e) {
      return 'Sir, $category news lene mein problem hai.';
    }
  }
  
  List<String> getCategories() {
    return [
      'business', 'entertainment', 'general', 'health', 
      'science', 'sports', 'technology', 'india'
    ];
  }
}

class NewsArticle {
  final String title;
  final String? description;
  final String? content;
  final String? url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? sourceName;
  final String? author;
  
  NewsArticle({
    required this.title,
    this.description,
    this.content,
    this.url,
    this.urlToImage,
    required this.publishedAt,
    this.sourceName,
    this.author,
  });
  
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title',
      description: json['description'],
      content: json['content'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.parse(json['publishedAt']),
      sourceName: json['source']?['name'],
      author: json['author'],
    );
  }
  
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }
}