-- ============================================================
-- DEMO LỖI 5: DEADLOCK (Bế tắc khóa) - SESSION A
-- ============================================================
-- ⚠️ CẢNH BÁO CỰC KỲ QUAN TRỌNG VỀ MYSQL WORKBENCH:
-- Đừng dùng tính năng "New Query Tab" (Mở tab mới trong cùng cửa sổ).
-- Vì các Tab trong cùng 1 cửa sổ SẼ DÙNG CHUNG 1 KẾT NỐI (Cùng Connection_ID).
-- Khi đó lệnh START TRANSACTION ở Tab 2 sẽ tự động COMMIT Tab 1 -> MẤT DEADLOCK!
--
-- CÁCH LÀM ĐÚNG:
-- 1. Trở về màn hình Home của Workbench (Hình ngôi nhà góc trên trái).
-- 2. Click đúp vào tên kết nối (VD: Local instance) để mở ra 1 CỬA SỔ MỚI HOÀN TOÀN.
-- 3. Đảm bảo bạn có 2 Tab Kết nối Lớn (Session riêng biệt).
-- 4. Chạy file SessionA ở cửa sổ 1, file SessionB ở cửa sổ 2.
-- ============================================================
USE QuanLyDKHP;

-- 1. TẠO BẢNG TẠM THỜI (Bôi đen và chạy 4 dòng này trước tiên)
DROP TABLE IF EXISTS Demo_Deadlock;
CREATE TABLE Demo_Deadlock (MaHP VARCHAR(10) PRIMARY KEY, SiSo INT) ENGINE=InnoDB;
INSERT INTO Demo_Deadlock VALUES ('HP001', 30), ('HP002', 45);


-- BƯỚC 1: Bôi đen và chạy 2 dòng dưới đây (Tab A khóa HP001)
START TRANSACTION;
UPDATE Demo_Deadlock SET SiSo = 31 WHERE MaHP = 'HP001';


-- BƯỚC 3: Quay lại Tab này, bôi đen và chạy dòng này 
-- (Nó sẽ quay mòng mòng vì chờ Tab B)
UPDATE Demo_Deadlock SET SiSo = 46 WHERE MaHP = 'HP002';
