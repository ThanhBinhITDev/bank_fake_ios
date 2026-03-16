# Prompt Yêu Cầu Phát Triển App Mirror & Control iPhone

## 1. Tổng Quan Dự Án

- **Tên app đề xuất**: iMirror / PhoneMirror / ScreenCast
- **Mục đích**: Hiển thị và điều khiển iPhone từ máy tính khi màn hình iPhone bị hỏng hoặc cần thao tác từ xa
- **Nền tảng**: iOS (iPhone) + Desktop (Windows/Mac)
- **Người dùng mục tiêu**: Người dùng iPhone cần điều khiển khi màn hình hỏng, kỹ thuật viên sửa chữa, người dùng muốn điều khiển từ máy tính

---

## 2. Yêu Cầu Chức Năng

### 2.1. Chức năng chính (Bắt buộc)

| STT | Chức năng | Mô tả chi tiết |
|-----|-----------|----------------|
| 1 | **Mirror màn hình** | Hiển thị màn hình iPhone lên máy tính theo thời gian thực |
| 2 | **Điều khiển từ máy tính** | Dùng chuột/bàn phím máy tính để thao tác trên iPhone |
| 3 | **Kết nối qua USB** | Ưu tiên kết nối qua cáp Lightning để độ trễ thấp |
| 4 | **Kết nối qua WiFi** | Kết nối không dây trong cùng mạng LAN |
| 5 | **Tương thích iOS 15+** | Hỗ trợ iPhone chạy iOS 15, 16, 17, 18 |

### 2.2. Chức năng bổ sung (Nếu có thể)

| STT | Chức năng | Mô tả |
|-----|-----------|-------|
| 1 | **Chụp màn hình** | Lưu ảnh màn hình iPhone về máy tính |
| 2 | **Ghi video** | Quay video màn hình iPhone |
| 3 | **Truyền file** | Chuyển file giữa iPhone và máy tính |
| 4 | **Shell/Terminal** | Mở terminal trên iPhone từ máy tính |
| 5 | **Quản lý file** | Xem/copy file trong iPhone |

---

## 3. Yêu Cầu Kỹ Thuật

### 3.1. Phía iOS (iPhone)

```
- Ngôn ngữ: Swift
- Framework: UIKit / SwiftUI
- Kết nối: Lightning/USB-C + WiFi
- Frame mirroring: ReplayKit hoặc custom solution
- Điều khiển: Virtual Input (cần hướng dẫn user enable Accessibility)
- Tương thích: iOS 15.0 trở lên
- Bitcode: Enable (nếu cần)
```

### 3.2. Phía Desktop (Client)

```
- Windows: C# (.NET) hoặc Electron
- Mac: SwiftUI / Electron
- Giao thức: TCP socket hoặc WebSocket
- Video decoding: H.264 hardware decode
- Frame rate: 30-60 FPS
- Độ trễ: < 100ms qua USB, < 300ms qua WiFi
```

### 3.3. Giao Thức Truyền Dữ Liệu

```
- Protocol: TcpSocket hoặc WebSocket
- Video: H.264 encoded frames (JPEG hoặc PNG nếu đơn giản hơn)
- Audio: AAC hoặc Opus (nếu cần)
- Input: Mouse events, keyboard events, touch coordinates
- Port mặc định: 5555 hoặc configurable
```

---

## 4. UI/UX Design

### 4.1. Giao diện iOS

```
- Màn hình chính: Hiển thị IP address, port, trạng thái kết nối
- QR code: Để quét từ máy tính (nếu dùng WiFi)
- Hướng dẫn: Cách bật Accessibility cho điều khiển
- Cài đặt: Chọn chất lượng mirror, cổng kết nối
```

### 4.2. Giao diện Desktop

```
- Cửa sổ chính: Hiển thị màn hình iPhone
- Thanh công cụ: Kết nối, chụp màn hình, ghi video, settings
- Chế độ toàn màn hình
- Hiển thị FPS, độ trễ
```

---

## 5. Kỹ Thuật Chi Tiết

### 5.1. Mirror màn hình (iOS)

**Cách 1: ReplayKit (Apple chính thức)**
```swift
// Sử dụng RPScreenRecorder để capture màn hình
// Ưu: Chính thức, không cần jailbreak
// Nhược: Cần user cho phép từng lần
```

**Cách 2: Custom framebuffer access**
```swift
// Private APIs hoặc workaround
// Rủi ro: Có thể bị Apple reject
```

**Cách 3: CTServer + Virtual Display (Cần jailbreak)**
```
- Khuyến nghị KHÔNG dùng cách này
```

### 5.2. Điều khiển (Input Injection)

**Cách 1: Accessibility API**
```swift
// Yêu cầu user bật: Settings > Accessibility > Your App
// Sử dụng: AXUIElement
// Ưu: Không cần jailbreak
// Nhược: Cần user cấp quyền thủ công
```

**Cách 2: HID over Bluetooth/GUSB**
```
- Cần MFi license
- Phức tạp, chi phí cao
```

### 5.3. Data Flow

```
[iPhone] --> [ReplayKit capture] --> [H.264 encode] --> [TCP/WebSocket] --> [PC decode & display]
[PC] --> [Mouse/Keyboard events] --> [TCP/WebSocket] --> [iOS: Accessibility API] --> [Inject events]
```

---

## 6. Phân Chia Công Việc (Nếu Cần)

| Giai đoạn | Nội dung | Thời gian ước tính |
|-----------|----------|-------------------|
| Phase 1 | Mirror màn hình qua USB | 2-3 tuần |
| Phase 2 | Điều khiển bằng Accessibility | 1-2 tuần |
| Phase 3 | Kết nối WiFi | 1 tuần |
| Phase 4 | Tối ưu performance | 1-2 tuần |
| Phase 5 | Build desktop client | 2-3 tuần |

**Tổng thời gian ước tính**: 7-11 tuần

---

## 7. Hạn Chế & Lưu Ý

```
1. Apple hạn chế mirror màn hình iOS
   - ReplayKit: Cần user cho phép mỗi lần sử dụng
   - Private APIs: Có thể bị reject khỏi App Store

2. Điều khiển:
   - Bắt buộc user bật Accessibility
   - Không hỗ trợ một số gesture phức tạp

3. Pháp lý:
   - Cần tuân thủ Apple Developer Program
   - Không vi phạm điều khoản Apple

4. Giải pháp thay thế nếu bị reject:
   - Phát hành dưới dạng Enterprise/các nhân
   - Không đưa lên App Store
```

---

## 8. Yêu Cầu Đầu Ra

1. **iOS App**: File .ipa có thể cài đặt
2. **Desktop Client**: File .exe (Windows) / .app (Mac)
3. **Source code**: Đầy đủ, có comment
4. **Hướng dẫn sử dụng**: File PDF hoặc README
5. **Video demo**: Clip ngắn minh họa tính năng

---

## 9. Ngân Sách Dự Kiến

| Hạng mục | Chi phí ước tính |
|----------|-----------------|
| Developer (iOS + Desktop) | $2000 - $5000 |
| Apple Developer Account | $99/năm |
| Marketing ban đầu | $500 - $1000 |
| **Tổng** | **$2500 - $6100** |

---

## 10. Liên Hệ & Trao Đổi

```
- Người yêu cầu: [Tên của bạn]
- Email: [Email của bạn]
- Thời gian mong muốn hoàn thành: [Ngày]
- Ưu tiên: [Mirror trước / Điều khiển trước / Cả hai cùng lúc]
```

---

**Lưu ý quan trọng**: 
- App này khá phức tạp về mặt kỹ thuật do Apple hạn chế các API liên quan đến màn hình
- Cần developer có kinh nghiệm với iOS private APIs HOẶC sử dụng giải pháp chấp nhận hạn chế (ReplayKit)
- Nếu muốn đưa lên App Store, cần tham vấn kỹ về chính sách Apple

---

*Prompt được tạo bởi: [Tên của bạn]*
*Ngày: [Ngày hiện tại]*
