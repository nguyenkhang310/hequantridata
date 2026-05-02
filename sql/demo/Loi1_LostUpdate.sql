-- ============================================================
-- DEMO LỖI 1: LOST UPDATE (Mất dữ liệu cập nhật)
-- Chạy file này trước, xem kết quả từng bước
-- ============================================================
USE QuanLyDKHP;
SET SQL_SAFE_UPDATES = 0;

-- Chuẩn bị bảng test
DROP TABLE IF EXISTS Demo_SiSo;
CREATE TABLE Demo_SiSo (
    MaHP VARCHAR(10) PRIMARY KEY,
    TenHP VARCHAR(50),
    SiSo INT DEFAULT 0
) ENGINE=InnoDB;
INSERT INTO Demo_SiSo VALUES ('HP001', 'Co So Du Lieu', 30);

-- ============================================================
SELECT '1. TRUOC KHI TEST' AS Giai_Doan, MaHP, TenHP, SiSo AS 'Si_So_Hien_Tai' FROM Demo_SiSo;

-- ============================================================
-- GIẢ LẬP: Session A và B đều đọc SiSo = 30 cùng lúc

-- Session A đọc, tính 30+1=31, ghi
START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001'; -- A ghi 31
COMMIT;

-- Session B cũng tính 30+1=31, ghi ĐÈ lên A!
START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001'; -- B ghi đè 31!
COMMIT;

SELECT '2. KET QUA LỖI (Lost Update)' AS Giai_Doan, MaHP, SiSo AS 'Mong_32_Nhung_Chi_Tang_1' FROM Demo_SiSo;

-- ============================================================
-- ✅ FIX: Dùng UPDATE nguyên tử (SET SiSo = SiSo + 1)
UPDATE Demo_SiSo SET SiSo = 30 WHERE MaHP = 'HP001'; -- Reset

START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = SiSo + 1 WHERE MaHP = 'HP001';
COMMIT;

START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = SiSo + 1 WHERE MaHP = 'HP001';
COMMIT;

SELECT '3. KET QUA DUNG (Da Fix)' AS Giai_Doan, MaHP, SiSo AS 'Da_Tang_Dung_2_Lan' FROM Demo_SiSo;

SET SQL_SAFE_UPDATES = 1;
