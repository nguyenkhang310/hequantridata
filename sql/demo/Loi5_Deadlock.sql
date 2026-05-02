-- ============================================================
-- DEMO LỖI 5: DEADLOCK (Khóa cứng)
-- ============================================================
-- CHUẨN BỊ
USE QuanLyDKHP;
DROP TABLE IF EXISTS Demo_Deadlock;
CREATE TABLE Demo_Deadlock (MaMH VARCHAR(10) PRIMARY KEY, TinhTrang VARCHAR(50));
INSERT INTO Demo_Deadlock VALUES ('MH01', 'Dang Mo'), ('MH02', 'Dang Mo');
-- ============================================================

-- ------------------------------------------------------------
-- MỞ TAB 1 (SESSION A) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

START TRANSACTION;
-- Bước 1: A khóa MH01
UPDATE Demo_Deadlock SET TinhTrang = 'A dang khoa' WHERE MaMH = 'MH01';

-- Bước 3: A cố gắng khóa MH02 (Nhưng B đã khóa MH02 ở Bước 2)
-- A sẽ bị treo chờ B nhả MH02 ra...
-- NHƯNG B cũng đang chờ A nhả MH01 ra (ở Bước 4) -> DEADLOCK!
UPDATE Demo_Deadlock SET TinhTrang = 'A da khoa ca 2' WHERE MaMH = 'MH02';
COMMIT;


-- ------------------------------------------------------------
-- MỞ TAB 2 (SESSION B) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

START TRANSACTION;
-- Bước 2: B khóa MH02
UPDATE Demo_Deadlock SET TinhTrang = 'B dang khoa' WHERE MaMH = 'MH02';

-- Bước 4: B cố gắng khóa MH01 (Nhưng A đang giữ khóa ở Bước 1)
-- MySQL sẽ phát hiện vòng lặp vô tận (Deadlock) và lập tức HỦY (ROLLBACK) một trong 2!
UPDATE Demo_Deadlock SET TinhTrang = 'B da khoa ca 2' WHERE MaMH = 'MH01';
COMMIT;


-- ============================================================
-- CÁCH FIX LỖI
-- Để giải quyết Deadlock, bắt buộc ứng dụng phải quy định thứ tự khóa tài nguyên.
-- Ví dụ: Bắt buộc mọi giao dịch đều phải khóa theo thứ tự Alphabet (Luôn khóa MH01 trước rồi mới tới MH02).
