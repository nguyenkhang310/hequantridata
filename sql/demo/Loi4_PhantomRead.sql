-- ============================================================
-- DEMO LỖI 4: PHANTOM READ (Đọc thấy "bóng ma")
-- Đọc 2 lần thấy số lượng dòng dữ liệu KHÁC NHAU do có INSERT mới
-- ============================================================
USE QuanLyDKHP;
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Demo_DangKy;
CREATE TABLE Demo_DangKy (
    MaDK INT AUTO_INCREMENT PRIMARY KEY,
    MaSV VARCHAR(10),
    MaHP VARCHAR(10)
) ENGINE=InnoDB;

-- Bỏ sẵn 30 dòng
INSERT INTO Demo_DangKy (MaSV, MaHP)
WITH RECURSIVE nums AS ( SELECT 1 AS n UNION ALL SELECT n + 1 FROM nums WHERE n < 30 )
SELECT CONCAT('SV', LPAD(n, 3, '0')), 'HP001' FROM nums;

-- ============================================================
SELECT '== DEMO LỖI: Dùng READ COMMITTED (Dễ xuất hiện Phantom) ==' AS Buoc;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT COUNT(*) AS 'Lan_Doc_1_So_Luong' FROM Demo_DangKy WHERE MaHP = 'HP001';
-- -> 30

    -- (Session B INSERT dòng mới và commit)
    INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001');
    SELECT '(Session B đã INSERT SV999 và commit)' AS SessionB;

SELECT COUNT(*) AS 'Lan_Doc_2_So_Luong_Tang_Len' FROM Demo_DangKy WHERE MaHP = 'HP001';
-- -> 31 (Xuất hiện 1 dòng "Bóng ma"!)
COMMIT;

SELECT '== KẾT LUẬN: Đọc đếm số lượng 2 lần khác nhau -> PHANTOM READ! ==' AS KetLuan;

-- ============================================================
SELECT '== ✅ FIX: Dùng SERIALIZABLE (Mức cao nhất, chặn INSERT) ==' AS Fix;
DELETE FROM Demo_DangKy WHERE MaSV = 'SV999'; -- Xóa data rác

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT COUNT(*) AS 'Lan_Doc_1_SERIALIZABLE' FROM Demo_DangKy WHERE MaHP = 'HP001';
-- -> 30 (Và sẽ TẠO LOCK CHẶN RANGE NÀY)

    -- KHÔNG CHẠY LỆNH INSERT DƯỚI ĐÂY VÌ NÓ SẼ BỊ TREO (BLOCK)
    SELECT '(Session B cố INSERT SV999 nhưng sẽ bị TREO/WAIT)' AS SessionB;
    -- INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001'); 

SELECT COUNT(*) AS 'Lan_Doc_2_Van_La_30' FROM Demo_DangKy WHERE MaHP = 'HP001';
-- -> 30
COMMIT;

SELECT '== KẾT LUẬN: SERIALIZABLE khóa range, ngăn chặn hoàn toàn Phantom Read! ==' AS KetLuan_Fix;

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Đưa về mặc định
SET SQL_SAFE_UPDATES = 1;
