import 'package:videocalling/core/config/app_imports.dart';

class NotificationController extends GetxController {
  final supabase = supabaseHelper.client;

  // Observable list of notifications
  RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load notifications for the current user
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      final currentUser = firebaseHelper.currentUser;
      if (currentUser == null) {
        print('⚠️ No user logged in');
        // Add some sample notifications for demo
       
        return;
      }

      // Try to load notifications from database
      try {
        final response = await supabase
            .from('notifications')
            .select()
            .eq('user_id', currentUser.uid)
            .order('created_at', ascending: false)
            .limit(50);

        if (response.isNotEmpty) {
          notifications.value = List<Map<String, dynamic>>.from(response);
          _updateUnreadCount();
          print('✅ Loaded ${notifications.length} notifications');
        } else {
          // No notifications in database, load samples
         
        }
      } catch (e) {
        print('⚠️ Error loading notifications from database: $e');
        // Fallback to sample notifications
       
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
     
    } finally {
      isLoading.value = false;
    }
  }



  /// Update unread count
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => n['is_read'] == false).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Update in local list
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['is_read'] = true;
        notifications.refresh();
        _updateUnreadCount();
      }

      // Update in database if user is logged in
      final currentUser = firebaseHelper.currentUser;
      if (currentUser != null) {
        try {
          await supabase
              .from('notifications')
              .update({'is_read': true})
              .eq('id', notificationId);
          print('✅ Notification marked as read');
        } catch (e) {
          print('⚠️ Could not update notification in database: $e');
        }
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Update all in local list
      for (var notification in notifications) {
        notification['is_read'] = true;
      }
      notifications.refresh();
      _updateUnreadCount();

      // Update in database if user is logged in
      final currentUser = firebaseHelper.currentUser;
      if (currentUser != null) {
        try {
          await supabase
              .from('notifications')
              .update({'is_read': true})
              .eq('user_id', currentUser.uid);
          print('✅ All notifications marked as read');
        } catch (e) {
          print('⚠️ Could not update notifications in database: $e');
        }
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Remove from local list
      notifications.removeWhere((n) => n['id'] == notificationId);
      _updateUnreadCount();

      // Delete from database if user is logged in
      final currentUser = firebaseHelper.currentUser;
      if (currentUser != null) {
        try {
          await supabase
              .from('notifications')
              .delete()
              .eq('id', notificationId);
          print('✅ Notification deleted');
        } catch (e) {
          print('⚠️ Could not delete notification from database: $e');
        }
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      notifications.clear();
      _updateUnreadCount();

      // Delete from database if user is logged in
      final currentUser = firebaseHelper.currentUser;
      if (currentUser != null) {
        try {
          await supabase
              .from('notifications')
              .delete()
              .eq('user_id', currentUser.uid);
          print('✅ All notifications cleared');
        } catch (e) {
          print('⚠️ Could not clear notifications from database: $e');
        }
      }
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}
