import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/user_model.dart';
import '../models/chat_message_model.dart';
import '../models/ai_consultation_model.dart';

class AiChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  late final GenerativeModel _model;

  AiChatRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system(_getSystemPrompt()),
    );
  }

  // Send message to AI and get response
  Future<String> sendMessage(
    String message,
    List<ChatMessage> chatHistory,
  ) async {
    try {
      // Build conversation history for context
      final history = <Content>[];

      // Add previous messages for context (last 10 messages)
      final recentHistory = chatHistory.take(10).toList();
      for (final msg in recentHistory) {
        if (msg.isUser) {
          history.add(Content.text(msg.content));
        } else {
          history.add(Content.model([TextPart(msg.content)]));
        }
      }

      // Create chat session with history
      final chat = _model.startChat(history: history);

      // Send the new message
      final response = await chat.sendMessage(Content.text(message));

      return response.text ??
          'I apologize, but I\'m having trouble responding right now. Please try again.';
    } catch (e) {
      throw Exception('Failed to get AI response: ${e.toString()}');
    }
  }

  // Save chat session to Firestore
  Future<String> saveChatSession(AiConsultation consultation) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final docRef = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ai_consultations')
          .add({
            ...consultation.toJson(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save chat session: ${e.toString()}');
    }
  }

  // Update existing chat session
  Future<void> updateChatSession(
    String sessionId,
    AiConsultation consultation,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Use set with merge to avoid NOT_FOUND errors
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ai_consultations')
          .doc(sessionId)
          .set({
            ...consultation.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update chat session: ${e.toString()}');
    }
  }

  // Get user's chat history
  Future<List<AiConsultation>> getChatHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ai_consultations')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => AiConsultation.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get specific chat session
  Future<AiConsultation?> getChatSession(String sessionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ai_consultations')
          .doc(sessionId)
          .get();

      if (!doc.exists) return null;

      return AiConsultation.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      return null;
    }
  }

  // Delete chat session
  Future<void> deleteChatSession(String sessionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ai_consultations')
          .doc(sessionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete chat session: ${e.toString()}');
    }
  }

  // Get user context for personalized responses
  Future<Map<String, dynamic>> getUserContext() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return {};

      final userData = userDoc.data()!;
      final userModel = UserModel.fromJson(userData);

      // Get recent mood entries for context
      final moodSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('moods')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      final recentMoods = moodSnapshot.docs.map((doc) => doc.data()).toList();

      return {'user': userModel.toJson(), 'recentMoods': recentMoods};
    } catch (e) {
      return {};
    }
  }

  // Generate conversation starters based on user context
  Future<List<String>> getConversationStarters() async {
    try {
      final userContext = await getUserContext();

      // Base conversation starters
      final starters = [
        "How are you feeling today?",
        "What's on your mind right now?",
        "Is there something specific you'd like to talk about?",
        "How has your week been so far?",
        "What emotions are you experiencing lately?",
      ];

      // Add personalized starters based on recent moods
      if (userContext['recentMoods'] != null) {
        final recentMoods = userContext['recentMoods'] as List;
        if (recentMoods.isNotEmpty) {
          starters.addAll([
            "I noticed you've been tracking your mood. How are you feeling about that?",
            "Would you like to discuss any patterns you've noticed in your mood?",
            "How do you feel your mood has been lately?",
          ]);
        }
      }

      return starters;
    } catch (e) {
      return [
        "How are you feeling today?",
        "What's on your mind right now?",
        "Is there something specific you'd like to talk about?",
      ];
    }
  }

  String _getSystemPrompt() {
    return '''
You are a compassionate and professional mental health AI assistant named "Mentally AI". You provide supportive, empathetic, and helpful responses to users seeking mental health guidance. 

Key guidelines:
1. Always be empathetic, non-judgmental, and supportive
2. Provide evidence-based mental health information and coping strategies
3. Encourage professional help when appropriate
4. Never diagnose or provide medical advice
5. Respect user privacy and confidentiality
6. Use a warm, understanding tone
7. Ask follow-up questions to better understand the user's situation
8. Provide practical coping strategies and techniques
9. Validate the user's feelings and experiences
10. Encourage self-care and healthy habits

Formatting guidelines:
- Write in natural, conversational language
- Use simple bullet points with * for lists when needed
- Use **bold** sparingly, only for very important key points
- Avoid excessive formatting or special characters
- Keep responses clean and easy to read
- Write in paragraph form when possible

Important disclaimers:
- You are not a replacement for professional mental health care
- In crisis situations, direct users to emergency services or crisis hotlines
- Encourage users to seek professional help for serious mental health concerns

Remember to:
- Listen actively and respond thoughtfully
- Provide helpful resources and techniques
- Maintain appropriate boundaries
- Be culturally sensitive and inclusive
- Focus on strengths and resilience
- Encourage hope and positive change

Keep responses conversational, supportive, and focused on the user's wellbeing. Respond in a natural, flowing manner without excessive formatting.
''';
  }
}
