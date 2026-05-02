-- ============================================================
-- DEMO LỖI 2: DIRTY READ (Đọc dữ liệu bẩn)
-- Chạy toàn bộ, xem kết quả bước cuối
-- ============================================================
USE QuanLyDKHP;

-- Chuẩn bị
DROP TABLE IF EXISTS Demo_Diem;
CREATE TABLE Demo_Diem (
    MaDK INT PRIMARY KEY,
    MaSV VARCHAR(10),
    DiemTB DECIMAL(4,2)
) ENGINE=InnoDB;
INSERT INTO Demo_Diem VALUES (1, 'SV001', 7.50);

SELECT '1. DIEM BAN DAU' AS Giai_Doan, MaSV, DiemTB AS Diem_Ban_Dau FROM Demo_Diem WHERE MaDK = 1;

-- ============================================================
-- SESSION A: Giáo viên đang sửa điểm lên 9.0 (CHƯA COMMIT)
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
-- ⚠️ Chưa COMMIT! Đây là điểm "bẩn"

-- ============================================================
-- SESSION B: Sinh viên đọc với READ UNCOMMITTED → Thấy điểm BẨN 9.0
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT '2. KET QUA LỖI (Dirty Read)' AS Giai_Doan, MaSV, DiemTB AS 'Doc_Thấy_9.0_Chua_Commit' FROM Demo_Diem WHERE MaDK = 1;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ============================================================
-- SESSION A: Phát hiện sai → ROLLBACK, điểm về 7.5
ROLLBACK;

-- ============================================================
-- ✅ FIX: Dùng READ COMMITTED - Session B KHÔNG thấy dữ liệu chưa commit
UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1;

START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
-- Chưa commit

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- Mức an toàn hơn
SELECT '3. KET QUA DUNG (Da Fix)' AS Giai_Doan, MaSV, DiemTB AS 'Chỉ_Thấy_7.5_An_Toan' FROM Demo_Diem WHERE MaDK = 1;
-- Sẽ thấy 7.50, không thấy 9.00 chưa commit
ROLLBACK;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
