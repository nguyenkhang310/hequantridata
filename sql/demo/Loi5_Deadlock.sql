-- ============================================================
-- DEMO LỖI 5: DEADLOCK (Bế tắc khóa)
-- Lỗi này CHỈ demo được khi bạn MỞ 2 TAB QUERY SONG SONG!
-- ============================================================
USE QuanLyDKHP;

DROP TABLE IF EXISTS Demo_SiSo;
CREATE TABLE Demo_SiSo (
    MaHP VARCHAR(10) PRIMARY KEY,
    SiSo INT DEFAULT 0
) ENGINE=InnoDB;
INSERT INTO Demo_SiSo VALUES ('HP001', 30), ('HP002', 45);

SELECT '
=====================================================
HƯỚNG DẪN DEMO DEADLOCK CHO GIẢNG VIÊN (MỞ 2 TAB)
=====================================================
Để có được lỗi Deadlock thật sự, bạn hãy làm đúng theo các bước này:

1. Copy BƯỚC 1 bên dưới và dán vào Tab hiện tại (Tab 1 - Đại diện Session A)
2. Mở một Tab SQL mới (File -> New Query Tab), Copy BƯỚC 2 dán vào (Tab 2 - Đại diện Session B)
3. Chạy từng dòng một theo hướng dẫn ghi chú bên dưới!
' AS HuongDan;

/*
================== BƯỚC 1 (DÁN VÀO TAB 1) ==================
USE QuanLyDKHP;
START TRANSACTION;
-- 1. Chạy dòng này trước (A khóa HP001)
SELECT * FROM Demo_SiSo WHERE MaHP = 'HP001' FOR UPDATE;

-- (Bây giờ qua Tab 2 chạy phần của B)

-- 3. Chạy dòng này sau cùng (A cần HP002 nhưng B đang giữ -> BẾ TẮC!)
SELECT * FROM Demo_SiSo WHERE MaHP = 'HP002' FOR UPDATE;
===========================================================
*/

/*
================== BƯỚC 2 (DÁN VÀO TAB 2 MỚI) ==================
USE QuanLyDKHP;
START TRANSACTION;
-- 2. Chạy dòng này thứ hai (B khóa HP002)
SELECT * FROM Demo_SiSo WHERE MaHP = 'HP002' FOR UPDATE;

-- 4. Chạy dòng này thứ tư (B cần HP001 nhưng A đang giữ)
-- -> MYSQL SẼ PHÁT HIỆN DEADLOCK VÀ BÁO LỖI NGAY TẠI ĐÂY!
SELECT * FROM Demo_SiSo WHERE MaHP = 'HP001' FOR UPDATE;
===========================================================
*/

SELECT '
✅ CÁCH FIX BÁO CÁO THẦY:
1. Luôn truy cập dữ liệu theo đúng 1 thứ tự cố định (Ví dụ: Luôn khóa HP có mã nhỏ trước).
2. Khi code app, luôn có hàm try-catch để chạy lại (retry) transaction nếu văng lỗi Deadlock.
' AS GiaiThichFix;
