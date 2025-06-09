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
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildChatList()),
            _buildMessageInput(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'AI Consultation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatHeaderDate(DateTime.now()),
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildChatBubble(message);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final bool isFromUser = message.isFromUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isFromUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: EdgeInsets.only(
                    left: isFromUser ? 40 : 0,
                    right: isFromUser ? 0 : 40,
                  ),
                  decoration: BoxDecoration(
                    color: isFromUser ? const Color(0xFF1E3A8A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isFromUser ? Colors.white : const Color(0xFF1E3A8A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF64748B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                Icons.home,
                'Home',
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                isSelected: false,
              ),
              _buildBottomNavItem(
                Icons.people_outline,
                'Community',
                onTap: () {},
                isSelected: false,
              ),
              _buildBottomNavItem(
                Icons.person_outline,
                'Profile',
                onTap: () {},
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label, {
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isFromUser: true, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response after delay
    Future.delayed(const Duration(seconds: 2), () {
      _generateAiResponse(text);
    });
  }

  void _generateAiResponse(String userMessage) {
    // This is where you would integrate with actual AI/database
    // For now, using dummy responses
    final responses = [
      "Aku mengerti perasaan kamu. Ceritakan lebih lanjut tentang apa yang sedang kamu alami.",
      "Terima kasih sudah berbagi. Bagaimana kalau kita coba teknik pernapasan untuk menenangkan diri?",
      "Perasaan yang kamu alami sangat normal. Kamu tidak sendirian dalam menghadapi ini.",
      "Mari kita cari solusi bersama. Apa yang menurutmu bisa membantu situasi ini?",
      "Aku bangga kamu mau terbuka. Langkah pertama untuk pemulihan adalah mengakui perasaan kita.",
    ];

    final response = responses[DateTime.now().millisecond % responses.length];

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isFromUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatHeaderDate(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dayName = days[date.weekday % 7];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$dayName $hour:$minute';
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

  // Methods for database integration
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isFromUser': isFromUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      isFromUser: map['isFromUser'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
