# JobConnect VN

JobConnect VN là ứng dụng tìm việc bán thời gian cho sinh viên Việt Nam. Dự án gồm ứng dụng Flutter đa nền tảng và backend Express/PostgreSQL, hỗ trợ sinh viên tìm việc, quản lý hồ sơ/CV, ứng tuyển, nhắn tin, nhận thông báo và nhà tuyển dụng quản lý tin đăng/ứng viên.

## Tính năng chính

- Đăng ký, đăng nhập, đăng nhập Google và xác thực email.
- Hồ sơ sinh viên: thông tin cá nhân, học vấn, kỹ năng, kinh nghiệm, quản lý CV.
- Hồ sơ nhà tuyển dụng: thông tin công ty, logo, website, địa chỉ.
- Tìm kiếm và lọc việc làm theo từ khóa, loại hình, địa điểm.
- Nhà tuyển dụng tạo, cập nhật, xóa và theo dõi tin tuyển dụng.
- Sinh viên ứng tuyển bằng CV trong hồ sơ hoặc CV tải lên riêng cho từng đơn.
- Theo dõi đơn ứng tuyển, cập nhật trạng thái ứng viên.
- Gợi ý việc làm/ứng viên và phân tích hồ sơ bằng AI.
- Chat giữa người dùng và thông báo trong ứng dụng.

## Công nghệ

### Frontend

- Flutter/Dart
- Provider cho state management
- Dio cho HTTP client
- Flutter Secure Storage và Shared Preferences
- File Picker, Image Picker, URL Launcher
- Google Sign-In

### Backend

- Node.js + Express
- PostgreSQL
- JWT authentication
- Multer upload file
- Nodemailer gửi email xác thực
- Google Auth Library
- Groq/Z.ai API cho tính năng chatbot AI

## Cấu trúc thư mục

```text
.
├── lib/
│   ├── core/
│   │   ├── api/          # Dio API client
│   │   ├── storage/      # Secure storage
│   │   ├── theme/        # Theme, màu sắc
│   │   └── widgets/      # Widget dùng chung
│   └── features/
│       ├── apply/        # Ứng tuyển và danh sách đơn
│       ├── auth/         # Đăng nhập, đăng ký, xác thực
│       ├── chat/         # Trò chuyện
│       ├── jobs/         # Việc làm, tin đăng, ứng viên
│       ├── notifications/# Thông báo
│       └── profile/      # Hồ sơ, chỉnh sửa, quản lý CV
├── backend/
│   ├── src/
│   │   ├── config/       # DB, migration, email
│   │   ├── controllers/  # Logic API
│   │   ├── middleware/   # Auth, upload
│   │   ├── routes/       # API routes
│   │   └── index.js      # Entry backend
│   ├── uploads/          # File upload local
│   ├── package.json
│   └── .env.example
├── assets/
├── android/
├── ios/
├── web/
└── pubspec.yaml
```

## Yêu cầu môi trường

- Flutter SDK `>= 3.0.0`
- Dart SDK theo Flutter
- Node.js `>= 18`
- PostgreSQL
- Chrome hoặc thiết bị/emulator để chạy Flutter

Kiểm tra Flutter:

```bash
flutter doctor
```

## Cài đặt backend

1. Vào thư mục backend:

```bash
cd backend
```

2. Cài dependencies:

```bash
npm install
```

3. Tạo file `.env` từ mẫu:

```bash
copy .env.example .env
```

Trên macOS/Linux:

```bash
cp .env.example .env
```

4. Cập nhật `.env`:

```env
PORT=3002
JWT_SECRET=change_this_secret
JWT_EXPIRES_IN=7d

DB_HOST=localhost
DB_PORT=5432
DB_NAME=jobconnect_db
DB_USER=postgres
DB_PASSWORD=your_password

GOOGLE_CLIENT_ID=
EMAIL_USER=
EMAIL_PASS=

AI_PROVIDER=groq
GROQ_API_KEY=
GROQ_BASE_URL=https://api.groq.com/openai/v1
GROQ_MODEL=llama-3.1-8b-instant
ZAI_API_KEY=
ZAI_BASE_URL=https://api.z.ai/api/paas/v4
ZAI_MODEL=glm-4.5-flash
```

Lưu ý: Flutter hiện trỏ API về `http://localhost:3002/api` trên web/desktop và `http://10.0.2.2:3002/api` trên Android emulator. Vì vậy backend nên chạy ở port `3002`, hoặc cần chỉnh lại trong `lib/core/api/api_client.dart`.

5. Tạo database PostgreSQL:

```sql
CREATE DATABASE jobconnect_db;
```

6. Chạy backend:

```bash
npm run dev
```

Hoặc chạy production mode:

```bash
npm start
```

Khi backend khởi động, migration trong `backend/src/config/migrate.js` và migration chat sẽ tự chạy.

7. Seed dữ liệu mẫu nếu cần:

```bash
npm run seed
```

Kiểm tra backend:

```bash
curl http://localhost:3002/health
```

## Cài đặt frontend

Ở thư mục gốc dự án:

```bash
flutter pub get
```

Chạy web:

```bash
flutter run -d chrome
```

Chạy Windows desktop:

```bash
flutter run -d windows
```

Chạy Android emulator:

```bash
flutter run -d android
```

Build web:

```bash
flutter build web
```

## API chính

Backend expose các route dưới prefix `/api`:

- `POST /api/auth/register` - đăng ký
- `POST /api/auth/login` - đăng nhập
- `POST /api/auth/google` - đăng nhập Google
- `POST /api/auth/verify` - xác thực email
- `GET /api/auth/me` - lấy hồ sơ hiện tại
- `PUT /api/auth/profile` - cập nhật hồ sơ
- `PUT /api/auth/change-password` - đổi mật khẩu
- `GET /api/jobs` - danh sách việc làm
- `POST /api/jobs` - tạo tin tuyển dụng
- `PUT /api/jobs/:id` - cập nhật tin tuyển dụng
- `DELETE /api/jobs/:id` - xóa tin tuyển dụng
- `POST /api/apply` - ứng tuyển
- `GET /api/applications` - danh sách đơn ứng tuyển
- `PUT /api/applications/:id/status` - cập nhật trạng thái đơn
- `GET /api/chat/conversations` - danh sách hội thoại
- `GET /api/chat/messages/:conversationId` - tin nhắn
- `POST /api/chat/send` - gửi tin nhắn
- `GET /api/notifications` - thông báo
- `POST /api/upload/avatar` - upload avatar
- `POST /api/upload/cv` - upload CV
- `DELETE /api/upload/cv` - xóa CV khỏi hồ sơ
- `POST /api/upload/logo` - upload logo công ty

Các route cần đăng nhập sử dụng header:

```http
Authorization: Bearer <token>
```

## Quản lý CV

Sinh viên có thể quản lý CV tại:

```text
Hồ sơ -> Quản lý CV
```

Chức năng hỗ trợ:

- Tải CV lên với định dạng `pdf`, `doc`, `docx`.
- Thay thế CV hiện tại.
- Mở CV hiện tại trong trình duyệt/ứng dụng ngoài.
- Xóa CV khỏi hồ sơ.

File CV được lưu trong `backend/uploads/cv/`; đường dẫn CV được lưu ở cột `users.cv_url`.

## Ghi chú phát triển

- Nếu sửa backend, cần restart server Node.js để route/controller mới có hiệu lực.
- Nếu chạy web/desktop, backend phải truy cập được qua `localhost:3002`.
- Nếu chạy Android emulator, Flutter dùng `10.0.2.2:3002` để gọi về máy host.
- Nếu chạy trên điện thoại thật, cần đổi base URL trong `lib/core/api/api_client.dart` sang IP LAN của máy chạy backend.
- Chatbot AI ưu tiên provider theo `AI_PROVIDER`: `groq` sẽ gọi Groq trước rồi fallback sang Z.ai; `zai` sẽ gọi Z.ai trước rồi fallback sang Groq. Nếu cả hai lỗi hoặc thiếu key, backend trả fallback nội bộ thay vì lỗi 500.
- Cảnh báo `flutter_secure_storage_web` không tương thích wasm chỉ ảnh hưởng wasm dry run, không chặn build web JavaScript thông thường.

## Lệnh thường dùng

Backend:

```bash
cd backend
npm install
npm run dev
npm run seed
```

Frontend:

```bash
flutter pub get
flutter run -d chrome
flutter build web
```

Kiểm tra nhanh:

```bash
node --check backend/src/index.js
flutter build web
```
