import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_banner.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/ai_chat_event.dart';
import '../bloc/ai_chat_state.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/conversation_starters.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/consultation_end_dialog.dart';
import '../models/ai_consultation_model.dart';

class AiChatPage extends StatefulWidget {
  final String? consultationId;
  final ConsultationCategory? category;
  final double? initialMood;
  final String? initialMessage;

  const AiChatPage({
    super.key,
    this.consultationId,
    this.category,
    this.initialMood,
    this.initialMessage,
  });

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();

    // Listen for keyboard visibility changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageFocusNode.addListener(_onFocusChange);
    });
  }

  void _initializeChat() {
    final bloc = context.read<AiChatBloc>();

    // Always initialize and load history first
    bloc.add(const AiChatInitializeEvent());

    if (widget.consultationId != null) {
      // Load existing consultation
      bloc.add(AiChatLoadConsultationEvent(widget.consultationId!));
    } else {
      // Start new consultation
      bloc.add(
        AiChatStartConsultationEvent(
          category: widget.category ?? ConsultationCategory.general,
          moodBefore: widget.initialMood,
          initialMessage: widget.initialMessage,
        ),
      );
    }
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _messageFocusNode.hasFocus;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    context.read<AiChatBloc>().add(AiChatSendMessageEvent(message.trim()));
    _messageController.clear();

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _onStarterTap(String starter) {
    _messageController.text = starter;
    _messageFocusNode.requestFocus();
  }

  void _showEndConsultationDialog() {
    showDialog(
      context: context,
      builder: (context) => ConsultationEndDialog(
        onEnd: (moodAfter, notes) {
          context.read<AiChatBloc>().add(
            AiChatEndConsultationEvent(moodAfter: moodAfter, notes: notes),
          );
          context.pop(); // Close dialog
          context.pop(); // Close chat page
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listener: (context, state) {
        // Auto-scroll when new messages arrive
        if (state.hasMessages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        // Handle errors
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ChatAppBar(
            consultation: state.currentConsultation,
            onEndPressed: _showEndConsultationDialog,
          ),
          body: LoadingOverlay(
            isLoading: state.status == AiChatStatus.loading,
            child: Column(
              children: [
                // Error banner
                if (state.hasError)
                  ErrorBanner(
                    message: state.errorMessage!,
                    onRetry: () {
                      context.read<AiChatBloc>().add(
                        const AiChatInitializeEvent(),
                      );
                    },
                  ),

                // Chat content
                Expanded(
                  child: state.hasMessages
                      ? ChatMessageList(
                          messages: state.currentMessages,
                          scrollController: _scrollController,
                          onRetryMessage: (message) {
                            context.read<AiChatBloc>().add(
                              AiChatRetryMessageEvent(message),
                            );
                          },
                        )
                      : ConversationStarters(
                          starters: state.conversationStarters,
                          category:
                              state.currentConsultation?.category ??
                              ConsultationCategory.general,
                          onStarterTap: _onStarterTap,
                        ),
                ),

                // Input field
                ChatInputField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  onSend: _sendMessage,
                  enabled: state.canSendMessage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extension for consultation category display
extension ConsultationCategoryExtension on ConsultationCategory {
  String get displayName {
    switch (this) {
      case ConsultationCategory.general:
        return 'General Support';
      case ConsultationCategory.anxiety:
        return 'Anxiety & Panic';
      case ConsultationCategory.depression:
        return 'Depression & Mood';
      case ConsultationCategory.stress:
        return 'Stress Management';
      case ConsultationCategory.relationships:
        return 'Relationships';
      case ConsultationCategory.sleep:
        return 'Sleep Issues';
      case ConsultationCategory.selfEsteem:
        return 'Self-Care';
      case ConsultationCategory.grief:
        return 'Grief & Loss';
      case ConsultationCategory.trauma:
        return 'Trauma & PTSD';
      case ConsultationCategory.addiction:
        return 'Addiction Recovery';
    }
  }

  String get description {
    switch (this) {
      case ConsultationCategory.general:
        return 'General mental health support and guidance';
      case ConsultationCategory.anxiety:
        return 'Help with anxiety and panic attacks';
      case ConsultationCategory.depression:
        return 'Support for depression and mood disorders';
      case ConsultationCategory.stress:
        return 'Stress management and coping strategies';
      case ConsultationCategory.relationships:
        return 'Relationship and social interaction guidance';
      case ConsultationCategory.sleep:
        return 'Sleep problems and insomnia support';
      case ConsultationCategory.selfEsteem:
        return 'Self-care strategies and wellness tips';
      case ConsultationCategory.grief:
        return 'Grief processing and loss support';
      case ConsultationCategory.trauma:
        return 'Trauma processing and PTSD support';
      case ConsultationCategory.addiction:
        return 'Addiction recovery and substance abuse help';
    }
  }
}
 