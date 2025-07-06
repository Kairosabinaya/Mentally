import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSend;
  final bool enabled;
  final bool isAiTyping;
  final String? placeholder;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.enabled = true,
    this.isAiTyping = false,
    this.placeholder,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (_hasText && widget.enabled) {
      widget.onSend(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Typing indicator
            if (widget.isAiTyping)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    _buildTypingIndicator(),
                    const SizedBox(width: 8),
                    Text(
                      'AI is typing...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Input field
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: widget.focusNode.hasFocus
                            ? AppColors.borderFocus
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      enabled: widget.enabled,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.placeholder ?? 'Type your message...',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: _hasText && widget.enabled
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: _hasText && widget.enabled ? _handleSend : null,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.send_rounded,
                          color: _hasText && widget.enabled
                              ? AppColors.textOnPrimary
                              : AppColors.surface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 24,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
