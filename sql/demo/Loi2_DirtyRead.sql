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

SELECT '== ĐIỂM BAN ĐẦU CỦA SV001 ==' AS Buoc;
SELECT MaSV, DiemTB AS Diem_Ban_Dau FROM Demo_Diem WHERE MaDK = 1;

-- ============================================================
SELECT '== SESSION A: Giáo viên đang sửa điểm lên 9.0 (CHƯA COMMIT) ==' AS Buoc;
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
-- ⚠️ Chưa COMMIT! Đây là điểm "bẩn"

-- ============================================================
SELECT '== SESSION B: Sinh viên đọc với READ UNCOMMITTED → Thấy điểm BẨN 9.0 ==' AS Buoc;
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT MaSV, DiemTB AS 'Du_Lieu_Ban_Doc_Duoc' FROM Demo_Diem WHERE MaDK = 1;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ============================================================
SELECT '== SESSION A: Phát hiện sai → ROLLBACK, điểm về 7.5 ==' AS Buoc;
ROLLBACK;
SELECT MaSV, DiemTB AS 'Diem_Thuc_Te_Sau_Rollback' FROM Demo_Diem WHERE MaDK = 1;

SELECT '== KẾT LUẬN: Session B đọc được 9.0 nhưng thực tế là 7.5 → DỮ LIỆU BẨN! ==' AS KetLuan;

-- ============================================================
SELECT '== ✅ FIX: Dùng READ COMMITTED - Session B KHÔNG thấy dữ liệu chưa commit ==' AS Fix;
UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1;

START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
-- Chưa commit

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- Mức an toàn hơn
SELECT MaSV, DiemTB AS 'Voi_READ_COMMITTED_SB_Van_Thay' FROM Demo_Diem WHERE MaDK = 1;
-- Sẽ thấy 7.50, không thấy 9.00 chưa commit
ROLLBACK;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT '== KẾT LUẬN: READ COMMITTED ngăn Dirty Read thành công! ==' AS KetLuan_Fix;
