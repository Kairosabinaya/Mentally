import 'package:equatable/equatable.dart';
import '../models/chat_message_model.dart';
import '../models/ai_consultation_model.dart';

enum AiChatStatus { initial, loading, ready, sending, typing, error }

class AiChatState extends Equatable {
  final AiChatStatus status;
  final AiConsultation? currentConsultation;
  final List<AiConsultation> consultationHistory;
  final List<String> conversationStarters;
  final String? errorMessage;
  final bool isTyping;
  final bool hasUnsavedChanges;
  final String? typingIndicatorId;

  const AiChatState({
    this.status = AiChatStatus.initial,
    this.currentConsultation,
    this.consultationHistory = const [],
    this.conversationStarters = const [],
    this.errorMessage,
    this.isTyping = false,
    this.hasUnsavedChanges = false,
    this.typingIndicatorId,
  });

  // Copy with method for immutability
  AiChatState copyWith({
    AiChatStatus? status,
    AiConsultation? currentConsultation,
    List<AiConsultation>? consultationHistory,
    List<String>? conversationStarters,
    String? errorMessage,
    bool? isTyping,
    bool? hasUnsavedChanges,
    String? typingIndicatorId,
  }) {
    return AiChatState(
      status: status ?? this.status,
      currentConsultation: currentConsultation ?? this.currentConsultation,
      consultationHistory: consultationHistory ?? this.consultationHistory,
      conversationStarters: conversationStarters ?? this.conversationStarters,
      errorMessage: errorMessage,
      isTyping: isTyping ?? this.isTyping,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      typingIndicatorId: typingIndicatorId,
    );
  }

  // Clear current consultation
  AiChatState clearCurrent() {
    return copyWith(
      currentConsultation: null,
      hasUnsavedChanges: false,
      isTyping: false,
      typingIndicatorId: null,
      errorMessage: null,
    );
  }

  // Add message to current consultation
  AiChatState addMessage(ChatMessage message) {
    if (currentConsultation == null) return this;

    return copyWith(
      currentConsultation: currentConsultation!.addMessage(message),
      hasUnsavedChanges: true,
    );
  }

  // Update last message in current consultation
  AiChatState updateLastMessage(ChatMessage message) {
    if (currentConsultation == null) return this;

    return copyWith(
      currentConsultation: currentConsultation!.updateLastMessage(message),
      hasUnsavedChanges: true,
    );
  }

  // Remove message from current consultation
  AiChatState removeMessage(String messageId) {
    if (currentConsultation == null) return this;

    final updatedMessages = currentConsultation!.messages
        .where((msg) => msg.id != messageId)
        .toList();

    return copyWith(
      currentConsultation: currentConsultation!.copyWith(
        messages: updatedMessages,
        messageCount: updatedMessages.length,
        updatedAt: DateTime.now(),
      ),
      hasUnsavedChanges: true,
    );
  }

  // Update message status
  AiChatState updateMessageStatus(String messageId, MessageStatus status) {
    if (currentConsultation == null) return this;

    final updatedMessages = currentConsultation!.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(status: status);
      }
      return msg;
    }).toList();

    return copyWith(
      currentConsultation: currentConsultation!.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      ),
      hasUnsavedChanges: true,
    );
  }

  // Add typing indicator
  AiChatState addTypingIndicator() {
    if (currentConsultation == null || typingIndicatorId != null) return this;

    final typingId = 'typing_${DateTime.now().millisecondsSinceEpoch}';
    final typingMessage = ChatMessage.typing(id: typingId);

    return copyWith(
      currentConsultation: currentConsultation!.addMessage(typingMessage),
      isTyping: true,
      typingIndicatorId: typingId,
    );
  }

  // Remove typing indicator
  AiChatState removeTypingIndicator() {
    if (currentConsultation == null || typingIndicatorId == null) {
      return copyWith(isTyping: false, typingIndicatorId: null);
    }

    final updatedMessages = currentConsultation!.messages
        .where((msg) => msg.id != typingIndicatorId)
        .toList();

    return copyWith(
      currentConsultation: currentConsultation!.copyWith(
        messages: updatedMessages,
        messageCount: updatedMessages.length,
      ),
      isTyping: false,
      typingIndicatorId: null,
    );
  }

  // Update consultation in history
  AiChatState updateConsultationInHistory(AiConsultation consultation) {
    final updatedHistory = consultationHistory.map((c) {
      if (c.id == consultation.id) {
        return consultation;
      }
      return c;
    }).toList();

    return copyWith(consultationHistory: updatedHistory);
  }

  // Remove consultation from history
  AiChatState removeConsultationFromHistory(String consultationId) {
    final updatedHistory = consultationHistory
        .where((c) => c.id != consultationId)
        .toList();

    return copyWith(consultationHistory: updatedHistory);
  }

  // Get current messages (excluding typing indicator for display)
  List<ChatMessage> get currentMessages {
    if (currentConsultation == null) return [];
    return currentConsultation!.messages;
  }

  // Get messages for AI context (excluding typing indicators)
  List<ChatMessage> get messagesForAI {
    if (currentConsultation == null) return [];
    return currentConsultation!.messages.where((msg) => !msg.isTyping).toList();
  }

  // Check if there are any messages
  bool get hasMessages {
    return currentConsultation?.messages.isNotEmpty == true;
  }

  // Check if consultation is new (no messages)
  bool get isNewConsultation {
    return currentConsultation?.messages.isEmpty == true;
  }

  // Check if AI is currently responding
  bool get isAiResponding {
    return status == AiChatStatus.sending || isTyping;
  }

  // Check if can send message
  bool get canSendMessage {
    return status != AiChatStatus.sending &&
        status != AiChatStatus.loading &&
        !isTyping;
  }

  // Get recent consultations (last 5)
  List<AiConsultation> get recentConsultations {
    return consultationHistory.take(5).toList();
  }

  // Get bookmarked consultations
  List<AiConsultation> get bookmarkedConsultations {
    return consultationHistory.where((c) => c.isBookmarked).toList();
  }

  // Get consultations by category
  List<AiConsultation> getConsultationsByCategory(
    ConsultationCategory category,
  ) {
    return consultationHistory.where((c) => c.category == category).toList();
  }

  // Get total consultation count
  int get totalConsultations => consultationHistory.length;

  // Get total message count across all consultations
  int get totalMessages {
    return consultationHistory.fold(0, (sum, c) => sum + c.messageCount);
  }

  // Get average consultation duration
  Duration get averageConsultationDuration {
    if (consultationHistory.isEmpty) return Duration.zero;

    final totalSeconds = consultationHistory.fold(
      0,
      (sum, c) => sum + c.duration.inSeconds,
    );

    return Duration(seconds: totalSeconds ~/ consultationHistory.length);
  }

  // Check if has error
  bool get hasError => status == AiChatStatus.error && errorMessage != null;

  @override
  List<Object?> get props => [
    status,
    currentConsultation,
    consultationHistory,
    conversationStarters,
    errorMessage,
    isTyping,
    hasUnsavedChanges,
    typingIndicatorId,
  ];

  @override
  bool get stringify => true;
}
