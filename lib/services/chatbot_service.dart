// lib/services/chatbot_service.dart
import 'dart:convert';
import 'api_client.dart';

class ChatbotService {
  final ApiClient _api = ApiClient();

  // Lấy lịch sử chat
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await _api.get('/chatbot/history');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;

        // Chuyển đổi (message, reply) -> (sender, text)
        final messages = data
            .expand(
              (log) => [
                {'sender': 'user', 'text': log['message']},
                {'sender': 'bot', 'text': log['reply']},
              ],
            )
            .where((msg) => msg['text'] != null)
            .toList();

        return messages.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Lỗi tải lịch sử chatbot: $e');
    }
    return [];
  }

  // Gửi tin nhắn
  Future<String> sendMessage(String message) async {
    try {
      final response = await _api.post('/chatbot', {'message': message});
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['reply'] ??
            'Lỗi: Không nhận được phản hồi';
      }
      return 'Lỗi server: ${response.statusCode}';
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }
}
