-- ============================================================
-- DEMO LỖI 1: LOST UPDATE (Mất dữ liệu cập nhật)
-- ============================================================
-- CHUẨN BỊ (Chạy ở bất kỳ đâu trước khi bắt đầu)
USE QuanLyDKHP;
DROP TABLE IF EXISTS Demo_SiSo;
CREATE TABLE Demo_SiSo (MaHP VARCHAR(10) PRIMARY KEY, SiSo INT DEFAULT 0);
INSERT INTO Demo_SiSo VALUES ('HP001', 30);
-- ============================================================

-- ------------------------------------------------------------
-- MỞ TAB 1 (SESSION A) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

-- Bước 1: Session A bắt đầu giao dịch và đọc sĩ số
START TRANSACTION;
SELECT SiSo FROM Demo_SiSo WHERE MaHP = 'HP001'; 
-- Kết quả: Thấy SiSo = 30

-- Bước 3: Session A tính 30+1=31 và cập nhật
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001';
COMMIT;

-- Bước 5 (Kiểm tra lỗi): Xem sĩ số cuối cùng (Đúng ra 2 người thêm thì phải lên 32)
SELECT SiSo AS KET_QUA_SAI_LOST_UPDATE FROM Demo_SiSo WHERE MaHP = 'HP001';


-- ------------------------------------------------------------
-- MỞ TAB 2 (SESSION B) - Dán đoạn code này vào:
-- ------------------------------------------------------------
USE QuanLyDKHP;

-- Bước 2: Cùng lúc đó, Session B cũng đọc sĩ số
START TRANSACTION;
SELECT SiSo FROM Demo_SiSo WHERE MaHP = 'HP001';
-- Kết quả: Vẫn thấy SiSo = 30 (chưa biết A đang làm)

-- Bước 4: Session B cũng tính 30+1=31 và cập nhật đè lên!
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001';
COMMIT;


-- ============================================================
-- CÁCH FIX LỖI (Dùng cho cả 2 Session)
-- Sửa câu UPDATE thành: UPDATE Demo_SiSo SET SiSo = SiSo + 1 WHERE MaHP = 'HP001';
-- Thay vì lấy giá trị cũ cộng lên ở Application layer.
