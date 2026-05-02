# KỊCH BẢN THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN MÔN HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU
*(Tài liệu này bao gồm toàn bộ kịch bản demo và mô tả chi tiết 5 lỗi Transaction để phục vụ làm Báo Cáo Đồ Án)*

---

## ✅ KIỂM TRA TRẠNG THÁI CÁC FILE SQL (Cập nhật mới nhất)

| File | Trạng thái | Nội dung |
|---|---|---|
| `01_CreateDatabase.sql` | ✅ Nguyên vẹn | Tạo 8 bảng, khóa chính, khóa ngoại |
| `02_SampleData.sql` | 🆕 **Cập nhật mới** | **500 SV, 20 GV, 50 HP, 2.758 lượt ĐK** |
| `03_Functions.sql` | ✅ Nguyên vẹn | 6 hàm tính GPA, xếp loại... |
| `04_StoredProcedures.sql` | ✅ Nguyên vẹn | 10+ Stored Procedures |
| `05_Triggers.sql` | ✅ Nguyên vẹn | Trigger chặn trùng lịch, cập nhật sĩ số |
| `06_Views.sql` | ✅ Nguyên vẹn | View TKB, bảng điểm tổng hợp |
| `demo/` | ✅ Nguyên vẹn | 5 demo lỗi Transaction |

> ⚠️ **Lưu ý quan trọng:** File `02_SampleData.sql` dùng `SET FOREIGN_KEY_CHECKS = 0` khi import hàng loạt để bypass Trigger kiểm tra trùng lịch — đây là kỹ thuật chuẩn khi import dữ liệu bulk, **không phải lỗi**.

---

## PHẦN 1: GIỚI THIỆU TỔNG QUAN VÀ GIẢI THÍCH 6 FILE SQL
*(Khi mới lên bảng, thầy sẽ bảo: "Rồi, nhóm làm cái gì, giới thiệu xem. Hệ thống có mấy bảng?")*

**🗣️ Bạn nói:**
"Dạ thưa thầy, đề tài của nhóm em là **Hệ thống Quản lý Đăng ký Học phần của Sinh viên — UTH Portal**. Nhóm em đã tách rời Database thành **6 file script riêng biệt**, chạy lần lượt từ 01 đến 06."

**🗣️ Giải thích chi tiết 6 file (Nội dung dùng để ghi vào Báo cáo):**

1. **File `01_CreateDatabase.sql`:**
   "Dạ file này khởi tạo Database mới hoàn toàn. Hệ thống của em có **8 bảng**: SinhVien, GiaoVien, MonHoc, HocPhan, LichHoc, DangKyHocPhan, BangDiem, LogHoatDong. Bảng trung tâm là **DangKyHocPhan** — liên kết N-N giữa Sinh Viên và Học Phần. File này cũng cấu hình sẵn khóa chính (Primary Key) và khóa ngoại (Foreign Key) đảm bảo tính toàn vẹn dữ liệu."

2. **File `02_SampleData.sql`:**
   "File này chứa lệnh `INSERT` để tạo dữ liệu mẫu. Em đã tạo **500 Sinh viên, 20 Giáo viên, 20 Môn học, 50 Học phần và 2.758 lượt đăng ký** kèm điểm số thực tế. Đặc biệt có `SET FOREIGN_KEY_CHECKS = 0` và `TRUNCATE` ở đầu — nếu lỡ demo sai, chỉ cần chạy lại file này là dữ liệu quay về trạng thái ban đầu ngay lập tức."

3. **File `03_Functions.sql`:**
   "Em viết **6 Hàm (Functions)** để tính toán tự động. Ví dụ hàm `f_TinhGPA` tự quét bảng điểm và tính GPA, hàm `f_XepLoaiHocLuc` dịch từ GPA sang chữ (Giỏi/Khá/Trung Bình) theo quy chế nhà trường."

4. **File `04_StoredProcedures.sql`:**
   "Đây là trái tim của hệ thống — chứa **10+ Stored Procedures** phục vụ nghiệp vụ chính. Quan trọng nhất là `sp_DangKyHocPhan`: khi sinh viên bấm đăng ký, Store này kiểm tra lịch học có bị trùng không, sĩ số lớp đã đầy chưa, có vượt 30 tín chỉ/kỳ không. Nếu vi phạm, Store tự báo lỗi chứ không cho INSERT vào Database."

5. **File `05_Triggers.sql`:**
   "Trigger tự động hóa hoàn toàn. Khi có `INSERT` vào bảng DangKyHocPhan, Trigger `trg_DangKyHocPhan_AfterInsert` tự cộng 1 vào `SiSoHienTai`. Đồng thời có Trigger ghi `LogHoatDong` — ai sửa điểm hay đổi mật khẩu đều bị lưu log lại giống History."

6. **File `06_Views.sql`:**
   "Cuối cùng là View phục vụ báo cáo. Thay vì mỗi lần JOIN 5-6 bảng rất nặng, em tạo sẵn View `v_ThoiKhoaBieu_SinhVien`. Chỉ cần `SELECT * FROM View` là ra lịch học đầy đủ ngay."

---

## PHẦN 2: CHẠY LỆNH DEMO THỰC TẾ
*(Sau khi giải thích xong, thầy sẽ bảo: "Được rồi, chạy thử tui xem")*

Bạn mở MySQL Workbench (hoặc HeidiSQL) và paste từng đoạn vào chạy:

**1. Demo xem dữ liệu 500 sinh viên:**
```sql
-- Xem tổng quan dữ liệu
SELECT COUNT(*) AS TongSV FROM SinhVien;
SELECT COUNT(*) AS TongDangKy FROM DangKyHocPhan;

-- Xem vài sinh viên
SELECT MaSV, HoTen, Lop, KhoaHoc FROM SinhVien LIMIT 10;
```
**🗣️ Bạn nói:** "Dạ thầy xem, hệ thống đang có 500 sinh viên và 2.758 lượt đăng ký học phần thực tế."

**2. Demo Stored Procedure đăng nhập:**
```sql
CALL sp_DangNhap('SV001', 'sv123456', 'SinhVien', @ok, @ten, @msg);
SELECT @ok AS ThanhCong, @ten AS HoTen, @msg AS ThongBao;
```
**🗣️ Bạn nói:** "Dạ Stored Procedure sp_DangNhap xử lý xác thực — nó kiểm tra mật khẩu đã hash SHA2-256 trong DB, trả về kết quả qua OUT parameter."

**3. Demo Function tính GPA:**
```sql
SELECT 
    f_TinhGPA('SV001') AS GPA,
    f_XepLoaiHocLuc(f_TinhGPA('SV001')) AS XepLoai;
```
**🗣️ Bạn nói:** "Hàm tự quét toàn bộ điểm của SV001 trong bảng BangDiem, tính trung bình có trọng số rồi trả về GPA và xếp loại."

**4. Demo Trigger tự động cập nhật sĩ số:**
```sql
-- Xem sĩ số trước
SELECT MaHP, SiSoHienTai, SiSoToiDa FROM HocPhan WHERE MaHP = 'HP001';

-- SV mới chưa đăng ký môn này (tìm SV chưa đăng ký HP001)
SELECT MaSV FROM SinhVien 
WHERE MaSV NOT IN (SELECT MaSV FROM DangKyHocPhan WHERE MaHP = 'HP001')
LIMIT 1;

-- Giả sử kết quả ra SV099, thực hiện đăng ký (đổi MaSV cho phù hợp)
INSERT INTO DangKyHocPhan(MaSV, MaHP, TrangThai) VALUES ('SV099', 'HP001', 'DaDuyet');

-- Xem sĩ số sau — Trigger tự cộng thêm 1
SELECT MaHP, SiSoHienTai, SiSoToiDa FROM HocPhan WHERE MaHP = 'HP001';
```
**🗣️ Bạn nói:** "Dạ thầy thấy không — sĩ số tự động nhảy lên 1 mà em không cần viết lệnh UPDATE nào hết. Đó là Trigger `trg_DangKyHocPhan_AfterInsert` chạy ngầm sau mỗi lần INSERT."

**5. Demo Trigger chặn trùng lịch học:**
```sql
-- Tìm một SV đang học HP001 (có lịch nhất định)
SELECT dk.MaSV, lh.Thu, lh.TietBD, lh.TietKT 
FROM DangKyHocPhan dk
JOIN LichHoc lh ON dk.MaHP = lh.MaHP
WHERE dk.MaHP = 'HP001' LIMIT 1;

-- Tìm HP khác có CÙNG lịch với HP001
SELECT hp.MaHP, lh2.Thu, lh2.TietBD FROM HocPhan hp
JOIN LichHoc lh2 ON hp.MaHP = lh2.MaHP
JOIN LichHoc lh1 ON lh1.MaHP = 'HP001' 
WHERE lh2.Thu = lh1.Thu AND lh2.TietBD = lh1.TietBD
AND hp.MaHP != 'HP001' LIMIT 1;

-- Thử đăng ký HP trùng lịch với SV đó → Trigger sẽ báo lỗi
-- (thay MaSV và MaHP cho phù hợp với kết quả trên)
INSERT INTO DangKyHocPhan(MaSV, MaHP, TrangThai) VALUES ('SV001', 'HP_TRUNG_LICH', 'DaDuyet');
```
**🗣️ Bạn nói:** "Dạ thầy thấy lỗi `45002: Lịch học bị trùng` ngay — đây là Trigger `trg_KiemTraTrungLichHoc` chạy BEFORE INSERT, nó chặn từ đầu, không cho dữ liệu sai vào Database ạ."

**6. Demo Bảng điểm + View:**
```sql
CALL sp_XemBangDiem('SV001');

-- Hoặc dùng View
SELECT * FROM v_BangDiem_SinhVien WHERE MaSV = 'SV001';
```

---

## PHẦN 3: KỊCH BẢN DEMO & BÁO CÁO 5 LỖI TRANSACTION (BƯỚC ĂN ĐIỂM 10)

*(Phần này đưa vào BÁO CÁO CUỐI KỲ và đọc lúc thuyết trình)*

### 🚀 3.1. LỖI 1: LOST UPDATE (MẤT DỮ LIỆU CẬP NHẬT)
**💻 Cách Demo:** Mở file `sql/demo/Loi1_LostUpdate.sql` → nhấn Execute All.
- **Tab 1:** "Lớp HP001 ban đầu có 57 lượt đăng ký."
- **Tab 2:** "SV_A và SV_B cùng lúc đăng ký. Cả 2 đọc giá trị 57, tự tính lên 58."
- **Tab 3:** "Transaction B ghi đè lên A → DB chỉ ghi nhận 58 thay vì 59. Mất 1 lượt đăng ký."
- **Tab 4:** "Fix: Dùng `UPDATE SiSo = SiSo + 1` thay vì đọc-tính-ghi. MySQL xử lý atomic, kết quả đúng 59."

### 🚀 3.2. LỖI 2: DIRTY READ (ĐỌC DỮ LIỆU BẨN)
**💻 Cách Demo:** Mở file `sql/demo/Loi2_DirtyRead.sql` → Execute All.
- **Tab 1:** "Điểm thi ban đầu của SV001 là một giá trị X."
- **Tab 2:** "Giáo viên A sửa điểm thành 10.0 nhưng **chưa COMMIT**."
- **Tab 3:** "Với mức cô lập `READ UNCOMMITTED`, SV_B đọc thấy điểm 10.0 — đây là dữ liệu bẩn."
- **Tab 4:** "Giáo viên A ROLLBACK, điểm về lại X. SV_B vừa đọc dữ liệu không tồn tại."
- **Fix:** "Nâng lên `READ COMMITTED` — chỉ đọc dữ liệu đã COMMIT."

### 🚀 3.3. LỖI 3: NON-REPEATABLE READ (ĐỌC KHÔNG LẶP LẠI)
**💻 Cách Demo:** Mở file `sql/demo/Loi3_NonRepeatableRead.sql` → Execute All.
- **Tab 2:** "Transaction báo cáo đọc điểm SV001 lần 1 = 7.50."
- **Tab 3:** "Giáo viên B cập nhật điểm thành 9.0 và COMMIT."
- **Tab 4:** "Transaction báo cáo đọc lại lần 2 = 9.0. Cùng 1 báo cáo, cùng 1 người mà điểm thay đổi."
- **Fix:** "Dùng `REPEATABLE READ` (mặc định InnoDB) — snapshot tại thời điểm bắt đầu, không thay đổi."

### 🚀 3.4. LỖI 4: PHANTOM READ (ĐỌC THẤY "BÓNG MA")
**💻 Cách Demo:** Mở file `sql/demo/Loi4_PhantomRead.sql` → Execute All.
- **Tab 1:** "Đếm số SV đăng ký HP001 = 57 người."
- **Tab 2:** "Một SV mới INSERT đăng ký HP001 thành công."
- **Tab 3:** "Đếm lại = 58. Xuất hiện 1 dòng 'bóng ma'. Khác lỗi 3 (UPDATE) — lỗi này do INSERT."
- **Fix:** "Dùng `SERIALIZABLE` + Range Lock — mọi INSERT vào HP001 bị treo cho đến khi báo cáo xong."

### 🚀 3.5. LỖI 5: DEADLOCK (BẾ TẮC KHÓA)
**💻 Cách Demo:** Mở 2 tab query song song — xem hướng dẫn trong `sql/demo/Loi5_Deadlock.sql`.
- **Kịch bản:** SV_A khóa HP001 chờ HP002. SV_B khóa HP002 chờ HP001.
- **Kết quả:** MySQL phát hiện Deadlock, tự động Rollback 1 transaction, trả lỗi `Error 1213`.
- **Fix:** "Quy định thứ tự khóa bảng cố định trong code backend (luôn HP nhỏ trước). Thêm `try-catch` retry khi gặp lỗi 1213."

---

## PHẦN 4: DEMO GIAO DIỆN WEB (ĐIỂM CỘNG)

*(Sau khi demo SQL xong, bật web lên gây ấn tượng với thầy cô)*

1. **Mở trình duyệt → `http://localhost:8080`**
2. **Đăng nhập Sinh viên:** `SV001` / `sv123456`
   - Xem Dashboard: GPA, tín chỉ tích lũy, số môn đã đăng ký
   - Xem Lịch học: Hiển thị thời khóa biểu theo thứ/tiết
   - Xem Bảng điểm: Toàn bộ điểm từ database thực
   - Đăng ký học phần: Danh sách 50 học phần, bấm đăng ký thực
3. **Đăng nhập Giảng viên:** `GV001` / `gv123456`
   - Xem danh sách lớp giảng dạy
   - Nhập/sửa điểm sinh viên

**🗣️ Bạn nói:** "Dạ thưa thầy, toàn bộ dữ liệu trên giao diện này đều lấy trực tiếp từ MySQL qua API — không có dữ liệu giả lập nào hết. Khi sinh viên đăng ký trên web, Stored Procedure và Trigger vẫn hoạt động đầy đủ ạ."

---

🎉 **HOÀN THÀNH KỊCH BẢN**
*Copy phần 3.1 → 3.5 vào file Word báo cáo là đủ nội dung khoa học, chuẩn điểm A+.*
