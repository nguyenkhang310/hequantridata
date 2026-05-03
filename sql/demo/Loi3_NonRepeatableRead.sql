-- ============================================================
-- DEMO LOI 3: NON-REPEATABLE READ
-- Doc cung mot dong 2 lan trong 1 transaction nhung ra 2 gia tri khac nhau.
-- Cach chay dung: can 2 cua so ket noi MySQL rieng biet.
-- Khong bam Execute All trong mot tab.
-- ============================================================

USE QuanLyDKHP;

-- ============================================================
-- BUOC 0 - SESSION A: chuan bi du lieu
-- ============================================================
DROP TABLE IF EXISTS Demo_Diem;
CREATE TABLE Demo_Diem (
    MaDK INT PRIMARY KEY,
    MaSV VARCHAR(10),
    DiemTB DECIMAL(4,2)
) ENGINE=InnoDB;
INSERT INTO Demo_Diem VALUES (1, 'SV001', 7.50);

-- ============================================================
-- PHAN A - TAO LOI VOI READ COMMITTED
-- ============================================================

-- BUOC 1 - SESSION A:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT '1. LOI - LAN DOC 1, dang la 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;

-- BUOC 2 - SESSION B:
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
COMMIT;

-- BUOC 3 - SESSION A:
SELECT '2. LOI - LAN DOC 2, bi doi thanh 9.00' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;

-- ============================================================
-- PHAN B - CACH KHAC PHUC: REPEATABLE READ
-- ============================================================

-- BUOC 4 - SESSION A:
UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT '3. DA FIX - LAN DOC 1, dang la 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;

-- BUOC 5 - SESSION B:
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
COMMIT;

-- BUOC 6 - SESSION A:
SELECT '4. DA FIX - LAN DOC 2 van giu 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
