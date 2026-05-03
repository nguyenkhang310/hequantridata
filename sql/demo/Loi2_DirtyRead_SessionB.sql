-- ============================================================
-- DEMO LOI 2: DIRTY READ - SESSION B
-- Mo file nay trong connection/cua so thu hai.
-- Chay tung khoi theo thu tu: A0 -> A1 -> B1 -> A2 -> A3 -> B2 -> A4.
-- ============================================================

USE QuanLyDKHP;

-- B1. Tao loi: READ UNCOMMITTED doc thay DiemTB = 9.00 chua commit.
-- Chi chay sau khi Session A da chay A1 va dang giu transaction.
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT '1. LOI DIRTY READ - doc thay 9.00 chua commit' AS Giai_Doan,
       MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- B2. Cach fix: READ COMMITTED khong doc du lieu chua commit, nen thay 7.50.
-- Chi chay sau khi Session A da chay A3 va dang giu transaction.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT '3. DA FIX - READ COMMITTED chi thay 7.50' AS Giai_Doan,
       MaSV, DiemTB
FROM Demo_Diem
WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
