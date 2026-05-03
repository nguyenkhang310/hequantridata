-- ============================================================
-- DEMO LOI 4: PHANTOM READ
-- Doc COUNT(*) 2 lan trong 1 transaction nhung lan 2 xuat hien them dong moi.
-- Cach chay dung: can 2 cua so ket noi MySQL rieng biet.
-- Khong bam Execute All trong mot tab.
-- ============================================================

USE QuanLyDKHP;

-- ============================================================
-- BUOC 0 - SESSION A: chuan bi du lieu
-- ============================================================
DROP TABLE IF EXISTS Demo_DangKy;
CREATE TABLE Demo_DangKy (
    MaDK INT AUTO_INCREMENT PRIMARY KEY,
    MaSV VARCHAR(10),
    MaHP VARCHAR(10),
    INDEX IDX_Demo_DangKy_MaHP (MaHP)
) ENGINE=InnoDB;

INSERT INTO Demo_DangKy (MaSV, MaHP)
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 30
)
SELECT CONCAT('SV', LPAD(n, 3, '0')), 'HP001'
FROM nums;

-- ============================================================
-- PHAN A - TAO LOI VOI READ COMMITTED
-- ============================================================

-- BUOC 1 - SESSION A:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT '1. LOI - LAN DEM 1, dang la 30 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';

-- BUOC 2 - SESSION B:
INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001');
COMMIT;

-- BUOC 3 - SESSION A:
SELECT '2. LOI - LAN DEM 2, bi thanh 31 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';
COMMIT;

-- ============================================================
-- PHAN B - CACH KHAC PHUC: REPEATABLE READ
-- ============================================================

-- BUOC 4 - SESSION A:
DELETE FROM Demo_DangKy WHERE MaSV = 'SV999';
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT '3. DA FIX - LAN DEM 1, dang la 30 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';

-- BUOC 5 - SESSION B:
INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001');
COMMIT;

-- BUOC 6 - SESSION A:
SELECT '4. DA FIX - LAN DEM 2 van giu 30 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
