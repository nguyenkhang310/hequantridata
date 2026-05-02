-- ============================================================
-- DEMO LỖI 5: DEADLOCK (Bế tắc khóa)
-- Lỗi này CHỈ demo được khi bạn MỞ 2 TAB QUERY SONG SONG!
-- ============================================================

SELECT '
=====================================================
HƯỚNG DẪN DEMO DEADLOCK (CẦN LÀM CHUẨN TỪNG BƯỚC)
=====================================================
Lý do bạn chạy báo xanh là do bạn QUÊN bôi đen chữ START TRANSACTION!
HOẶC do bạn quên tạo bảng dữ liệu!

Hãy mở 2 Tab SQL và làm ĐÚNG thứ tự bôi đen sau:
' AS HuongDan;

/*
================== PHẦN DÀNH CHO TAB 1 ==================

-- BƯỚC 1: Bôi đen và chạy CÙNG LÚC 8 dòng dưới đây ở Tab 1
USE QuanLyDKHP;
DROP TABLE IF EXISTS Demo_Deadlock;
CREATE TABLE Demo_Deadlock (MaHP VARCHAR(10) PRIMARY KEY, SiSo INT);
INSERT INTO Demo_Deadlock VALUES ('HP001', 30), ('HP002', 45);

START TRANSACTION;
UPDATE Demo_Deadlock SET SiSo = 31 WHERE MaHP = 'HP001';

-- BƯỚC 3: Quay lại Tab 1, bôi đen và chạy 1 dòng này (Nó sẽ bị treo quay vòng vòng)
UPDATE Demo_Deadlock SET SiSo = 46 WHERE MaHP = 'HP002';

===========================================================
*/

/*
================== PHẦN DÀNH CHO TAB 2 ==================

-- BƯỚC 2: Bôi đen và chạy CÙNG LÚC 3 dòng dưới đây ở Tab 2
USE QuanLyDKHP;
START TRANSACTION;
UPDATE Demo_Deadlock SET SiSo = 46 WHERE MaHP = 'HP002';

-- BƯỚC 4: Bôi đen và chạy 1 dòng này ở Tab 2
-- NGAY LẬP TỨC TAB 2 SẼ VĂNG LỖI 1213 DEADLOCK MÀU ĐỎ!
UPDATE Demo_Deadlock SET SiSo = 31 WHERE MaHP = 'HP001';

===========================================================
*/
