-- ============================================================
-- DEMO LỖI 5: DEADLOCK (Bế tắc khóa) - SESSION B
-- ============================================================

USE QuanLyDKHP;

-- BƯỚC 2: Bôi đen và chạy 2 dòng dưới đây (Tab B khóa HP002)
START TRANSACTION;
UPDATE Demo_Deadlock SET SiSo = 46 WHERE MaHP = 'HP002';


-- BƯỚC 4: Bôi đen và chạy dòng này 
-- (NGAY LẬP TỨC SẼ VĂNG LỖI ĐỎ DEADLOCK 1213 Ở ĐÂY!)
UPDATE Demo_Deadlock SET SiSo = 31 WHERE MaHP = 'HP001';
