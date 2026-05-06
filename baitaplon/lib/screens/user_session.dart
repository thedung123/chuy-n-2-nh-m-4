class UserSession {
  static int? userId;
  static String? fullName;
  static String? username;
  static bool isLoggedIn = false;

  static void setSession(Map<String, dynamic> userData) {
    // Ép kiểu ID từ database trả về sang số nguyên
    userId = int.tryParse(userData['id'].toString());
    fullName = userData['full_name'];
    username = userData['username'];
    isLoggedIn = true;
  }

  static void clearSession() {
    userId = null;
    fullName = null;
    username = null;
    isLoggedIn = false;
  }
}
