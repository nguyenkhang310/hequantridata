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
HƯỚNG DẪN DEMO DEADLOCK (CẦN LÀM CHUẨN TỪNG BƯỚC)
=====================================================
Lý do bạn chạy báo xanh là do bạn QUÊN bôi đen chữ START TRANSACTION!
Nếu không có START TRANSACTION, MySQL sẽ tự động Commit ngay lập tức -> Mất khóa!

Hãy mở 2 Tab SQL và làm ĐÚNG thứ tự bôi đen sau:
' AS HuongDan;

/*
================== PHẦN DÀNH CHO TAB 1 ==================

-- BƯỚC 1: Bôi đen và chạy CÙNG LÚC 3 dòng dưới đây ở Tab 1
USE QuanLyDKHP;
START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001';

-- BƯỚC 3: Quay lại Tab 1, bôi đen và chạy dòng này (Nó sẽ bị treo quay vòng vòng)
UPDATE Demo_SiSo SET SiSo = 46 WHERE MaHP = 'HP002';

===========================================================
*/

/*
================== PHẦN DÀNH CHO TAB 2 ==================

-- BƯỚC 2: Bôi đen và chạy CÙNG LÚC 3 dòng dưới đây ở Tab 2
USE QuanLyDKHP;
START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 46 WHERE MaHP = 'HP002';

-- BƯỚC 4: Bôi đen và chạy dòng này ở Tab 2
-- NGAY LẬP TỨC TAB 2 SẼ VĂNG LỖI 1213 DEADLOCK MÀU ĐỎ!
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001';

===========================================================
*/
