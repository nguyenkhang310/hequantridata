-- ============================================================
-- DEMO LOI 3: NON-REPEATABLE READ - SESSION A
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

-- A1. Lan doc 1 trong READ COMMITTED. Sau khoi nay qua Session B chay B1.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT '1. LOI - LAN DOC 1, dang la 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;

-- A2. Lan doc 2 trong cung transaction, se thay 9.00.
-- Chay sau khi Session B da chay B1.
SELECT '2. LOI - LAN DOC 2, bi doi thanh 9.00' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;

-- A3. Bat dau phan fix bang REPEATABLE READ. Sau khoi nay qua Session B chay B2.
UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT '3. DA FIX - LAN DOC 1, dang la 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;

-- A4. Lan doc 2 van giu 7.50 du Session B da update.
-- Chay sau khi Session B da chay B2.
SELECT '4. DA FIX - LAN DOC 2 van giu 7.50' AS Giai_Doan, MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
