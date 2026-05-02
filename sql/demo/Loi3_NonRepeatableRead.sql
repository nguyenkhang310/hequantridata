-- ============================================================
-- DEMO LỖI 3: NON-REPEATABLE READ (Đọc không thể lặp lại)
-- ============================================================
-- CHUẨN BỊ
USE QuanLyDKHP;
DROP TABLE IF EXISTS Demo_HocPhi;
CREATE TABLE Demo_HocPhi (MaSV VARCHAR(10) PRIMARY KEY, TienNo INT);
INSERT INTO Demo_HocPhi VALUES ('SV001', 1000000);
-- ============================================================

-- ------------------------------------------------------------
-- MỞ TAB 1 (SESSION A - Sinh viên) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;
-- Cố tình dùng mức cách ly thấp (READ COMMITTED) để thấy lỗi
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
-- Bước 1: Sinh viên xem nợ học phí lần 1
SELECT TienNo AS 'Lan 1' FROM Demo_HocPhi WHERE MaSV = 'SV001';
-- Thấy nợ 1.000.000, quyết định đi vay tiền để đóng

-- Bước 3: Vay được tiền, mở app lên xem lại nợ lần 2 (vẫn trong cùng 1 phiên)
SELECT TienNo AS 'Lan 2_Bong_Dung_Thay_Doi' FROM Demo_HocPhi WHERE MaSV = 'SV001';
COMMIT;

-- Khôi phục mặc định
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;


-- ------------------------------------------------------------
-- MỞ TAB 2 (SESSION B - Hệ thống) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

-- Bước 2: Hệ thống quét và tự động miễn giảm học phí cho SV001
START TRANSACTION;
UPDATE Demo_HocPhi SET TienNo = 500000 WHERE MaSV = 'SV001';
COMMIT;


-- ============================================================
-- CÁCH FIX LỖI
-- Để Session A ở mức mặc định của MySQL là REPEATABLE READ.
-- Lúc đó cả 2 lần SELECT trong Session A sẽ đảm bảo trả về cùng 1 kết quả là 1.000.000.
