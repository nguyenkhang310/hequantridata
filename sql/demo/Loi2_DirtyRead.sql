-- ============================================================
-- DEMO LỖI 2: DIRTY READ (Đọc dữ liệu rác)
-- ============================================================
-- CHUẨN BỊ
USE QuanLyDKHP;
DROP TABLE IF EXISTS Demo_Diem;
CREATE TABLE Demo_Diem (MaDK INT PRIMARY KEY, MaSV VARCHAR(10), DiemTB DECIMAL(4,2));
INSERT INTO Demo_Diem VALUES (1, 'SV001', 7.50);
-- ============================================================

-- ------------------------------------------------------------
-- MỞ TAB 1 (SESSION A - Giáo viên) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

-- Bước 1: Giáo viên sửa điểm nhưng CHƯA COMMIT
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;

-- Bước 3: Giảng viên phát hiện nhập sai, HỦY thao tác (ROLLBACK)
ROLLBACK;

-- Bước 4: Kiểm tra lại điểm thực tế
SELECT DiemTB AS Diem_Thuc_Te FROM Demo_Diem WHERE MaDK = 1;


-- ------------------------------------------------------------
-- MỞ TAB 2 (SESSION B - Sinh viên) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

-- Bước 2: Sinh viên dùng READ UNCOMMITTED và đọc trúng dữ liệu RÁC
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT DiemTB AS Du_Lieu_Rac_Doc_Duoc FROM Demo_Diem WHERE MaDK = 1;
COMMIT;
-- Sinh viên tưởng mình được 9.0 nhưng thực ra là dữ liệu ảo!

-- Khôi phục mức cách ly mặc định
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ============================================================
-- CÁCH FIX LỖI
-- Ở Bước 2, để Session B ở mức cách ly READ COMMITTED.
-- Khi đó Session B sẽ bị "treo" chờ hoặc chỉ đọc được 7.50 chứ không đọc được 9.00.
