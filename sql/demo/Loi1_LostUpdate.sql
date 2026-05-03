-- ============================================================
-- DEMO LOI 1: LOST UPDATE (mat cap nhat)
-- File nay co the chay Execute All trong mot tab.
-- Muc tieu: minh hoa viec 2 thao tac dua tren cung gia tri cu lam mat 1 lan tang.
-- ============================================================

USE QuanLyDKHP;
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Demo_SiSo;
CREATE TABLE Demo_SiSo (
    MaHP VARCHAR(10) PRIMARY KEY,
    TenHP VARCHAR(50),
    SiSo INT DEFAULT 0
) ENGINE=InnoDB;
INSERT INTO Demo_SiSo VALUES ('HP001', 'Co So Du Lieu', 30);

SELECT '1. TRUOC KHI TEST' AS Giai_Doan, MaHP, TenHP, SiSo AS SiSoHienTai
FROM Demo_SiSo;

-- ============================================================
-- PHAN A - TAO LOI
-- Gia lap 2 session cung doc SiSo = 30, moi session deu tinh ket qua moi la 31.
-- Ket qua dung mong doi la 32, nhung do ghi theo gia tri stale nen chi con 31.
-- ============================================================
START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001';
COMMIT;

START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = 31 WHERE MaHP = 'HP001';
COMMIT;

SELECT '2. LOI LOST UPDATE - mong 32 nhung chi 31' AS Giai_Doan, MaHP, SiSo
FROM Demo_SiSo;

-- ============================================================
-- PHAN B - CACH KHAC PHUC
-- Dung update nguyen tu: SiSo = SiSo + 1.
-- ============================================================
UPDATE Demo_SiSo SET SiSo = 30 WHERE MaHP = 'HP001';

START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = SiSo + 1 WHERE MaHP = 'HP001';
COMMIT;

START TRANSACTION;
UPDATE Demo_SiSo SET SiSo = SiSo + 1 WHERE MaHP = 'HP001';
COMMIT;

SELECT '3. DA FIX - tang dung 2 lan thanh 32' AS Giai_Doan, MaHP, SiSo
FROM Demo_SiSo;

SET SQL_SAFE_UPDATES = 1;
