# KỊCH BẢN THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN MÔN HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU
*(Tài liệu này bao gồm toàn bộ kịch bản demo và mô tả chi tiết 5 lỗi Transaction để phục vụ làm Báo Cáo Đồ ÁN)*

---

## PHẦN 1: GIỚI THIỆU TỔNG QUAN VÀ GIẢI THÍCH 6 FILE SQL
*(Khi mới lên bảng, thầy sẽ bảo: "Rồi, nhóm làm cái gì, giới thiệu xem. Hệ thống có mấy bảng?")*

**🗣️ Bạn nói:**
"Dạ thưa thầy, đề tài của nhóm em là **Hệ thống Quản lý Đăng ký Học phần của Sinh viên**. Để dễ quản lý code và bàn giao, nhóm em đã tách rời Database thành **6 file script riêng biệt**, chạy lần lượt từ 01 đến 06."

**🗣️ Giải thích chi tiết 6 file (Nội dung dùng để ghi vào Báo cáo):**

1. **File `01_CreateDatabase.sql`:** 
   "Dạ file này dùng để khởi tạo Database mới hoàn toàn. Hệ thống của em có **8 bảng** (SinhVien, GiaoVien, MonHoc, HocPhan, LichHoc, DangKyHocPhan, BangDiem, LogHoatDong). Bảng trung tâm là **DangKyHocPhan**, liên kết N-N giữa Sinh Viên và Học Phần. File này em cũng cấu hình sẵn các khóa chính (Primary Key) và khóa ngoại (Foreign Key) để đảm bảo không bị rác dữ liệu."

2. **File `02_SampleData.sql`:** 
   "File này chứa lệnh `INSERT` để tạo dữ liệu mẫu cho hệ thống test. Em đã mock-up 15 Sinh viên, 5 Giáo viên, 10 Môn học và các học phần tương ứng. Đặc biệt em có chèn mã `SET FOREIGN_KEY_CHECKS = 0` và `TRUNCATE` ở đầu, để có lỡ demo sai, em chỉ cần chạy lại file này là dữ liệu sẽ quay về trạng thái sạch ban đầu."

3. **File `03_Functions.sql`:**
   "Ở đây em viết **6 Hàm (Functions)** để tính toán tự động. Ví dụ em có hàm `f_TinhGPA` để tự đếm số tín chỉ và điểm của sinh viên rồi chia trung bình ra GPA, hay hàm `f_XepLoaiHocLuc` tự động dịch từ GPA sang chữ (Giỏi/Khá/Trung Bình) dựa theo quy chế trường."

4. **File `04_StoredProcedures.sql`:**
   "Đây là trái tim của hệ thống chứa các nghiệp vụ chính (10 Store). Quan trọng nhất là `sp_DangKyHocPhan`, khi sinh viên bấm đăng ký, Store này sẽ kiểm tra xem lớp đó có bị trùng lịch học không, có vượt quá 30 tín chỉ 1 kỳ không. Nếu không thỏa mãn, Store tự động báo lỗi chứ không cho chèn vào Database."

5. **File `05_Triggers.sql`:**
   "Em dùng Trigger chủ yếu để tự động hóa. Chẳng hạn khi một dòng được `INSERT` vào bảng Đăng ký, Trigger `trg_SauKhiDangKy` sẽ kích hoạt tự động cộng 1 vào cột `SiSoHienTai` của bảng Học phần. Đồng thời em có Trigger ghi `LogHoatDong` giống như tính năng History, ai đổi mật khẩu hay sửa điểm đều bị lưu log lại."

6. **File `06_Views.sql`:**
   "Cuối cùng là View để phục vụ làm Báo cáo nhanh. Thay vì mỗi lần muốn xem TKB phải join 5-6 bảng rất nặng, em tạo sẵn View `v_ThoiKhoaBieu_SinhVien`. Chỉ cần `SELECT * FROM View` là ra luôn lịch học rõ ràng."

---

## PHẦN 2: CHẠY LỆNH DEMO THỰC TẾ
*(Sau khi giải thích xong, thầy sẽ bảo: "Được rồi, chạy thử tui xem")*

Bạn mở 1 tab mới ở MySQL (File -> New Query Tab) và copy paste từng dòng này vào chạy:

**1. Demo View & Hàm tính toán:**
**💻 Chạy lệnh:**
```sql
SELECT f_TinhGPA('SV001') AS GPA, f_XepLoaiHocLuc(f_TinhGPA('SV001')) AS XepLoai;
```
**🗣️ Bạn nói:** "Dạ em gọi hàm tính điểm GPA cho SV001, nó tự quét bảng điểm và tính ra con số, kèm luôn chữ Xếp loại Giỏi."

**2. Demo Trigger tự động:**
**💻 Chạy lệnh:**
```sql
-- Xem sĩ số trước
SELECT SiSoHienTai FROM HocPhan WHERE MaHP = 'HP002';

-- Đăng ký mới
INSERT INTO DangKyHocPhan(MaSV, MaHP) VALUES ('SV014', 'HP002');

-- Xem lại sĩ số
SELECT SiSoHienTai FROM HocPhan WHERE MaHP = 'HP002';
```
**🗣️ Bạn nói:** "Dạ thầy xem, sĩ số ban đầu của lớp HP002 là 4. Sau khi SV014 đăng ký thêm môn này, hệ thống tự động nhảy sĩ số lên 5 nhờ vào Trigger chạy ngầm ạ."

---

## PHẦN 3: KỊCH BẢN DEMO & BÁO CÁO 5 LỖI TRANSACTION (BƯỚC ĂN ĐIỂM 10)

*(Đây là phần để bạn đưa vào BÁO CÁO GIỮA KỲ/CUỐI KỲ và đọc lúc thuyết trình tùy theo yêu cầu của Giảng viên)*

### 🚀 3.1. LỖI 1: LOST UPDATE (MẤT DỮ LIỆU CẬP NHẬT)
**💻 Cách Demo:** Mở file `sql/demo/Loi1_LostUpdate.sql` và nhấn nút Tia Sét (Execute All). Nó hiện ra 4 tab.
*   **(Click Tab 1):** "Dạ thưa thầy, xét tình huống khóa học ban đầu có 30 lượt đăng ký."
*   **(Click Tab 2):** "Giả sử Sinh viên A và Sinh viên B cùng lúc bấm đăng ký. Cả 2 giao dịch đều đọc giá trị là 30 và tự tính lên 31 trên máy cá nhân."
*   **(Click Tab 3):** "Nhưng do hệ thống không có cơ chế khóa, Transaction B chạy sau đã lưu đè kết quả lên Transaction A. Kết quả cuối cùng DB chỉ ghi nhận sĩ số là 31 (Mất đi 1 lượt đăng ký của A). Đây gọi là lỗi Lost Update."
*   **(Click Tab 4):** "Cách khắc phục của nhóm em là khóa dòng dữ liệu lại bằng `FOR UPDATE` (Pessimistic Locking) và yêu cầu Database dùng phép toán cập nhật trực tiếp `UPDATE SiSo = SiSo + 1`. Kết quả giờ đã lên đúng 32 ạ."

### 🚀 3.2. LỖI 2: DIRTY READ (ĐỌC DỮ LIỆU BẨN)
**💻 Cách Demo:** Mở file `sql/demo/Loi2_DirtyRead.sql` và nhấn nút Tia Sét (Execute All).
*   **(Click Tab 1):** "Dạ thưa thầy, xét điểm thi ban đầu của SV001 là 7.50."
*   **(Click Tab 2):** "Giáo viên A vào sửa điểm thành 9.0 nhưng **chưa bấm Lưu (Chưa COMMIT)**."
*   **(Click Tab 3):** "Lúc này, nếu sinh viên B truy cập với mức cô lập `READ UNCOMMITTED`, hệ thống sẽ cho sinh viên B thấy điểm 9.0 (Đây là dữ liệu rác, chưa được xác nhận)."
*   **(Click Tab 4):** "Giáo viên A thấy sửa nhầm nên bấm Hủy (ROLLBACK), điểm quay về 7.50. Tức là sinh viên B vừa đọc một dữ liệu không hề tồn tại. Đây là lỗi Dirty Read."
*   **(Click Tab 5):** "Cách Fix: Nhóm em nâng mức cô lập lên `READ COMMITTED`. Khi đó, mọi giao dịch chỉ được phép đọc dữ liệu đã được COMMIT. Giao dịch rác sẽ bị ẩn đi hoàn toàn."

### 🚀 3.3. LỖI 3: NON-REPEATABLE READ (ĐỌC KHÔNG LẶP LẠI ĐƯỢC)
**💻 Cách Demo:** Mở file `sql/demo/Loi3_NonRepeatableRead.sql` và nhấn nút Tia Sét (Execute All).
*   **(Click Tab 1):** "Lỗi này xảy ra khi ở mức cô lập `READ COMMITTED`."
*   **(Click Tab 2):** "Trong cùng 1 thao tác thống kê (Transaction A), lần đọc thứ 1 điểm của sinh viên là 7.50."
*   **(Click Tab 3):** "Trong lúc hệ thống A đang chạy chưa xong, Giáo viên B vào cập nhật điểm thành 9.0 và COMMIT thành công."
*   **(Click Tab 4):** "Khi Transaction A đọc lại lần thứ 2, điểm đột nhiên biến thành 9.0. Nghĩa là trong cùng 1 báo cáo, cùng 1 người mà điểm lúc đầu 7.5, lúc sau 9.0 gây sai lệch số liệu. Đây gọi là Non-repeatable Read."
*   **(Click Tab 5):** "Cách Fix: Nhóm em dùng chuẩn mặc định của InnoDB là `REPEATABLE READ`. Hệ thống sẽ chụp một bức ảnh (Snapshot) tại thời điểm bắt đầu. Dù ai có sửa đổi, thì trong suốt quá trình báo cáo, hệ thống A vẫn thấy giá trị 7.50 nguyên vẹn."

### 🚀 3.4. LỖI 4: PHANTOM READ (ĐỌC THẤY "BÓNG MA")
**💻 Cách Demo:** Mở file `sql/demo/Loi4_PhantomRead.sql` và nhấn nút Tia Sét (Execute All).
*   **(Click Tab 1):** "Dạ thưa thầy, giả sử em đang chạy lệnh đếm số lượng sinh viên đăng ký lớp HP001. Lần 1 em đếm được 30 người."
*   **(Click Tab 2):** "Lúc này một sinh viên mới bấm nút đăng ký thành công (INSERT dữ liệu mới)."
*   **(Click Tab 3):** "Đến cuối báo cáo, em đếm lại lần nữa thì đột nhiên lòi ra 31 người. Có một dòng dữ liệu 'bóng ma' xuất hiện từ hư không làm sai lệch thuật toán. Đây là Phantom Read (Khác với lỗi 3 là UPDATE, lỗi 4 này là do INSERT)."
*   **(Click Tab 4):** "Cách Fix: Nhóm dùng cấp độ cao nhất là `SERIALIZABLE`. Nó sẽ tạo ra cơ chế khóa phạm vi (Range Lock). Nghĩa là khi quản trị viên đang đếm, mọi hành vi INSERT vào lớp HP001 sẽ bị treo lại chờ đếm xong mới được chạy."

### 🚀 3.5. LỖI 5: DEADLOCK (BẾ TẮC KHÓA)
**💻 Cách Demo:** (PHẢI MỞ 2 TAB QUERY SONG SONG) - Hướng dẫn chi tiết đã có trong file `sql/demo/Loi5_Deadlock.sql`.
*   **(Giải thích cho báo cáo):** "Deadlock là tình huống 2 người dùng khóa chéo tài nguyên của nhau. Ví dụ: Sinh viên A khóa môn Toán chờ đăng ký môn Lý. Sinh viên B khóa môn Lý chờ đăng ký môn Toán."
*   **(Kịch bản demo):** 
    *   Thực hiện chạy Bước 1 bên Tab A (Khóa HP001).
    *   Thực hiện chạy Bước 2 bên Tab B (Khóa HP002).
    *   Quay lại Tab A đòi khóa HP002 (Bị đứng vì B đang giữ).
    *   Quay lại Tab B đòi khóa HP001.
*   **(Kết quả):** "Dạ thầy xem, khi cả 2 bên bế tắc, cơ chế phát hiện Deadlock của MySQL sẽ nhảy vào, 'giết' (Rollback) một trong hai giao dịch và trả về lỗi `Error 1213: Deadlock found`. Transaction còn lại sẽ được đi tiếp."
*   **(Cách Fix chốt hạ):** "Để chống Deadlock, khi lập trình mã nguồn Backend, nhóm em quy định toàn bộ truy vấn phải luôn khóa bảng theo một thứ tự cố định (Ví dụ luôn khóa HP001 trước HP002). Hoặc lập trình thêm hàm `try-catch` để retry lại transaction khi bị hệ thống văng lỗi 1213 ạ."

---
🎉 **HOÀN THÀNH KỊCH BẢN**
*Bạn chỉ cần chép toàn bộ phần từ 3.1 đến 3.5 này vào file Word làm báo cáo nộp cho Giảng viên là đảm bảo nội dung cực kỳ khoa học và chuẩn điểm A+.*
