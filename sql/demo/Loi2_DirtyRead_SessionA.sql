-- ============================================================
-- DEMO LOI 2: DIRTY READ - SESSION A
-- Mo file nay trong connection/cua so thu nhat.
-- Chay tung khoi theo thu tu: A0 -> A1 -> B1 -> A2 -> A3 -> B2 -> A4.
-- ============================================================

USE QuanLyDKHP;

-- A0. Chuan bi du lieu. Chay khoi nay truoc.
DROP TABLE IF EXISTS Demo_Diem;
CREATE TABLE Demo_Diem (
    MaDK INT PRIMARY KEY,
    MaSV VARCHAR(10),
    DiemTB DECIMAL(4,2)
) ENGINE=InnoDB;
INSERT INTO Demo_Diem VALUES (1, 'SV001', 7.50);
SELECT '0. DIEM BAN DAU' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;

-- A1. Tao du lieu chua commit. Sau khoi nay qua Session B chay B1.
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;

-- A2. Rollback de chung minh 9.00 la du lieu rac.
-- Chay sau khi Session B da chay B1.
ROLLBACK;
SELECT '2. SAU ROLLBACK - diem that ve 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;

-- A3. Tao lai thay doi chua commit de test cach fix.
-- Sau khoi nay qua Session B chay B2.
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;

-- A4. Don dep sau khi Session B da chay B2.
ROLLBACK;
