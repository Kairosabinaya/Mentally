import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_message_model.dart';

class ChatMessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final Function(ChatMessage) onRetryMessage;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.onRetryMessage,
  });

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMessageBubble(context, message),
        );
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.isUser;

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
        ],

        // Message bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              border: isUser
                  ? null
                  : Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message content
                _buildMessageContent(context, message),

                // Message footer
                _buildMessageFooter(context, message),
              ],
            ),
          ),
        ),

        if (isUser) ...[
          const SizedBox(width: 8),
          // User Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context, ChatMessage message) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context, message),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildFormattedText(message),
      ),
    );
  }

  Widget _buildFormattedText(ChatMessage message) {
    final baseStyle = TextStyle(
      fontSize: 16,
      color: message.isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
      height: 1.4,
    );

    // Parse markdown-style formatting
    final spans = _parseMarkdownText(message.content, baseStyle);

    return SelectableText.rich(TextSpan(children: spans));
  }

  List<TextSpan> _parseMarkdownText(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Handle bullet points
      if (line.trim().startsWith('* ')) {
        final bulletText = line.trim().substring(2);
        // Parse bullet text for bold formatting
        final bulletSpans = _parseBoldText('• $bulletText', baseStyle);
        spans.addAll(bulletSpans);
      } else {
        // Handle regular text with bold formatting
        spans.addAll(_parseBoldText(line, baseStyle));
      }

      // Add line break except for last line
      if (i < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }
    }

    return spans;
  }

  List<TextSpan> _parseBoldText(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before bold
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1) ?? '',
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }

    return spans;
  }

  Widget _buildMessageFooter(BuildContext context, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timestamp
          Text(
            _formatTimestamp(message.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: message.isUser
                  ? AppColors.textOnPrimary.withOpacity(0.7)
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 8),

          // Status indicator
          if (message.isUser) _buildStatusIcon(message.status),

          // Retry button for failed messages
          if (message.status == MessageStatus.failed) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => widget.onRetryMessage(message),
              child: Icon(Icons.refresh, size: 16, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = AppColors.textOnPrimary.withOpacity(0.7);
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = AppColors.textOnPrimary.withOpacity(0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = AppColors.textOnPrimary.withOpacity(0.7);
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = AppColors.error;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  void _showMessageOptions(BuildContext context, ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Copy option
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Message'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message copied to clipboard'),
                    ),
                  );
                },
              ),

              // Retry option for failed messages
              if (message.status == MessageStatus.failed)
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Retry Message'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRetryMessage(message);
                  },
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
 