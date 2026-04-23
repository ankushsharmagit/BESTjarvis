// lib/widgets/typing_text_widget.dart
// Typewriter Animation Widget

import 'package:flutter/material.dart';
import 'dart:async';
import '../config/colors.dart';

class TypingTextWidget extends StatefulWidget {
  final String text;
  final Duration speed;
  final TextStyle? style;
  final VoidCallback? onComplete;
  final bool showCursor;
  final int delayBeforeStart;
  
  const TypingTextWidget({
    Key? key,
    required this.text,
    this.speed = const Duration(milliseconds: 50),
    this.style,
    this.onComplete,
    this.showCursor = true,
    this.delayBeforeStart = 0,
  }) : super(key: key);

  @override
  State<TypingTextWidget> createState() => _TypingTextWidgetState();
}

class _TypingTextWidgetState extends State<TypingTextWidget>
    with SingleTickerProviderStateMixin {
  
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;
  Timer? _delayTimer;
  bool _isTyping = true;
  late AnimationController _cursorController;
  
  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    
    _startTyping();
  }
  
  void _startTyping() {
    _delayTimer = Timer(Duration(milliseconds: widget.delayBeforeStart), () {
      _timer = Timer.periodic(widget.speed, (timer) {
        if (_currentIndex < widget.text.length) {
          setState(() {
            _displayedText += widget.text[_currentIndex];
            _currentIndex++;
          });
        } else {
          _timer?.cancel();
          _isTyping = false;
          widget.onComplete?.call();
        }
      });
    });
  }
  
  @override
  void didUpdateWidget(TypingTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _resetAndStart();
    }
  }
  
  void _resetAndStart() {
    _timer?.cancel();
    _delayTimer?.cancel();
    setState(() {
      _displayedText = '';
      _currentIndex = 0;
      _isTyping = true;
    });
    _startTyping();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _delayTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            _displayedText,
            style: widget.style ?? const TextStyle(color: Colors.white, fontSize: 16),
            softWrap: true,
          ),
        ),
        if (widget.showCursor && _isTyping)
          AnimatedBuilder(
            animation: _cursorController,
            builder: (context, child) {
              return Opacity(
                opacity: _cursorController.value,
                child: Container(
                  width: 2,
                  height: 20,
                  color: JarvisColors.accentCyan,
                  margin: const EdgeInsets.only(left: 2),
                ),
              );
            },
          ),
      ],
    );
  }
}