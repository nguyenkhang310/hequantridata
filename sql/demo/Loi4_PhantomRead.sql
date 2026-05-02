-- ============================================================
-- DEMO LỖI 4: PHANTOM READ (Đọc bóng ma)
-- ============================================================
-- CHUẨN BỊ
USE QuanLyDKHP;
DROP TABLE IF EXISTS Demo_Lop;
CREATE TABLE Demo_Lop (MaSV VARCHAR(10) PRIMARY KEY, Lop VARCHAR(20));
INSERT INTO Demo_Lop VALUES ('SV001', 'CNTT01'), ('SV002', 'CNTT01');
-- ============================================================

-- ------------------------------------------------------------
-- MỞ TAB 1 (SESSION A - Admin) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;
-- Ở MySQL mức REPEATABLE READ mặc định đã chống được Phantom Read đa số trường hợp.
-- Để demo lỗi này, ta tạm thời hạ mức cách ly xuống READ COMMITTED.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
-- Bước 1: Thống kê số sinh viên lớp CNTT01 (đang có 2)
SELECT COUNT(*) AS 'SoLuong_Lan1' FROM Demo_Lop WHERE Lop = 'CNTT01';

-- Bước 3: Thống kê lại lần 2
-- Đột nhiên ra 3 dòng! (Xuất hiện bóng ma do Session B vừa chèn vào)
SELECT COUNT(*) AS 'SoLuong_Lan2_Bong_Ma' FROM Demo_Lop WHERE Lop = 'CNTT01';
COMMIT;

-- Khôi phục mặc định
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;


-- ------------------------------------------------------------
-- MỞ TAB 2 (SESSION B - Hệ thống/Sinh viên) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

-- Bước 2: Sinh viên mới SV003 đăng ký vào lớp CNTT01
START TRANSACTION;
INSERT INTO Demo_Lop VALUES ('SV003', 'CNTT01');
COMMIT;


-- ============================================================
-- CÁCH FIX LỖI
-- Để Session A ở mức mặc định REPEATABLE READ hoặc SERIALIZABLE.
-- MySQL (InnoDB) sử dụng Next-Key Locks để khóa cả khoảng trống, ngăn chặn INSERT.
