-- ============================================================
-- DEMO LỖI 4: PHANTOM READ (Đọc thấy "bóng ma")
-- Đọc 2 lần thấy số lượng dòng dữ liệu KHÁC NHAU do có INSERT mới
-- ============================================================
USE QuanLyDKHP;
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Demo_DangKy;
CREATE TABLE Demo_DangKy (
    MaDK INT AUTO_INCREMENT PRIMARY KEY,
    MaSV VARCHAR(10),
    MaHP VARCHAR(10)
) ENGINE=InnoDB;

-- Bỏ sẵn 30 dòng
INSERT INTO Demo_DangKy (MaSV, MaHP)
WITH RECURSIVE nums AS ( SELECT 1 AS n UNION ALL SELECT n + 1 FROM nums WHERE n < 30 )
SELECT CONCAT('SV', LPAD(n, 3, '0')), 'HP001' FROM nums;

-- ============================================================
-- DEMO LỖI: Dùng READ COMMITTED (Dễ xuất hiện Phantom)
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT '1. KET QUA LỖI (Lan 1)' AS Giai_Doan, COUNT(*) AS 'Dang_La_30_Dong' FROM Demo_DangKy WHERE MaHP = 'HP001';

    -- (Session B INSERT dòng mới và commit)
    INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001');

SELECT '2. KET QUA LỖI (Lan 2 - Phantom!)' AS Giai_Doan, COUNT(*) AS 'Tu_Nhien_Thanh_31_Dong' FROM Demo_DangKy WHERE MaHP = 'HP001';
COMMIT;

-- ============================================================
-- ✅ FIX: Dùng SERIALIZABLE (Mức cao nhất, chặn INSERT)
DELETE FROM Demo_DangKy WHERE MaSV = 'SV999'; -- Xóa data rác

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT '3. KET QUA DUNG (Lan 1)' AS Giai_Doan, COUNT(*) AS 'Dang_La_30_Dong' FROM Demo_DangKy WHERE MaHP = 'HP001';

    -- (Trong thực tế, câu lệnh INSERT dưới đây của Session B sẽ bị TREO/WAIT)
    -- INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001'); 

SELECT '4. KET QUA DUNG (Lan 2 - On dinh!)' AS Giai_Doan, COUNT(*) AS 'Van_Giu_Nguyen_30_Dong' FROM Demo_DangKy WHERE MaHP = 'HP001';
COMMIT;

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Đưa về mặc định
SET SQL_SAFE_UPDATES = 1;
