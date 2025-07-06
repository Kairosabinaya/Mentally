import 'package:equatable/equatable.dart';
import '../models/ai_consultation_model.dart';
import '../models/chat_message_model.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

class AiChatInitializeEvent extends AiChatEvent {
  const AiChatInitializeEvent();
}

class AiChatStartConsultationEvent extends AiChatEvent {
  final ConsultationCategory category;
  final String? initialMessage;
  final double? moodBefore;

  const AiChatStartConsultationEvent({
    required this.category,
    this.initialMessage,
    this.moodBefore,
  });

  @override
  List<Object?> get props => [category, initialMessage, moodBefore];
}

class AiChatLoadConsultationEvent extends AiChatEvent {
  final String consultationId;

  const AiChatLoadConsultationEvent(this.consultationId);

  @override
  List<Object?> get props => [consultationId];
}

class AiChatSendMessageEvent extends AiChatEvent {
  final String message;

  const AiChatSendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class AiChatRetryMessageEvent extends AiChatEvent {
  final ChatMessage message;

  const AiChatRetryMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class AiChatDeleteMessageEvent extends AiChatEvent {
  final String messageId;

  const AiChatDeleteMessageEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class AiChatUpdateMessageStatusEvent extends AiChatEvent {
  final String messageId;
  final MessageStatus status;

  const AiChatUpdateMessageStatusEvent({
    required this.messageId,
    required this.status,
  });

  @override
  List<Object?> get props => [messageId, status];
}

class AiChatSaveConsultationEvent extends AiChatEvent {
  const AiChatSaveConsultationEvent();
}

class AiChatEndConsultationEvent extends AiChatEvent {
  final double? moodAfter;
  final String? notes;

  const AiChatEndConsultationEvent({this.moodAfter, this.notes});

  @override
  List<Object?> get props => [moodAfter, notes];
}

class AiChatLoadHistoryEvent extends AiChatEvent {
  const AiChatLoadHistoryEvent();
}

class AiChatDeleteConsultationEvent extends AiChatEvent {
  final String consultationId;

  const AiChatDeleteConsultationEvent(this.consultationId);

  @override
  List<Object?> get props => [consultationId];
}

class AiChatToggleBookmarkEvent extends AiChatEvent {
  final String consultationId;

  const AiChatToggleBookmarkEvent(this.consultationId);

  @override
  List<Object?> get props => [consultationId];
}

class AiChatUpdateTitleEvent extends AiChatEvent {
  final String title;

  const AiChatUpdateTitleEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class AiChatUpdateCategoryEvent extends AiChatEvent {
  final ConsultationCategory category;

  const AiChatUpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class AiChatGetStartersEvent extends AiChatEvent {
  final ConsultationCategory category;

  const AiChatGetStartersEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class AiChatClearCurrentEvent extends AiChatEvent {
  const AiChatClearCurrentEvent();
}

class AiChatAddTypingIndicatorEvent extends AiChatEvent {
  const AiChatAddTypingIndicatorEvent();
}

class AiChatRemoveTypingIndicatorEvent extends AiChatEvent {
  const AiChatRemoveTypingIndicatorEvent();
}

class AiChatErrorEvent extends AiChatEvent {
  final String error;

  const AiChatErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}
