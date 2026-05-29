# Klever Fruits Mobile App (Flutter Project)

## 1. Tổng quan dự án

Klever Fruits Mobile App là ứng dụng bán rau củ quả được xây dựng bằng Flutter và Dart trên nền tảng Android. Ứng dụng mô phỏng một hệ thống thương mại điện tử cơ bản cho phép người dùng đăng nhập, đăng ký tài khoản, xem danh mục sản phẩm, xem thông tin trái cây và thêm sản phẩm vào giỏ hàng.

Dự án được phát triển nhằm mục tiêu học tập và thực hành quy trình xây dựng một ứng dụng mobile thực tế theo cấu trúc chuẩn Flutter.

---

## 2. Mục tiêu của dự án

Mục tiêu chính của dự án gồm:

* Xây dựng ứng dụng mobile bằng Flutter
* Làm quen với cấu trúc project Flutter chuẩn
* Thiết kế giao diện theo Material Design
* Hiểu cách điều hướng giữa các màn hình (Navigation)
* Hiển thị danh sách sản phẩm dạng ListView
* Xây dựng mô hình ứng dụng bán hàng cơ bản

---

## 3. Công nghệ sử dụng

Các công nghệ sử dụng trong dự án:

* Flutter
* Dart
* Material UI Widgets
* Android Studio

Flutter giúp xây dựng ứng dụng đa nền tảng với hiệu suất cao và giao diện thân thiện.

---

## 4. Kiến trúc ứng dụng

Ứng dụng được xây dựng theo cấu trúc tách màn hình theo từng chức năng.

Các thành phần chính gồm:

* main.dart
* login_screen.dart
* register_screen.dart
* home_screen.dart
* fruit_screen.dart

Cấu trúc này giúp project dễ quản lý, dễ mở rộng và phù hợp với tiêu chuẩn phát triển ứng dụng Flutter.

---

## 5. Cấu trúc thư mục dự án

Cấu trúc thư mục chính:

lib/

main.dart → Điểm khởi chạy ứng dụng

login_screen.dart → Màn hình đăng nhập

register_screen.dart → Màn hình đăng ký

home_screen.dart → Trang chủ ứng dụng

fruit_screen.dart → Danh sách trái cây

assets/

images/ → Lưu hình ảnh sản phẩm (nếu dùng ảnh local)

---

## 6. Luồng hoạt động của ứng dụng

Luồng hoạt động chính:

Khởi động ứng dụng

→ Màn hình đăng nhập

→ Màn hình đăng ký (nếu chưa có tài khoản)

→ Trang chủ ứng dụng

→ Chọn danh mục sản phẩm

→ Màn hình danh sách trái cây

→ Thêm sản phẩm vào giỏ hàng

Luồng hoạt động mô phỏng quy trình mua hàng cơ bản trong ứng dụng thương mại điện tử.

---

## 7. Chức năng chính của hệ thống

### 7.1 Màn hình đăng nhập

Cho phép người dùng nhập thông tin tài khoản để truy cập ứng dụng.

Chức năng:

* Nhập username
* Nhập password
* Điều hướng sang trang chủ

---

### 7.2 Màn hình đăng ký

Cho phép người dùng tạo tài khoản mới.

Chức năng:

* Nhập tên người dùng
* Nhập email
* Nhập mật khẩu
* Điều hướng quay lại màn hình đăng nhập

---

### 7.3 Trang chủ (Home Screen)

Trang chủ hiển thị thông tin tổng quan của ứng dụng.

Bao gồm:

* Thanh tìm kiếm sản phẩm
* Banner giới thiệu ứng dụng
* Thông tin mô tả Klever Fruits
* Danh mục sản phẩm
* Icon giỏ hàng

Danh mục sản phẩm gồm:

* Trái cây
* Rau xanh
* Củ quả
* Trái cây nhập khẩu

---

### 7.4 Trang danh sách trái cây

Hiển thị danh sách sản phẩm trái cây.

Mỗi sản phẩm gồm:

* Hình ảnh sản phẩm
* Tên sản phẩm
* Giá sản phẩm
* Mô tả sản phẩm
* Nút thêm vào giỏ hàng

Danh sách được hiển thị bằng ListView.builder giúp tối ưu hiệu suất.

---

### 7.5 Chức năng thêm vào giỏ hàng

Người dùng có thể nhấn nút thêm để đưa sản phẩm vào giỏ hàng.

Hiện tại chức năng đang mô phỏng bằng SnackBar thông báo thêm thành công.

Trong phiên bản nâng cao có thể mở rộng:

* Lưu danh sách sản phẩm
* Hiển thị Cart Screen
* Thanh toán

---

## 8. Widget Flutter sử dụng trong dự án

Các widget chính được sử dụng:

* MaterialApp
* Scaffold
* AppBar
* TextField
* Column
* Row
* ListView.builder
* Card
* ListTile
* Image.network
* ElevatedButton
* SnackBar
* Navigator

Các widget giúp xây dựng giao diện theo chuẩn Material Design.

---

## 9. Điều hướng giữa các màn hình (Navigation)

Ứng dụng sử dụng Navigator.push để chuyển màn hình.

Ví dụ:

Login Screen
→ Home Screen

Home Screen
→ Fruit Screen

Điều hướng giúp ứng dụng hoạt động giống ứng dụng mobile thực tế.

---

## 10. Hướng dẫn chạy dự án

Bước 1: Cài đặt Flutter SDK

Bước 2: Cài đặt Android Studio

Bước 3: Clone project về máy

Bước 4: Mở project bằng Android Studio

Bước 5: Chạy lệnh:

flutter pub get

Bước 6: Chạy ứng dụng:

flutter run

Ứng dụng có thể chạy trên:

* Máy ảo Android
* Thiết bị Android thật

---

## 11. Hướng phát triển trong tương lai

Các chức năng có thể phát triển thêm:

* Trang chi tiết sản phẩm
* Trang giỏ hàng
* Lưu dữ liệu người dùng
* Kết nối API backend
* Thanh toán online
* Quản lý đơn hàng

---

## 12. Ưu điểm của ứng dụng

Ưu điểm của dự án:

* Giao diện thân thiện
* Dễ sử dụng
* Cấu trúc rõ ràng
* Dễ mở rộng chức năng
* Phù hợp học tập Flutter cơ bản

---

## 13. Thành viên thực hiện

Nhóm phát triển gồm:

Nguyễn Thế Dũng

Trần Tùng Dương

Lê Văn Sáng

---

## 14. Kết luận

Klever Fruits Mobile App là dự án ứng dụng Flutter mô phỏng hệ thống bán rau củ quả trực tuyến cơ bản. Dự án giúp sinh viên hiểu rõ quy trình xây dựng ứng dụng mobile thực tế và làm nền tảng để phát triển các chức năng nâng cao trong tương lai.
