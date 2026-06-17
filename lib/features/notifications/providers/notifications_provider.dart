import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../../../core/api/api_client.dart';

class NotificationsProvider extends ChangeNotifier {
  final _api = ApiClient();

  List<NotificationModel> _notifications = [];
  int  _unreadCount = 0;
  bool _isLoading   = false;

  List<NotificationModel> get notifications => _notifications;
  int  get unreadCount => _unreadCount;
  bool get isLoading   => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/notifications');
      _notifications = (res.data['notifications'] as List)
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();
      _unreadCount = res.data['unread_count'] as int;
    } on DioException catch (e) {
      debugPrint('[Notif] error: ${ApiClient.parseError(e)}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _api.put('/notifications/$id/read');
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return NotificationModel.fromJson({
            'id': n.id, 'user_id': n.userId, 'type': n.type,
            'title': n.title, 'body': n.body, 'ref_id': n.refId,
            'ref_type': n.refType, 'is_read': true,
            'created_at': n.createdAt.toIso8601String(),
          });
        }
        return n;
      }).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } on DioException catch (e) {
      debugPrint('[Notif] markRead error: ${ApiClient.parseError(e)}');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.put('/notifications/all/read');
      _notifications = _notifications.map((n) => NotificationModel.fromJson({
        'id': n.id, 'user_id': n.userId, 'type': n.type,
        'title': n.title, 'body': n.body, 'ref_id': n.refId,
        'ref_type': n.refType, 'is_read': true,
        'created_at': n.createdAt.toIso8601String(),
      })).toList();
      _unreadCount = 0;
      notifyListeners();
    } on DioException catch (e) {
      debugPrint('[Notif] markAllRead error: ${ApiClient.parseError(e)}');
    }
  }
}
