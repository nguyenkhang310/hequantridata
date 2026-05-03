-- ============================================================
-- DEMO LOI 3: NON-REPEATABLE READ - SESSION B
-- Mo file nay trong connection/cua so thu hai.
-- Chay tung khoi theo thu tu: A0 -> A1 -> B1 -> A2 -> A3 -> B2 -> A4.
-- ============================================================

USE QuanLyDKHP;

-- B1. Xen vao sua diem thanh 9.00 de tao loi.
-- Chi chay sau khi Session A da chay A1.
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
COMMIT;

-- B2. Xen vao sua diem thanh 9.00 trong phan fix.
-- Chi chay sau khi Session A da chay A3.
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
COMMIT;
