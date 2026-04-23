// lib/screens/chat_history_screen.dart
// Full Chat History Screen with Search

import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/chat_message.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/chat_bubble_widget.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatMessage> _messages = [];
  List<ChatMessage> _filteredMessages = [];
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }
  
  void _loadChatHistory() {
    // Load from database
    _messages = [
      ChatMessage(
        id: '1',
        content: 'Hello JARVIS!',
        type: MessageType.command,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isFromUser: true,
      ),
      ChatMessage(
        id: '2',
        content: 'Namaste Sir! Main JARVIS hoon. Kaise hain aap? 🚀',
        type: MessageType.response,
        timestamp: DateTime.now().subtract(const Duration(minutes: 58)),
        isFromUser: false,
      ),
      ChatMessage(
        id: '3',
        content: 'What is the weather today?',
        type: MessageType.command,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isFromUser: true,
      ),
      ChatMessage(
        id: '4',
        content: 'Sir, weather is clear and sunny. Temperature 28°C. ☀️',
        type: MessageType.response,
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        isFromUser: false,
      ),
    ];
    _filteredMessages = List.from(_messages);
  }
  
  void _filterMessages(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMessages = List.from(_messages);
      } else {
        _filteredMessages = _messages.where((msg) =>
          msg.content.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }
  
  void _clearSearch() {
    _searchController.clear();
    _filterMessages('');
    setState(() {
      _isSearching = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(color: JarvisColors.textHint),
                  border: InputBorder.none,
                ),
                onChanged: _filterMessages,
              )
            : const Text('Chat History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: JarvisColors.accentCyan),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: JarvisColors.accentCyan),
              onPressed: _clearSearch,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: JarvisColors.accentCyan),
            onPressed: () {
              _showDeleteDialog();
            },
          ),
        ],
      ),
      body: _filteredMessages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: JarvisColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No chat history yet'
                        : 'No messages found for "$_searchQuery"',
                    style: TextStyle(color: JarvisColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMessages.length,
              itemBuilder: (context, index) {
                final message = _filteredMessages[index];
                return ChatBubbleWidget(
                  message: message,
                  isUser: message.isFromUser,
                );
              },
            ),
    );
  }
  
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all chat history?'),
        backgroundColor: JarvisColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: JarvisColors.accentCyan),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _filteredMessages.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}