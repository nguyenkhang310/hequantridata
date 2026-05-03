-- ============================================================
-- DEMO LOI 5: DEADLOCK - SESSION A
-- Cach chay dung: can 2 cua so ket noi MySQL rieng biet.
-- Khong dung 2 tab chung mot connection trong MySQL Workbench.
-- ============================================================

USE QuanLyDKHP;

-- BUOC 0 - SESSION A: chuan bi bang demo
DROP TABLE IF EXISTS Demo_Deadlock;
CREATE TABLE Demo_Deadlock (
    MaHP VARCHAR(10) PRIMARY KEY,
    SiSo INT
) ENGINE=InnoDB;
INSERT INTO Demo_Deadlock VALUES ('HP001', 30), ('HP002', 45);

-- BUOC 1 - SESSION A: khoa HP001
START TRANSACTION;
UPDATE Demo_Deadlock SET SiSo = 31 WHERE MaHP = 'HP001';

-- BUOC 3 - SESSION A: chay sau khi Session B da khoa HP002.
-- Lenh nay se doi khoa HP002.
UPDATE Demo_Deadlock SET SiSo = 46 WHERE MaHP = 'HP002';

-- Neu Session B bi deadlock va rollback, Session A co the COMMIT.
COMMIT;
