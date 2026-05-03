-- ============================================================
-- DEMO LOI 4: PHANTOM READ - SESSION A
-- Mo file nay trong connection/cua so thu nhat.
-- Chay tung khoi theo thu tu: A0 -> A1 -> B1 -> A2 -> A3 -> B2 -> A4.
-- ============================================================

USE QuanLyDKHP;

-- A0. Chuan bi du lieu 30 dong. Chay khoi nay truoc.
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
COMMIT;

SELECT '0. SAU A0 - bang demo co 30 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';

-- A1. Lan dem 1 trong READ COMMITTED. Sau khoi nay qua Session B chay B1.
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT 'A1 CHECK - isolation phai la READ-COMMITTED' AS Giai_Doan,
       @@transaction_isolation AS IsolationLevel;
START TRANSACTION;
SELECT '1. LOI - LAN DEM 1, dang la 30 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';

-- A2. Lan dem 2 se thay dong moi, thanh 31.
-- Chay sau khi Session B da chay B1.
SELECT '2. LOI - LAN DEM 2, bi thanh 31 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';
COMMIT;

-- A3. Bat dau phan fix bang REPEATABLE READ. Sau khoi nay qua Session B chay B2.
-- Xoa het dong demo cu neu truoc do bam chay B1/B2 nhieu lan.
-- Dieu kien MaDK > 0 giup chay duoc khi MySQL Workbench bat Safe Updates.
DELETE FROM Demo_DangKy
WHERE MaSV IN ('SV998', 'SV999')
  AND MaDK > 0;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT 'A3 CHECK - isolation phai la REPEATABLE-READ' AS Giai_Doan,
       @@transaction_isolation AS IsolationLevel;
START TRANSACTION;
SELECT '3. DA FIX - LAN DEM 1, dang la 30 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';

-- A4. Lan dem 2 van giu 30 dong du Session B da insert.
-- Chay sau khi Session B da chay B2.
SELECT '4. DA FIX - LAN DEM 2 van giu 30 dong' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
