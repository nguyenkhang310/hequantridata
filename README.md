# HỆ THỐNG QUẢN LÝ ĐĂNG KÝ HỌC PHẦN (UTH PORTAL)

**Môn học:** Hệ Quản trị Cơ sở dữ liệu  
**Trường:** Đại học Giao thông Vận tải TP.HCM (UTH)  
**Đề tài số 6:** Quản lý sinh viên đăng ký học phần tín chỉ  

---

## 1. MÔ TẢ TỔNG QUAN

Hệ thống quản lý đăng ký học phần trực tuyến được xây dựng nhằm mô phỏng quy trình đăng ký tín chỉ thực tế của sinh viên UTH. Dự án tập trung sâu vào việc thiết kế và tối ưu hóa cơ sở dữ liệu quan hệ (MySQL), khai thác tối đa sức mạnh của hệ quản trị CSDL thông qua việc triển khai đồng bộ các đối tượng như Tables, Views, Functions, Stored Procedures và Triggers.

Bên cạnh đó, dự án được tích hợp một giao diện người dùng hiện đại (Frontend) và API xử lý dữ liệu (Backend) độc lập, sau đó được đóng gói thành một phần mềm Desktop duy nhất, mang lại trải nghiệm người dùng tối ưu và thuận tiện cho việc triển khai cũng như đánh giá.

---

## 2. KIẾN TRÚC VÀ CÔNG NGHỆ SỬ DỤNG

### Mô hình kiến trúc
Hệ thống được thiết kế theo mô hình 3 lớp (3-Tier Architecture) kết hợp với kiến trúc Client-Server, được đóng gói trong một môi trường Desktop:

1. **Lớp Giao diện (Presentation Layer - Frontend):** 
   - **Công nghệ:** ReactJS, TypeScript, TailwindCSS, Vite.
   - **Vai trò:** Hiển thị thông tin trực quan, tiếp nhận thao tác của người dùng (Sinh viên/Giảng viên).

2. **Lớp Xử lý (Application Layer - Backend):**
   - **Công nghệ:** Python, Flask (RESTful API), Flask-CORS.
   - **Vai trò:** Cầu nối giao tiếp, nhận request từ Frontend, phân giải tham số, gọi các Stored Procedures dưới Database và trả về dữ liệu theo định dạng chuẩn JSON.

3. **Lớp Dữ liệu (Data Layer - Database):**
   - **Công nghệ:** MySQL 8.0+.
   - **Vai trò:** Lưu trữ dữ liệu vật lý, đảm bảo tính toàn vẹn thông qua các Constraint và Trigger, xử lý logic nghiệp vụ lõi (Business Logic) bằng Stored Procedures và Functions.

4. **Lớp Đóng gói (Wrapper):**
   - **Công nghệ:** PyInstaller, PyWebview, Multi-threading.
   - **Vai trò:** Khởi chạy ngầm các tiến trình máy chủ (Flask & Node.js) và hiển thị giao diện web trong một cửa sổ ứng dụng Desktop độc lập (.exe).

### Sơ đồ kiến trúc hệ thống

```mermaid
graph TD
    subgraph LOP_DONG_GOI["Lớp đóng gói Desktop (Pywebview)"]
        UI["Giao diện Web (ReactJS)"]
    end
    
    subgraph LOP_BACKEND["Lớp Backend (Flask API)"]
        API["RESTful API Server"]
    end
    
    subgraph LOP_CSDL["Lớp Cơ sở dữ liệu (MySQL)"]
        DB[("MySQL Database")]
        SP["Stored Procedures"]
        TR["Triggers"]
        FN["Functions"]
        VW["Views"]
    end
    
    UI <-->|HTTP GET/POST JSON| API
    API <-->|Call Procedures / Queries| SP
    API <-->|Execute SQL| VW
    SP --> DB
    TR --> DB
    FN --> DB
    VW --> DB
```

---

## 3. CẤU TRÚC THƯ MỤC VÀ TẬP TIN DATABASE (6 SCRIPT KHỞI TẠO)

Hệ thống cơ sở dữ liệu được thiết kế chặt chẽ và chia thành 6 tệp lệnh SQL riêng biệt để dễ dàng quản lý và triển khai. Dưới đây là bảng tóm tắt cấu trúc:

| STT | Tên tập tin | Vai trò và Nội dung chi tiết |
|:---:|-------------|------------------------------|
| 1 | `01_CreateDatabase.sql` | **Khởi tạo cấu trúc nền tảng:** Chứa lệnh tạo Database `QuanLyDKHP` và định nghĩa cấu trúc 8 bảng thực thể. Thiết lập chặt chẽ PK, FK và các Constraint. |
| 2 | `02_SampleData.sql` | **Nạp dữ liệu mẫu:** Thêm 500 SV, 20 GV, 20 Môn học, 50 Học phần và 2.758 bản ghi đăng ký kèm điểm. (Sử dụng `SET FOREIGN_KEY_CHECKS = 0` để tối ưu Bulk Insert). |
| 3 | `03_Functions.sql` | **Hàm vô hướng (Scalar Functions):** Định nghĩa các hàm tính toán như `f_TinhGPA` và `f_XepLoaiHocLuc`. |
| 4 | `04_StoredProcedures.sql`| **Thủ tục lưu trữ (Stored Procedures):** Đóng gói logic nghiệp vụ CRUD, bao gồm đăng nhập, đăng ký học phần, cập nhật điểm... |
| 5 | `05_Triggers.sql` | **Bẫy sự kiện (Triggers):** Tự động hóa cập nhật sĩ số, kiểm tra điều kiện trùng lịch, bảo vệ xóa dữ liệu và ghi log (Audit). |
| 6 | `06_Views.sql` | **Khung nhìn (Views):** Tổng hợp dữ liệu báo cáo đa chiều (Bảng điểm, Lịch học, Xếp hạng GPA...) tối ưu hóa truy vấn JOIN. |
| * | `demo/` (Thư mục) | Chứa 5 kịch bản SQL độc lập nhằm giả lập các lỗi đồng thời (Concurrency) và mã lệnh khắc phục. |

---

## 4. SƠ ĐỒ THỰC THỂ KẾT HỢP (ERD)

```mermaid
erDiagram
    SinhVien {
        varchar MaSV PK
        varchar HoTen
        date NgaySinh
        varchar GioiTinh
        varchar Lop
        varchar MatKhau
    }
    
    GiaoVien {
        varchar MaGV PK
        varchar HoTen
        varchar KhoaBoMon
        varchar MatKhau
    }
    
    MonHoc {
        varchar MaMH PK
        varchar TenMH
        int SoTinChi
    }
    
    HocPhan {
        varchar MaHP PK
        varchar MaMH FK
        varchar MaGV FK
        varchar HocKy
        varchar NamHoc
        int SiSoToiDa
        int SiSoHienTai
    }
    
    LichHoc {
        int MaLich PK
        varchar MaHP FK
        varchar Thu
        int TietBD
        int TietKT
        varchar Phong
    }
    
    DangKyHocPhan {
        int MaDK PK
        varchar MaSV FK
        varchar MaHP FK
        date NgayDK
        varchar TrangThai
    }
    
    BangDiem {
        int MaDK PK
        decimal DiemCC
        decimal DiemGiuaKy
        decimal DiemCuoiKy
        decimal DiemTB
    }

    SinhVien ||--o{ DangKyHocPhan : "Thực hiện"
    HocPhan ||--o{ DangKyHocPhan : "Bao gồm"
    MonHoc ||--o{ HocPhan : "Mở thành"
    GiaoVien ||--o{ HocPhan : "Giảng dạy"
    HocPhan ||--o{ LichHoc : "Có lịch"
    DangKyHocPhan ||--|| BangDiem : "Sở hữu"
```

---

## 5. CHI TIẾT CẤU TRÚC CÁC BẢNG DỮ LIỆU

Dưới đây là chi tiết cấu trúc của 8 bảng dữ liệu trong hệ thống, bao gồm các ràng buộc (Constraints) quan trọng nhằm bảo đảm tính toàn vẹn dữ liệu:

### 5.1. Bảng `SinhVien` (Lưu thông tin sinh viên)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaSV` | VARCHAR(10) | PK, NOT NULL | Mã sinh viên (Khóa chính) |
| `HoTen` | VARCHAR(100) | NOT NULL | Họ và tên sinh viên |
| `NgaySinh` | DATE | | Ngày sinh |
| `GioiTinh` | ENUM | DEFAULT 'Nam' | Giới tính ('Nam', 'Nu', 'Khac') |
| `DiaChi` | VARCHAR(200) | | Địa chỉ liên hệ |
| `Email` | VARCHAR(100) | UNIQUE | Địa chỉ email (Duy nhất) |
| `SoDT` | VARCHAR(15) | | Số điện thoại liên lạc |
| `Lop` | VARCHAR(20) | | Lớp sinh hoạt |
| `KhoaHoc` | VARCHAR(20) | | Khóa học (VD: K21) |
| `MatKhau` | VARCHAR(255) | NOT NULL | Mật khẩu (Mã hóa SHA256) |
| `NgayTao` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Thời điểm tạo tài khoản |

### 5.2. Bảng `GiaoVien` (Lưu thông tin giảng viên)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaGV` | VARCHAR(10) | PK, NOT NULL | Mã giảng viên (Khóa chính) |
| `HoTen` | VARCHAR(100) | NOT NULL | Họ và tên giảng viên |
| `NgaySinh` | DATE | | Ngày sinh |
| `GioiTinh` | ENUM | DEFAULT 'Nam' | Giới tính ('Nam', 'Nu', 'Khac') |
| `Email` | VARCHAR(100) | UNIQUE | Địa chỉ email (Duy nhất) |
| `SoDT` | VARCHAR(15) | | Số điện thoại |
| `KhoaBoMon` | VARCHAR(100) | | Khoa / Bộ môn công tác |
| `HocVi` | VARCHAR(50) | DEFAULT 'ThacSi' | Học vị (ThS, TS, PGS...) |
| `MatKhau` | VARCHAR(255) | NOT NULL | Mật khẩu (Mã hóa SHA256) |
| `NgayTao` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Thời điểm tạo tài khoản |

### 5.3. Bảng `MonHoc` (Danh mục môn học)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaMH` | VARCHAR(10) | PK, NOT NULL | Mã môn học (Khóa chính) |
| `TenMH` | VARCHAR(100) | NOT NULL | Tên môn học |
| `SoTinChi` | INT | NOT NULL, CHK(1-10) | Số tín chỉ (Chỉ từ 1 đến 10) |
| `SoTietLT` | INT | NOT NULL, DEFAULT 30 | Số tiết lý thuyết |
| `SoTietTH` | INT | NOT NULL, DEFAULT 0 | Số tiết thực hành |
| `MoTa` | TEXT | | Mô tả thông tin môn học |

### 5.4. Bảng `HocPhan` (Lớp mở theo học kỳ)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaHP` | VARCHAR(10) | PK, NOT NULL | Mã học phần (Khóa chính) |
| `MaMH` | VARCHAR(10) | FK, NOT NULL | Mã môn học (Tham chiếu `MonHoc`) |
| `MaGV` | VARCHAR(10) | FK | Mã giảng viên (Tham chiếu `GiaoVien`) |
| `HocKy` | TINYINT | NOT NULL, CHK(1-3) | Học kỳ diễn ra (1, 2, 3) |
| `NamHoc` | VARCHAR(9) | NOT NULL | Năm học (VD: 2023-2024) |
| `SiSoToiDa` | INT | NOT NULL, DEFAULT 50 | Sĩ số tối đa của lớp |
| `SiSoHienTai`| INT | NOT NULL, DEFAULT 0 | Sĩ số hiện tại (Kiểm tra <= Sĩ số tối đa) |
| `NgayBatDauDK`| DATE | | Ngày bắt đầu mở đăng ký |
| `NgayKetThucDK`| DATE | | Ngày đóng đăng ký |
| `TrangThai` | ENUM | DEFAULT 'MoDangKy' | Trạng thái (MoDangKy, DongDangKy...) |

### 5.5. Bảng `LichHoc` (Thời khóa biểu của học phần)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaLich` | INT | PK, AUTO_INCREMENT | Mã lịch học (Tự tăng) |
| `MaHP` | VARCHAR(10) | FK, NOT NULL | Mã học phần (Tham chiếu `HocPhan`) |
| `Thu` | ENUM | NOT NULL | Thứ trong tuần ('Thu2' -> 'ChuNhat') |
| `TietBD` | TINYINT | NOT NULL, CHK | Tiết bắt đầu (>=1 và < TietKT) |
| `TietKT` | TINYINT | NOT NULL, CHK | Tiết kết thúc (<=15) |
| `Phong` | VARCHAR(20) | NOT NULL | Mã phòng học (VD: V-A.01) |

### 5.6. Bảng `DangKyHocPhan` (Thông tin sinh viên đăng ký)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaDK` | INT | PK, AUTO_INCREMENT | Mã phiếu đăng ký (Tự tăng) |
| `MaSV` | VARCHAR(10) | FK, NOT NULL, UQ | Mã sinh viên (Tham chiếu `SinhVien`) |
| `MaHP` | VARCHAR(10) | FK, NOT NULL, UQ | Mã học phần (Tham chiếu `HocPhan`) |
| `NgayDK` | DATETIME | DEFAULT CURRENT_TIMESTAMP| Ngày thực hiện thao tác đăng ký |
| `TrangThai` | ENUM | DEFAULT 'DaDuyet' | Trạng thái (DaDuyet, HuyBo, HoanThanh) |

*(Lưu ý: Cặp `MaSV` và `MaHP` là UNIQUE để tránh 1 sinh viên đăng ký 1 học phần 2 lần)*

### 5.7. Bảng `BangDiem` (Kết quả học tập theo học phần)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaBD` | INT | PK, AUTO_INCREMENT | Mã bảng điểm (Tự tăng) |
| `MaDK` | INT | FK, NOT NULL, UNIQUE | Mã đăng ký (Tham chiếu `DangKyHocPhan`) |
| `DiemCC` | DECIMAL(4,2) | NOT NULL, DEFAULT 0.00 | Điểm chuyên cần (Trọng số 10%) |
| `DiemGiuaKy` | DECIMAL(4,2) | NOT NULL, DEFAULT 0.00 | Điểm giữa kỳ (Trọng số 30%) |
| `DiemCuoiKy` | DECIMAL(4,2) | NOT NULL, DEFAULT 0.00 | Điểm cuối kỳ (Trọng số 60%) |
| `DiemTB` | DECIMAL(4,2) | GENERATED STORED | Điểm tổng kết tự động tính |
| `XepLoai` | VARCHAR(2) | GENERATED STORED | Tự động xếp loại (A, B, C, D, F) |
| `NgayCapNhat`| DATETIME | ON UPDATE | Thời gian cập nhật điểm cuối cùng |
| `GhiChu` | VARCHAR(200) | | Các ghi chú bổ sung (VD: Cấm thi) |

### 5.8. Bảng `LogHoatDong` (Nhật ký kiểm toán / Audit Log)
| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả chi tiết |
|---------|--------------|-----------|----------------|
| `MaLog` | INT | PK, AUTO_INCREMENT | ID dòng log (Tự tăng) |
| `MaNguoiDung`| VARCHAR(10) | | ID của người dùng thao tác |
| `VaiTro` | ENUM | DEFAULT 'SinhVien' | Phân quyền (SinhVien, GiaoVien, Admin) |
| `HanhDong` | VARCHAR(100) | NOT NULL | Hành động (VD: Đăng nhập, Hủy HP) |
| `BangTacDong`| VARCHAR(50) | | Tên bảng bị ảnh hưởng dữ liệu |
| `MaBanGhi` | VARCHAR(50) | | Khóa chính của dòng dữ liệu bị ảnh hưởng|
| `ThoiGian` | DATETIME | DEFAULT CURRENT_TIMESTAMP| Thời điểm xảy ra hành động |
| `GhiChu` | TEXT | | Ghi chú thêm (VD: IP hoặc nội dung lỗi)|

---

## 6. DANH SÁCH 10 THỦ TỤC LƯU TRỮ (STORED PROCEDURES)

Hệ thống đóng gói toàn bộ logic nghiệp vụ (Business Logic) xuống cơ sở dữ liệu thông qua 10 Stored Procedures, giúp tăng tính bảo mật và hiệu năng xử lý:

| STT | Tên thủ tục (Stored Procedure) | Phân quyền | Chức năng chính |
|:---:|--------------------------------|------------|-----------------|
| 1 | `sp_DangNhap` | SV / GV | Xác thực đăng nhập sinh viên hoặc giáo viên (Băm mật khẩu SHA256) |
| 2 | `sp_DangKyHocPhan` | SinhVien | Đăng ký học phần - kiểm tra điều kiện tiên quyết, trùng lịch, giới hạn tín chỉ |
| 3 | `sp_HuyDangKyHocPhan` | SinhVien | Hủy đăng ký học phần, cập nhật lại trạng thái |
| 4 | `sp_XemDanhSachHocPhan` | Chung | Xem danh sách các học phần đang mở đăng ký trong học kỳ hiện tại |
| 5 | `sp_XemLichHocSinhVien` | SinhVien | Rút trích thời khóa biểu cá nhân của sinh viên theo học kỳ |
| 6 | `sp_XemBangDiem` | SinhVien | Xem toàn bộ bảng điểm chi tiết các môn và GPA tích lũy |
| 7 | `sp_CapNhatDiem` | GiaoVien | Giáo viên nhập hoặc cập nhật điểm (CC, GK, CK) cho sinh viên |
| 8 | `sp_ThemSinhVien` | Admin | Quản trị viên thêm sinh viên mới vào hệ thống |
| 9 | `sp_ThongKeSinhVienTheoHP` | GiaoVien | Xem danh sách toàn bộ sinh viên đã đăng ký vào một học phần |
| 10 | `sp_DoiMatKhau` | SV / GV | Đổi mật khẩu tài khoản người dùng an toàn |

---

## 7. DANH SÁCH 6 CƠ CHẾ KÍCH HOẠT TỰ ĐỘNG (TRIGGERS)

Các Triggers đóng vai trò là lớp bảo vệ cuối cùng (Last line of defense) để duy trì tính toàn vẹn dữ liệu và tự động hóa các tác vụ ngầm:

| STT | Tên Trigger | Sự kiện (Event) | Bảng tác động | Chức năng chính |
|:---:|-------------|-----------------|---------------|-----------------|
| 1 | `trg_BEFORE_DangKy_KiemTra` | `BEFORE INSERT` | `DangKyHocPhan` | Tự động kiểm tra trùng lịch học TRƯỚC KHI sinh viên đăng ký |
| 2 | `trg_AFTER_DangKy_CapNhatSiSo` | `AFTER INSERT` | `DangKyHocPhan` | Tự động tăng sĩ số `HocPhan` và ghi Log khi đăng ký thành công |
| 3 | `trg_AFTER_HuyDangKy_CapNhatSiSo`| `AFTER UPDATE` | `DangKyHocPhan` | Tự động giảm sĩ số khi sinh viên hủy đăng ký (Trạng thái -> HuyBo) |
| 4 | `trg_BEFORE_XoaHocPhan_BaoVe` | `BEFORE DELETE` | `HocPhan` | Ngăn chặn việc xóa học phần nếu đã có sinh viên đăng ký |
| 5 | `trg_AFTER_Insert/UpdateDiem` | `AFTER INS/UPD` | `BangDiem` | Ghi log kiểm toán (Audit Trail) mỗi khi điểm số bị thay đổi |
| 6 | `trg_BEFORE_XoaSinhVien_BaoVe` | `BEFORE DELETE` | `SinhVien` | Ngăn xóa sinh viên đang có lịch học hợp lệ, tránh mồ côi dữ liệu |

---

## 8. DANH SÁCH 5 KHUNG NHÌN (VIEWS) PHỤC VỤ BÁO CÁO

Các Views được tạo sẵn nhằm lưu lại các câu truy vấn JOIN phức tạp, giúp việc xuất báo cáo (Reports) trở nên nhanh chóng và dễ dàng:

| STT | Tên View (Khung nhìn) | Chức năng chính |
|:---:|-----------------------|-----------------|
| 1 | `vw_BangDiemTongHop` | Bảng điểm đầy đủ của tất cả sinh viên (JOIN từ 5 bảng dữ liệu) |
| 2 | `vw_LichHocTongHop` | Thời khóa biểu tổng hợp của toàn bộ sinh viên trong hệ thống |
| 3 | `vw_ThongKeHocPhan` | Báo cáo tỷ lệ lấp đầy, số chỗ còn lại và điểm trung bình của từng học phần |
| 4 | `vw_XepHangSinhVien` | Bảng xếp hạng học lực, GPA toàn trường (Dùng để xét học bổng) |
| 5 | `vw_LogHoatDongChiTiet` | Nhật ký hoạt động (Audit Log) có liên kết hiển thị rõ tên người dùng |

---

## 9. MÔ PHỎNG VÀ XỬ LÝ LỖI ĐỒNG THỜI (CONCURRENCY ERRORS)

Dự án cung cấp sẵn các kịch bản để mô phỏng 5 lỗi đồng thời (Concurrency Transactions) kinh điển. Các script này đã có sẵn trong thư mục `sql/demo/`.

> **Lưu ý thực hành:** Để mô phỏng chân thực nhất bản chất của các lỗi đồng thời, bạn cần mở **2 Tab truy vấn (Query Tabs)** riêng biệt trên phần mềm MySQL Workbench hoặc Navicat (Tab 1 đóng vai trò là **Session A**, Tab 2 là **Session B**). Mẹo: Trong Workbench, bạn có thể nhấn giữ chuột vào tên Tab 2 và kéo sang mép lề bên phải để chia đôi màn hình. Sau đó, copy code tương ứng vào từng Tab và **bôi đen chạy lần lượt theo từng bước (Bước 1, Bước 2...)**.

### Lỗi 1: Lost Update (Mất dữ liệu cập nhật)
- **Kịch bản:** 2 giao dịch cùng lúc đọc và cập nhật sĩ số, dẫn đến việc ghi đè lên nhau.
- **Cách thực hiện:** Copy nội dung trong `sql/demo/Loi1_LostUpdate.sql` vào 2 Tab và chạy theo từng bước.
- **Nơi chụp ảnh:** Bạn hãy chụp toàn màn hình có 2 tab Session A và B đặt cạnh nhau, làm nổi bật kết quả điểm bị ghi đè sai. Lưu ảnh thành `docs/lost_update.png` và cập nhật ảnh vào thư mục `docs/`.
![Lỗi Lost Update](docs/lost_update.png)

### Lỗi 2: Dirty Read (Đọc dữ liệu rác)
- **Kịch bản:** Đọc dữ liệu điểm đang được sửa nhưng chưa được xác nhận (Uncommitted), sau đó giao dịch sửa bị hủy (Rollback).
- **Cách thực hiện:** Copy nội dung trong `sql/demo/Loi2_DirtyRead.sql` vào 2 Tab.
- **Nơi chụp ảnh:** Chụp khoảnh khắc Session B (Tab 2) nhìn thấy điểm ảo (ví dụ 9.0), sau đó Session A gọi lệnh ROLLBACK đưa điểm về lại 7.5. Lưu ảnh thành `docs/dirty_read.png`.
![Lỗi Dirty Read](docs/dirty_read.png)

### Lỗi 3: Non-Repeatable Read (Đọc không thể lặp lại)
- **Kịch bản:** Đọc cùng một dữ liệu điểm 2 lần trong cùng một phiên nhưng ra 2 kết quả khác nhau do có người khác vừa xen vào sửa.
- **Cách thực hiện:** Copy nội dung trong `sql/demo/Loi3_NonRepeatableRead.sql` vào 2 Tab.
- **Nơi chụp ảnh:** Chụp màn hình Tab 1 cho thấy 2 lần chạy lệnh `SELECT` ở Bước 1 và Bước 3 cho ra 2 kết quả khác nhau. Lưu ảnh thành `docs/non_repeatable_read.png`.
![Lỗi Non Repeatable Read](docs/non_repeatable_read.png)

### Lỗi 4: Phantom Read (Đọc bóng ma)
- **Kịch bản:** Thống kê số lượng sinh viên 2 lần trong một phiên, lần 2 tự nhiên thấy lòi ra thêm một dòng "bóng ma" (do người khác vừa chèn thêm).
- **Cách thực hiện:** Copy nội dung trong `sql/demo/Loi4_PhantomRead.sql` vào 2 Tab.
- **Nơi chụp ảnh:** Chụp màn hình Tab 1 cho thấy số lượng bản ghi đếm được ở Bước 1 và Bước 3 bị lệch nhau. Lưu ảnh thành `docs/phantom_read.png`.
![Lỗi Phantom Read](docs/phantom_read.png)

### Lỗi 5: Deadlock (Khóa cứng)
- **Kịch bản:** Tiến trình A giữ tài nguyên X chờ Y. Tiến trình B giữ Y chờ X. Hai bên treo nhau và MySQL phải chủ động ngắt 1 bên.
- **Cách thực hiện:** Copy nội dung trong `sql/demo/Loi5_Deadlock.sql` vào 2 Tab và chạy chéo nhau.
- **Nơi chụp ảnh:** Chụp thông báo lỗi màu đỏ (Error Code: 1213 - Deadlock found when trying to get lock) xuất hiện ở phần Action Output của Workbench. Lưu ảnh thành `docs/deadlock.png`.
![Lỗi Deadlock](docs/deadlock.png)

---

## 10. HƯỚNG DẪN CÀI ĐẶT VÀ VẬN HÀNH

### 10.1. Yêu cầu hệ thống tối thiểu
- **Hệ điều hành:** Windows 10/11 (64-bit)
- **Hệ quản trị CSDL:** MySQL Server 8.0 trở lên
- **Môi trường thực thi:** Python 3.10+ và Node.js 18+ (Dành cho việc biên dịch và khởi chạy dự án)

### 10.2. Các bước triển khai Cơ sở dữ liệu
Mở phần mềm quản trị cơ sở dữ liệu (MySQL Workbench, HeidiSQL hoặc Navicat) và thực thi lần lượt các tập tin theo đúng thứ tự quy định sau:
1. `sql/01_CreateDatabase.sql`
2. `sql/02_SampleData.sql`
3. `sql/03_Functions.sql`
4. `sql/04_StoredProcedures.sql`
5. `sql/05_Triggers.sql`
6. `sql/06_Views.sql`

*Lưu ý kỹ thuật: Tập tin `02_SampleData.sql` sử dụng chỉ thị `SET FOREIGN_KEY_CHECKS = 0;` nhằm mục đích tối ưu hóa quá trình chèn dữ liệu hàng loạt (Bulk Insert) và tạm thời bỏ qua các Trigger xác thực để nạp 2.758 bản ghi một cách nhanh chóng nhất.*

### 10.3. Cấu hình kết nối
Mở tập tin `api.py` tại thư mục gốc, điều chỉnh thông tin tại biến `DB_CONFIG` cho khớp với tài khoản quản trị MySQL cục bộ của bạn:
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'MAT_KHAU_CUA_BAN',
    'database': 'QuanLyDKHP'
}
```

### 10.4. Khởi chạy ứng dụng
Hệ thống được thiết lập kịch bản tự động hóa tối đa nhằm thuận tiện cho việc đánh giá:

**Phương thức 1: Khởi tạo tự động (Dành cho máy tính mới chạy lần đầu)**
Tại thư mục gốc, khởi chạy tập tin `SETUP.bat`. Script sẽ tự động chẩn đoán môi trường máy tính, tải xuống toàn bộ thư viện Python (như Flask, Pywebview) và các gói Node.js tương ứng mà không cần gõ lệnh thủ công.

**Phương thức 2: Chạy trực tiếp ứng dụng (Người dùng cuối)**
Khởi chạy tập tin `UTH_Portal_Web.exe`. Phần mềm sẽ tự động cấp phát tài nguyên luồng (threads), khởi động máy chủ API nội bộ và hiển thị giao diện phần mềm.

**Thông tin Tài khoản Thử nghiệm:**
- Phân quyền Sinh viên: Tài khoản từ `SV001` đến `SV500` (Mật khẩu mặc định: `sv123456`)
- Phân quyền Giảng viên: Tài khoản từ `GV001` đến `GV020` (Mật khẩu mặc định: `gv123456`)
