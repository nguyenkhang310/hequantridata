-- ============================================================
-- DEMO LỖI 3: NON-REPEATABLE READ (Đọc không lặp lại được)
-- Trong 1 transaction đọc 2 lần → 2 kết quả khác nhau
-- ============================================================
USE QuanLyDKHP;
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Demo_Diem;
CREATE TABLE Demo_Diem (
    MaDK INT PRIMARY KEY,
    MaSV VARCHAR(10),
    DiemTB DECIMAL(4,2)
) ENGINE=InnoDB;
INSERT INTO Demo_Diem VALUES (1, 'SV001', 7.50);

-- ============================================================
-- DEMO LỖI: Dùng READ COMMITTED (dễ tái hiện lỗi)
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT '1. KET QUA LỖI (Lan 1)' AS Giai_Doan, MaSV, DiemTB AS 'Dang_La_7.5' FROM Demo_Diem WHERE MaDK = 1;

    -- (Trong lúc này Session B sửa và commit)
    UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;

SELECT '2. KET QUA LỖI (Lan 2 - Thay doi!)' AS Giai_Doan, MaSV, DiemTB AS 'Bi_Doi_Thanh_9.0' FROM Demo_Diem WHERE MaDK = 1;
COMMIT;

-- ============================================================
-- ✅ FIX: Dùng REPEATABLE READ (mặc định MySQL InnoDB)
UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1; -- Reset

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT '3. KET QUA DUNG (Lan 1)' AS Giai_Doan, MaSV, DiemTB AS 'Dang_La_7.5' FROM Demo_Diem WHERE MaDK = 1;

    -- Session B sửa DiemTB = 9.00 và commit
    UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;

SELECT '4. KET QUA DUNG (Lan 2 - On dinh!)' AS Giai_Doan, MaSV, DiemTB AS 'Van_Giu_Nguyen_7.5' FROM Demo_Diem WHERE MaDK = 1;
COMMIT;

SET SQL_SAFE_UPDATES = 1;
