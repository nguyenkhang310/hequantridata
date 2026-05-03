-- ============================================================
-- DEMO LOI 2: DIRTY READ (doc du lieu chua commit)
-- Cach chay dung: can 2 cua so ket noi MySQL rieng biet.
-- Khong bam Execute All trong mot tab.
-- ============================================================

USE QuanLyDKHP;

-- ============================================================
-- BUOC 0 - SESSION A: chuan bi du lieu
-- Chay khoi nay truoc.
-- ============================================================
DROP TABLE IF EXISTS Demo_Diem;
CREATE TABLE Demo_Diem (
    MaDK INT PRIMARY KEY,
    MaSV VARCHAR(10),
    DiemTB DECIMAL(4,2)
) ENGINE=InnoDB;
INSERT INTO Demo_Diem VALUES (1, 'SV001', 7.50);
SELECT '0. DIEM BAN DAU' AS Giai_Doan, MaSV, DiemTB FROM Demo_Diem WHERE MaDK = 1;

-- ============================================================
-- PHAN A - TAO LOI DIRTY READ
-- ============================================================

-- BUOC 1 - SESSION A:
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
-- De nguyen transaction, chua COMMIT/ROLLBACK.

-- BUOC 2 - SESSION B:
-- Chay trong cua so ket noi thu hai.
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT '1. LOI DIRTY READ - doc thay 9.00 chua commit' AS Giai_Doan,
       MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- BUOC 3 - SESSION A:
ROLLBACK;
SELECT '2. SAU ROLLBACK - diem that ve 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;

-- ============================================================
-- PHAN B - CACH KHAC PHUC: READ COMMITTED
-- ============================================================

-- BUOC 4 - SESSION A:
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
-- Van chua commit.

-- BUOC 5 - SESSION B:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT '3. DA FIX - READ COMMITTED chi thay 7.50' AS Giai_Doan,
       MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- BUOC 6 - SESSION A:
ROLLBACK;
