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
SELECT '== DEMO LỖI: Dùng READ COMMITTED (dễ tái hiện lỗi) ==' AS Buoc;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT MaSV, DiemTB AS 'Lan_Doc_1_Trong_Transaction' FROM Demo_Diem WHERE MaDK = 1;
-- → 7.50

    -- (Trong lúc này Session B sửa và commit)
    UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
    SELECT '(Session B đã sửa DiemTB = 9.00 và commit)' AS SessionB;

SELECT MaSV, DiemTB AS 'Lan_Doc_2_Trong_CUNG_Transaction' FROM Demo_Diem WHERE MaDK = 1;
-- → 9.00 (KHÁC! → NON-REPEATABLE READ)
COMMIT;

SELECT '== KẾT LUẬN: Cùng 1 transaction đọc 2 lần → 2 kết quả khác nhau! ==' AS KetLuan;

-- ============================================================
SELECT '== ✅ FIX: Dùng REPEATABLE READ (mặc định MySQL InnoDB) ==' AS Fix;
UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1; -- Reset

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT MaSV, DiemTB AS 'Lan_Doc_1_REPEATABLE_READ' FROM Demo_Diem WHERE MaDK = 1;
-- → 7.50

    UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
    SELECT '(Session B đã sửa DiemTB = 9.00 và commit)' AS SessionB;

SELECT MaSV, DiemTB AS 'Lan_Doc_2_Van_La' FROM Demo_Diem WHERE MaDK = 1;
-- → 7.50 (SNAPSHOT tại thời điểm bắt đầu transaction → đọc lại ổn định!)
COMMIT;
SELECT '== KẾT LUẬN: REPEATABLE READ đảm bảo đọc lại vẫn thấy cùng kết quả! ==' AS KetLuan_Fix;

SET SQL_SAFE_UPDATES = 1;
