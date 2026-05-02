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
SELECT '== TRƯỚC KHI DEMO: Sĩ số HP001 ==' AS Buoc;
SELECT MaHP, TenHP, SiSo AS 'Si_So_Hien_Tai' FROM Demo_SiSo;

-- ============================================================
SELECT '== GIẢ LẬP: Session A và B đều đọc SiSo = 30 cùng lúc ==' AS Buoc;

-- Session A đọc, tính 30+1=31, ghi
START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001'; -- A ghi 31
COMMIT;

-- Session B cũng tính 30+1=31, ghi ĐÈ lên A!
START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001'; -- B ghi đè 31!
COMMIT;

SELECT '== KẾT QUẢ SAI: Có 2 SV đăng ký nhưng SiSo chỉ tăng 1 ==' AS Buoc;
SELECT MaHP, SiSo AS 'Mong_Duoc_32_Nhung_Chi_Co' FROM Demo_SiSo;

-- ============================================================
SELECT '== ✅ FIX: Dùng UPDATE nguyên tử (SET SiSo = SiSo + 1) ==' AS Buoc;
UPDATE Demo_SiSo SET SiSo = 30 WHERE MaHP = 'HP001'; -- Reset

START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = SiSo + 1 WHERE MaHP = 'HP001';
COMMIT;

START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = SiSo + 1 WHERE MaHP = 'HP001';
COMMIT;

SELECT '== KẾT QUẢ ĐÚNG: SiSo = 32 (tăng đúng 2 lần) ==' AS Buoc;
SELECT MaHP, SiSo AS 'Ket_Qua_Dung_La_32' FROM Demo_SiSo;

SET SQL_SAFE_UPDATES = 1;
