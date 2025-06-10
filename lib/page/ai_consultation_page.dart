import 'package:flutter/material.dart';

class AiConsultationPage extends StatefulWidget {
  const AiConsultationPage({super.key});

  @override
  State<AiConsultationPage> createState() => _AiConsultationPageState();
}

class _AiConsultationPageState extends State<AiConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hari ini bener-bener parah. Aku kecewa banget dan bingung harus gimana",
      isFromUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ChatMessage(
      text: "Apa yang bikin kamu ngerasa kayak gitu? Cerita aja, aku dengerin.",
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 44)),
    ),
    ChatMessage(
      text:
          "Pagi-pagi udah kacau. Aku nyoba bikin kopi tapi kopinya tumpah, terus aku ketinggalan bus. Di kantor pun aku dimarahin bos.",
      isFromUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    ChatMessage(
      text:
          "Yah, pasti rasanya nyebelin banget ya. Kadang hal-hal kecil yang berantakan di pagi hari bikin mood kita jadi hancur sepanjang hari. Gimana sekarang? Udah sempet ambil napas dulu?",
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
    ),
    ChatMessage(
      text: "Belum sih. Rasanya terlalu banyak yang numpuk di kepala.",
      isFromUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    ChatMessage(
      text:
          "Aku paham banget. Kadang-kadang kita perlu rehat bentar buat ngatur napas dan tenengin pikiran. Gimana kalau coba keluar sebentar? Lihat langit atau jalan kaki kecil aja? Itu biasanya bikin lebih lega, lho.",
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 33)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.psychology_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Mental Health Assistant',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    'Online • Ready to help',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: Column(
        children: [Expanded(child: _buildChatList()), _buildMessageInput()],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + 1, // +1 for welcome message
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildWelcomeMessage();
        }
        final message = _messages[index - 1];
        return _buildChatBubble(message);
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.psychology_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to AI Mental Health Support',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'I\'m here to listen and provide support. Feel free to share what\'s on your mind.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSuggestionChip('How are you feeling today?'),
                  _buildSuggestionChip('I need someone to talk to'),
                  _buildSuggestionChip('Help with anxiety'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final bool isFromUser = message.isFromUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.psychology_rounded,
                color: colorScheme.onPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isFromUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.only(
                    left: isFromUser ? 40 : 0,
                    right: isFromUser ? 0 : 40,
                  ),
                  color: isFromUser ? colorScheme.primary : colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isFromUser
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    left: isFromUser ? 40 : 0,
                    right: isFromUser ? 0 : 40,
                  ),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFromUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.surfaceVariant,
              child: Icon(
                Icons.person_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: _sendMessage,
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text.trim(),
          isFromUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Simulate AI response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: _generateAIResponse(_messageController.text.trim()),
              isFromUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });

    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateAIResponse(String userMessage) {
    // Simple AI response simulation
    final responses = [
      "I understand how you're feeling. Would you like to talk more about what's bothering you?",
      "That sounds challenging. Let's work through this together. What do you think might help?",
      "Thank you for sharing that with me. How are you coping with these feelings?",
      "I'm here to support you. Have you tried any breathing exercises when you feel this way?",
      "It's okay to feel this way. What usually helps you feel better when you're going through difficult times?",
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });
}
