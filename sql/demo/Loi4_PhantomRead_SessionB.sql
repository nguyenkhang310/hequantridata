-- ============================================================
-- DEMO LOI 4: PHANTOM READ - SESSION B
-- Mo file nay trong connection/cua so thu hai.
-- Chay tung khoi theo thu tu: A0 -> A1 -> B1 -> A2 -> A3 -> B2 -> A4.
-- ============================================================

USE QuanLyDKHP;

-- B1. Chen them dong SV999 de tao phantom read.
-- Chi chay sau khi Session A da chay A1.
-- Dieu kien MaDK > 0 giup chay duoc khi MySQL Workbench bat Safe Updates.
DELETE FROM Demo_DangKy
WHERE MaSV = 'SV999'
  AND MaDK > 0;
INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001');
COMMIT;
SELECT 'B1 CHECK - da chen SV999, tong phai la 31' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';

-- B2. Chen them dong SV998 trong phan fix.
-- Chi chay sau khi Session A da chay A3.
DELETE FROM Demo_DangKy
WHERE MaSV = 'SV998'
  AND MaDK > 0;
INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV998', 'HP001');
COMMIT;
SELECT 'B2 CHECK - ben ngoai da chen SV998' AS Giai_Doan, COUNT(*) AS SoDong
FROM Demo_DangKy
WHERE MaHP = 'HP001';
