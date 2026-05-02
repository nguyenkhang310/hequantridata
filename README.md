# 🎓 UTH Portal — Hệ thống Quản lý Đăng ký Học phần

**Môn học:** Hệ Quản Trị Cơ Sở Dữ Liệu  
**Trường:** Đại học Giao thông Vận tải TP.HCM (UTH)  
**Đề tài số 6:** Quản lý sinh viên đăng ký học phần tín chỉ

---

## 📋 Mô tả hệ thống

Hệ thống quản lý đăng ký học phần trực tuyến cho sinh viên UTH, gồm:
- **Giao diện Web hiện đại** (React + TailwindCSS) chạy trong cửa sổ Desktop
- **Backend API** (Python Flask) kết nối trực tiếp MySQL
- **Cơ sở dữ liệu MySQL** với đầy đủ Trigger, Stored Procedure, View, Function

---

## 🗂 Cấu trúc thư mục

```
hequantridata_uth/
│
├── 📄 UTH_Portal_Web.exe        ← File chạy chương trình (click đúp)
├── 🐍 api.py                    ← Backend API Flask (khởi động tự động)
├── 🐍 run_app.py                ← Script launcher (nguồn để build exe)
│
├── 📁 sql/                      ← TOÀN BỘ SQL Database
│   ├── 01_CreateDatabase.sql    ← Tạo bảng, khóa chính, khóa ngoại
│   ├── 02_SampleData.sql        ← Dữ liệu mẫu: 500 SV, 20 GV, 2.758 lượt ĐK
│   ├── 03_Functions.sql         ← 6 Functions (tính GPA, xếp loại...)
│   ├── 04_StoredProcedures.sql  ← 10+ Stored Procedures
│   ├── 05_Triggers.sql          ← Triggers (chặn trùng lịch, cập nhật sĩ số)
│   ├── 06_Views.sql             ← Views (TKB, bảng điểm tổng hợp)
│   └── demo/                    ← 5 kịch bản demo lỗi Transaction
│
├── 📁 frontend/                 ← Mã nguồn giao diện Web (React)
│   ├── src/routes/              ← Các trang: đăng nhập, dashboard, điểm...
│   └── dist/                   ← File build (tự động tạo)
│
├── 📁 old_desktop_version/      ← Giao diện Tkinter cũ (lưu trữ)
├── 📁 docs/                     ← Tài liệu
│
├── 🐍 generate_data.py          ← Script tạo 500 SV dữ liệu mẫu
├── 🐍 export_sql.py             ← Script đồng bộ DB → SQL file
├── 📄 KICH_BAN_DEMO.md          ← Kịch bản thuyết trình chi tiết
└── 📄 README.md                 ← File này
```

---

## ⚙️ Yêu cầu hệ thống

| Thành phần | Phiên bản | Bắt buộc |
|---|---|---|
| **MySQL Server** | 8.0+ | ✅ |
| **Python** | 3.10+ | ✅ |
| **Node.js** | 18+ | ✅ |
| RAM | 4GB+ | Khuyến nghị |

---

## 🚀 Hướng dẫn cài đặt và chạy

### Bước 1: Thiết lập Database (Chỉ làm 1 lần)

Mở MySQL Workbench (hoặc HeidiSQL), chạy **lần lượt** từng file trong thư mục `sql/`:

```sql
-- Chạy từng file theo thứ tự:
SOURCE sql/01_CreateDatabase.sql;
SOURCE sql/02_SampleData.sql;
SOURCE sql/03_Functions.sql;
SOURCE sql/04_StoredProcedures.sql;
SOURCE sql/05_Triggers.sql;
SOURCE sql/06_Views.sql;
```

### Bước 2: Cài Python dependencies (Chỉ làm 1 lần)

```bash
pip install flask flask-cors mysql-connector-python pywebview
```

### Bước 3: Cài Node.js dependencies (Chỉ làm 1 lần)

```bash
cd frontend
npm install
```

### Bước 4: Sửa thông tin kết nối Database

Mở file `api.py`, tìm và sửa:
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'YOUR_MYSQL_PASSWORD',  # ← Đổi thành mật khẩu MySQL của bạn
    'database': 'QuanLyDKHP'
}
```

### Bước 5: Chạy chương trình

**Cách 1 — Double-click file exe (Đơn giản nhất):**
```
Click đúp vào: UTH_Portal_Web.exe
```
Đợi 5-10 giây, cửa sổ phần mềm sẽ tự mở.

**Cách 2 — Chạy thủ công (Dev mode):**
```bash
# Terminal 1: Chạy Backend
python api.py

# Terminal 2: Chạy Frontend  
cd frontend
npm run dev

# Mở trình duyệt: http://localhost:8080
```

---

## 🔑 Tài khoản demo

| Vai trò | Mã số | Mật khẩu |
|---|---|---|
| Sinh viên | `SV001` → `SV500` | `sv123456` |
| Giảng viên | `GV001` → `GV020` | `gv123456` |

---

## 🗃 Thống kê Database

| Bảng | Số lượng |
|---|---|
| SinhVien | 500 |
| GiaoVien | 20 |
| MonHoc | 20 |
| HocPhan | 50 |
| LichHoc | 50 |
| DangKyHocPhan | 2,758 |
| BangDiem | 2,758 |

---

## 🛠 Tính năng nổi bật Database

### Stored Procedures (04_StoredProcedures.sql)
| Tên | Chức năng |
|---|---|
| `sp_DangNhap` | Xác thực đăng nhập (mật khẩu hash SHA2-256) |
| `sp_DangKyHocPhan` | Đăng ký học phần (kiểm tra trùng lịch, giới hạn tín chỉ) |
| `sp_XemBangDiem` | Xem bảng điểm + tính GPA tự động |
| `sp_XemLichHocSinhVien` | Xem thời khóa biểu |
| `sp_XemDanhSachHocPhan` | Danh sách học phần đang mở |
| `sp_CapNhatDiem` | Giảng viên cập nhật điểm |

### Triggers (05_Triggers.sql)
| Tên | Chức năng |
|---|---|
| `trg_DangKyHocPhan_AfterInsert` | Tự động cộng SiSoHienTai khi đăng ký |
| `trg_DangKyHocPhan_AfterDelete` | Tự động trừ SiSoHienTai khi hủy |
| `trg_KiemTraTrungLichHoc` | Chặn đăng ký trùng lịch học |

### Functions (03_Functions.sql)
| Tên | Chức năng |
|---|---|
| `f_TinhGPA` | Tính GPA theo tín chỉ |
| `f_XepLoaiHocLuc` | Xếp loại học lực (Xuất sắc/Giỏi/Khá/TB) |

---

## 🔧 Reset dữ liệu

Nếu muốn reset database về trạng thái ban đầu:
```bash
# Chạy lại file 02:
SOURCE sql/02_SampleData.sql;

# Hoặc dùng Python script:
python generate_data.py
```

---

## 📌 Lưu ý kỹ thuật

- File `02_SampleData.sql` dùng `SET FOREIGN_KEY_CHECKS = 0` khi import bulk — đây là kỹ thuật chuẩn, không phải lỗi
- Trigger kiểm tra trùng lịch hoạt động trong thời gian thực (BEFORE INSERT)
- BangDiem có cột `DiemTB` và `XepLoai` là **STORED GENERATED** — MySQL tự tính, không cần cập nhật thủ công
- Mật khẩu được hash bằng `SHA2(..., 256)` ngay trong MySQL — không lưu plaintext

---

*Đề tài: Quản lý sinh viên đăng ký học phần — Môn Hệ Quản Trị CSDL — UTH 2024*
