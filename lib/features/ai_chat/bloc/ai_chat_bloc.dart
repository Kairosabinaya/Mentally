import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../repository/ai_chat_repository.dart';
import '../models/chat_message_model.dart';
import '../models/ai_consultation_model.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiChatRepository _repository;
  final Uuid _uuid = const Uuid();
  Timer? _sessionTimer;
  DateTime? _sessionStartTime;

  AiChatBloc({required AiChatRepository repository})
    : _repository = repository,
      super(const AiChatState()) {
    on<AiChatInitializeEvent>(_onInitialize);
    on<AiChatStartConsultationEvent>(_onStartConsultation);
    on<AiChatLoadConsultationEvent>(_onLoadConsultation);
    on<AiChatSendMessageEvent>(_onSendMessage);
    on<AiChatRetryMessageEvent>(_onRetryMessage);
    on<AiChatDeleteMessageEvent>(_onDeleteMessage);
    on<AiChatUpdateMessageStatusEvent>(_onUpdateMessageStatus);
    on<AiChatSaveConsultationEvent>(_onSaveConsultation);
    on<AiChatEndConsultationEvent>(_onEndConsultation);
    on<AiChatLoadHistoryEvent>(_onLoadHistory);
    on<AiChatDeleteConsultationEvent>(_onDeleteConsultation);
    on<AiChatToggleBookmarkEvent>(_onToggleBookmark);
    on<AiChatUpdateTitleEvent>(_onUpdateTitle);
    on<AiChatUpdateCategoryEvent>(_onUpdateCategory);
    on<AiChatGetStartersEvent>(_onGetStarters);
    on<AiChatClearCurrentEvent>(_onClearCurrent);

    on<AiChatErrorEvent>(_onError);
  }

  Future<void> _onInitialize(
    AiChatInitializeEvent event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AiChatStatus.loading));

      // Load conversation starters and chat history
      final starters = await _repository.getConversationStarters();
      final history = await _repository.getChatHistory();

      emit(
        state.copyWith(
          status: AiChatStatus.ready,
          conversationStarters: starters,
          consultationHistory: history,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to initialize chat: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStartConsultation(
    AiChatStartConsultationEvent event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      final consultationId = _uuid.v4();
      final consultation = AiConsultation.create(
        id: consultationId,
        userId: 'current_user', // TODO: Get from auth service
        category: event.category,
        moodBefore: event.moodBefore,
      );

      emit(
        state.copyWith(
          currentConsultation: consultation,
          status: AiChatStatus.ready,
          hasUnsavedChanges: false,
        ),
      );

      // Start session timer
      _sessionStartTime = DateTime.now();
      _startSessionTimer();

      // Send initial message if provided
      if (event.initialMessage != null && event.initialMessage!.isNotEmpty) {
        add(AiChatSendMessageEvent(event.initialMessage!));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to start consultation: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadConsultation(
    AiChatLoadConsultationEvent event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AiChatStatus.loading));

      final consultation = await _repository.getChatSession(
        event.consultationId,
      );
      if (consultation == null) {
        emit(
          state.copyWith(
            status: AiChatStatus.error,
            errorMessage: 'Consultation not found',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          currentConsultation: consultation,
          status: AiChatStatus.ready,
          hasUnsavedChanges: false,
        ),
      );

      // Start session timer for continuing consultation
      _sessionStartTime = DateTime.now();
      _startSessionTimer();
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to load consultation: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSendMessage(
    AiChatSendMessageEvent event,
    Emitter<AiChatState> emit,
  ) async {
    if (state.currentConsultation == null) return;

    try {
      // Create user message
      final userMessageId = _uuid.v4();
      final userMessage = ChatMessage.user(
        id: userMessageId,
        content: event.message,
        status: MessageStatus.sending,
      );

      // Add user message to state
      emit(state.addMessage(userMessage));

      // Update message status to sent
      emit(state.updateMessageStatus(userMessageId, MessageStatus.sent));

      // Send to AI and get response
      final aiResponse = await _repository.sendMessage(
        event.message,
        state.messagesForAI,
      );

      // Create AI message
      final aiMessageId = _uuid.v4();
      final aiMessage = ChatMessage.ai(
        id: aiMessageId,
        content: aiResponse,
        status: MessageStatus.sent,
      );

      // Add AI message to state
      emit(state.addMessage(aiMessage));

      // Auto-save after successful exchange
      add(const AiChatSaveConsultationEvent());
    } catch (e) {
      // Update user message status to failed
      emit(state.updateMessageStatus(event.message, MessageStatus.failed));

      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to send message: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRetryMessage(
    AiChatRetryMessageEvent event,
    Emitter<AiChatState> emit,
  ) async {
    if (event.message.isUser) {
      // Retry sending user message
      add(AiChatSendMessageEvent(event.message.content));
    }
  }

  void _onDeleteMessage(
    AiChatDeleteMessageEvent event,
    Emitter<AiChatState> emit,
  ) {
    emit(state.removeMessage(event.messageId));
  }

  void _onUpdateMessageStatus(
    AiChatUpdateMessageStatusEvent event,
    Emitter<AiChatState> emit,
  ) {
    emit(state.updateMessageStatus(event.messageId, event.status));
  }

  Future<void> _onSaveConsultation(
    AiChatSaveConsultationEvent event,
    Emitter<AiChatState> emit,
  ) async {
    if (state.currentConsultation == null) return;

    try {
      final consultation = state.currentConsultation!;

      // Update duration
      final duration = _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!)
          : consultation.duration;

      final updatedConsultation = consultation.copyWith(
        duration: duration,
        updatedAt: DateTime.now(),
      );

      // Always try to save as new first, then update if needed
      String? savedId;
      try {
        // Try to save as new consultation
        savedId = await _repository.saveChatSession(updatedConsultation);

        // Update consultation with the saved ID if it's different
        final finalConsultation = updatedConsultation.copyWith(id: savedId);

        emit(
          state.copyWith(
            currentConsultation: finalConsultation,
            hasUnsavedChanges: false,
            consultationHistory: _updateHistoryWithConsultation(
              finalConsultation,
            ),
          ),
        );
      } catch (saveError) {
        // If save fails (maybe document already exists), try to update
        try {
          await _repository.updateChatSession(
            consultation.id,
            updatedConsultation,
          );

          emit(
            state.copyWith(
              currentConsultation: updatedConsultation,
              hasUnsavedChanges: false,
              consultationHistory: _updateHistoryWithConsultation(
                updatedConsultation,
              ),
            ),
          );
        } catch (updateError) {
          // If both fail, try to save with a new ID
          final newId = _uuid.v4();
          final newConsultation = updatedConsultation.copyWith(id: newId);

          savedId = await _repository.saveChatSession(newConsultation);
          final finalConsultation = newConsultation.copyWith(id: savedId);

          emit(
            state.copyWith(
              currentConsultation: finalConsultation,
              hasUnsavedChanges: false,
              consultationHistory: _updateHistoryWithConsultation(
                finalConsultation,
              ),
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to save consultation: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onEndConsultation(
    AiChatEndConsultationEvent event,
    Emitter<AiChatState> emit,
  ) async {
    if (state.currentConsultation == null) return;

    try {
      final consultation = state.currentConsultation!;

      // Update consultation with final details
      final duration = _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!)
          : consultation.duration;

      final updatedConsultation = consultation.copyWith(
        status: ConsultationStatus.completed,
        moodAfter: event.moodAfter,
        notes: event.notes,
        duration: duration,
        updatedAt: DateTime.now(),
      );

      // Save final state using set with merge to avoid NOT_FOUND errors
      await _repository.updateChatSession(consultation.id, updatedConsultation);

      // Update history and clear current
      emit(
        state
            .copyWith(
              consultationHistory: _updateHistoryWithConsultation(
                updatedConsultation,
              ),
            )
            .clearCurrent(),
      );

      // Stop session timer
      _stopSessionTimer();
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to end consultation: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadHistory(
    AiChatLoadHistoryEvent event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      final history = await _repository.getChatHistory();
      emit(state.copyWith(consultationHistory: history));
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to load history: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeleteConsultation(
    AiChatDeleteConsultationEvent event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      await _repository.deleteChatSession(event.consultationId);
      emit(state.removeConsultationFromHistory(event.consultationId));

      // Clear current if it's the deleted one
      if (state.currentConsultation?.id == event.consultationId) {
        emit(state.clearCurrent());
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to delete consultation: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onToggleBookmark(
    AiChatToggleBookmarkEvent event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      final consultation = state.consultationHistory.firstWhere(
        (c) => c.id == event.consultationId,
      );

      final updatedConsultation = consultation.copyWith(
        isBookmarked: !consultation.isBookmarked,
      );

      await _repository.updateChatSession(
        event.consultationId,
        updatedConsultation,
      );
      emit(state.updateConsultationInHistory(updatedConsultation));

      // Update current if it's the same
      if (state.currentConsultation?.id == event.consultationId) {
        emit(state.copyWith(currentConsultation: updatedConsultation));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AiChatStatus.error,
          errorMessage: 'Failed to toggle bookmark: ${e.toString()}',
        ),
      );
    }
  }

  void _onUpdateTitle(AiChatUpdateTitleEvent event, Emitter<AiChatState> emit) {
    if (state.currentConsultation == null) return;

    final updatedConsultation = state.currentConsultation!.copyWith(
      title: event.title,
      updatedAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        currentConsultation: updatedConsultation,
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onUpdateCategory(
    AiChatUpdateCategoryEvent event,
    Emitter<AiChatState> emit,
  ) {
    if (state.currentConsultation == null) return;

    final updatedConsultation = state.currentConsultation!.copyWith(
      category: event.category,
      updatedAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        currentConsultation: updatedConsultation,
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onGetStarters(
    AiChatGetStartersEvent event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      final starters = await _repository.getConversationStarters();
      emit(state.copyWith(conversationStarters: starters));
    } catch (e) {
      // Ignore errors for conversation starters
    }
  }

  void _onClearCurrent(
    AiChatClearCurrentEvent event,
    Emitter<AiChatState> emit,
  ) {
    emit(state.clearCurrent());
    _stopSessionTimer();
  }



  void _onError(AiChatErrorEvent event, Emitter<AiChatState> emit) {
    emit(state.copyWith(status: AiChatStatus.error, errorMessage: event.error));
  }

  // Helper methods
  List<AiConsultation> _updateHistoryWithConsultation(
    AiConsultation consultation,
  ) {
    final history = List<AiConsultation>.from(state.consultationHistory);
    final existingIndex = history.indexWhere((c) => c.id == consultation.id);

    if (existingIndex >= 0) {
      history[existingIndex] = consultation;
    } else {
      history.insert(0, consultation);
    }

    return history;
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Auto-save every minute during active session
      if (state.hasUnsavedChanges) {
        add(const AiChatSaveConsultationEvent());
      }
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _sessionStartTime = null;
  }

  @override
  Future<void> close() {
    _stopSessionTimer();
    return super.close();
  }
}
 