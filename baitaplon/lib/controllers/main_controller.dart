import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../user_session.dart';

class MainController {
  int currentTabIndex = 0;
  String selectedCategory = "Trái Cây Nội Địa";
  String searchKeyword = "";

  // Danh sách thông báo sử dụng Model
  List<NotificationModel> notifications = [];

  void setTab(int index, VoidCallback updateUI) {
    currentTabIndex = index;
    updateUI();
  }

  void updateCategory(String category, VoidCallback updateUI) {
    selectedCategory = category;
    searchKeyword = "";
    updateUI();
  }

  void executeSearch(String value, VoidCallback updateUI) {
    searchKeyword = value;
    currentTabIndex = 0;
    updateUI();
  }

  void logout(VoidCallback updateUI) {
    UserSession.clearSession();
    updateUI();
  }

  void addNotification(String title, String message) {
    notifications.insert(0, NotificationModel(
      id: DateTime.now().toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
    ));
  }
}
