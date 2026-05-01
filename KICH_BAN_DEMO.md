# KỊCH BẢN THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN MÔN HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU

*Tài liệu này là "phao cứu sinh" cầm tay khi lên thuyết trình. Bạn có thể mở file này ở một bên màn hình, và MySQL Workbench ở một bên màn hình.*

---

## PHẦN 1: GIỚI THIỆU TỔNG QUAN VÀ GIẢI THÍCH 6 FILE SQL
*(Khi mới lên bảng, thầy sẽ bảo: "Rồi, nhóm làm cái gì, giới thiệu xem. Hệ thống có mấy bảng?")*

**🗣️ Bạn nói:**
"Dạ thưa thầy, đề tài của nhóm em là **Hệ thống Quản lý Đăng ký Học phần của Sinh viên**. Để dễ quản lý code và bàn giao, nhóm em đã tách rời Database thành **6 file script riêng biệt**, chạy lần lượt từ 01 đến 06."

**🗣️ Giải thích chi tiết 6 file (Bạn đọc trôi chảy phần này là thầy đánh giá rất cao):**

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
**🗣️ Bạn nói:** "Dạ thầy xem, sĩ số ban đầu là 45. Sau khi SV014 đăng ký thêm môn HP002, hệ thống tự động nhảy sĩ số lên 46 nhờ vào Trigger chạy ngầm ạ."

---

## PHẦN 3: DEMO TRANSACTION (BƯỚC ĂN ĐIỂM 10)
*(Thầy hỏi: "Thế phần quản lý giao dịch đồng thời (Concurrency) nhóm xử lý sao?")*

**🗣️ Bạn nói:** "Dạ, để demo tính huống nhiều người truy cập cùng lúc, em đã chuẩn bị sẵn các file script nhỏ. Em xin phép demo lỗi **Lost Update (Mất dữ liệu cập nhật)** khi 2 sinh viên tranh nhau một chỗ học cuối cùng."

**💻 Hành động:**
Bạn mở file `sql/demo/Loi1_LostUpdate.sql` và nhấn nút Tia Sét (Execute All). Nó hiện ra 4 tab.

**🗣️ Bạn đọc theo 4 tab hiện ra:**
1. **(Click Tab 1):** "Dạ sĩ số lớp ban đầu đang là 30."
2. **(Click Tab 2):** "Có 2 giao dịch của sinh viên A và B cùng đọc lên con số 30 và tự tính lên thành 31."
3. **(Click Tab 3):** "Nhưng vì không có cơ chế khóa (Lock), thằng B chạy sau đã lưu đè lên thằng A. Kết quả sĩ số chỉ là 31, bị mất đi 1 lượt đăng ký thực tế."
4. **(Click Tab 4):** "Để khắc phục, nhóm em đã khóa dòng dữ liệu lại, và yêu cầu Database dùng phép toán cập nhật trực tiếp. Thầy thấy kết quả hiện giờ đã lên chuẩn 32 rồi ạ."

---
*Lưu ý: Nếu thầy bắt demo các lỗi khác như Dirty Read hay Deadlock, bạn chỉ việc mở file Loi2, Loi3... tương ứng trong thư mục `sql/demo/` ra chạy và đọc y hệt những giải thích tiếng Việt mà hệ thống in ra trên màn hình.*

Chúc bạn lên bảng thật tự tin! Đọc trôi chảy kịch bản này là đảm bảo điểm A+!
