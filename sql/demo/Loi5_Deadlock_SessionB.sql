-- ============================================================
-- DEMO LOI 5: DEADLOCK - SESSION B
-- Cach chay dung: can 2 cua so ket noi MySQL rieng biet.
-- Khong dung 2 tab chung mot connection trong MySQL Workbench.
-- ============================================================

USE QuanLyDKHP;

-- BUOC 2 - SESSION B: chay sau BUOC 1 cua Session A, khoa HP002
START TRANSACTION;
UPDATE Demo_Deadlock SET SiSo = 46 WHERE MaHP = 'HP002';

-- BUOC 4 - SESSION B: chay sau khi BUOC 3 cua Session A dang doi.
-- MySQL se phat hien deadlock va mot trong hai session se nhan loi 1213.
UPDATE Demo_Deadlock SET SiSo = 31 WHERE MaHP = 'HP001';

-- Neu session nay khong bi MySQL rollback, co the COMMIT.
COMMIT;
