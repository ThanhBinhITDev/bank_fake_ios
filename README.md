# ban_fake

Ứng dụng iOS giả lập giao diện ngân hàng và thông báo biến động số dư, phục vụ mục đích học SwiftUI/MVVM.

## Tính năng chính
- Giao diện tài khoản theo phong cách ngân hàng.
- Hiển thị số dư và thông tin tài khoản.
- Màn hình lịch sử giao dịch (danh sách theo ngày).
- Tạo thông báo biến động số dư giả (chọn ngân hàng, tiền vào/ra, số lượng, khoảng cách).

## Cấu trúc thư mục
- `ban_fake/` mã nguồn app SwiftUI.
- `ban_fake/Models/` các model (Transaction, HistoryItem, ...).
- `ban_fake/ViewModels/` các view model.
- `ban_fake/Assets.xcassets/` tài nguyên (AppIcon, màu, ảnh).

## Yêu cầu môi trường
- Xcode (khuyến nghị bản mới nhất).
- iOS 16+ (tùy simulator/thiết bị).

## Cách chạy
1. Mở `ban_fake.xcodeproj` bằng Xcode.
2. Chọn simulator hoặc thiết bị thật.
3. Nếu chạy trên thiết bị thật: vào `Signing & Capabilities` chọn Apple ID (Team).
4. Run.

## Thông báo (Notification)
- Thông báo chỉ hiển thị khi đã cấp quyền.
- Lần đầu bấm tạo thông báo sẽ xin quyền.
- Nếu không thấy icon, xoá app và cài lại để xóa cache.

## Ghi chú
- Dữ liệu giao dịch là giả lập, không kết nối ngân hàng thật.
- Mục đích dự án: học UI/UX SwiftUI và mô phỏng flow ngân hàng.
