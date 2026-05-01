-- ============================================================
-- FILE: 07_Transactions_Demo.sql
-- MỤC ĐÍCH: Demo 5 lỗi Transaction trong hệ thống ĐKHP
-- CÁCH DÙNG: Mở 2 tab Query trong MySQL Workbench
--            Chạy từng SESSION A / SESSION B theo thứ tự
-- ============================================================

USE QuanLyDKHP;

-- ============================================================
-- CHUẨN BỊ: Tạo bảng test riêng để demo an toàn
-- ============================================================
DROP TABLE IF EXISTS Demo_SiSo;
CREATE TABLE Demo_SiSo (
    MaHP        VARCHAR(10) PRIMARY KEY,
    TenHP       VARCHAR(50),
    SiSoHienTai INT DEFAULT 0,
    SiSoToiDa   INT DEFAULT 50
) ENGINE=InnoDB;

INSERT INTO Demo_SiSo VALUES
('HP001', 'Co so Du lieu',    30, 50),
('HP002', 'Lap trinh OOP',    45, 50),
('HP003', 'Mang May tinh',    10, 40);

SELECT '=== Dữ liệu ban đầu ===' AS Info;
SELECT * FROM Demo_SiSo;

-- ============================================================
-- ⚠️  LỖI 1: LOST UPDATE (Mất dữ liệu cập nhật)
-- ============================================================
-- MÔ TẢ: 2 SV cùng đăng ký HP001 cùng lúc.
--        Cả 2 đều đọc SiSo=30, tính 30+1=31, ghi 31.
--        Kết quả: SiSo=31 thay vì 32 → MẤT 1 lượt đăng ký!
--
-- CHẠY TỪNG BƯỚC THEO THỨ TỰ:
-- ============================================================

SELECT '=== LỖI 1: LOST UPDATE ===' AS TenLoi;

-- [Bước 1] SESSION A: Đọc sĩ số
START TRANSACTION;
SELECT SiSoHienTai INTO @sisoA FROM Demo_SiSo WHERE MaHP = 'HP001';
SELECT CONCAT('Session A đọc: SiSo = ', @sisoA) AS SessionA_Doc;

-- [Bước 2] SESSION B (giả lập bằng UPDATE trực tiếp, không qua đọc):
--   Giả sử B đọc cùng lúc và cũng thấy 30
SET @sisoB = 30;

-- [Bước 3] SESSION A: Ghi (30 + 1 = 31)
UPDATE Demo_SiSo SET SiSoHienTai = @sisoA + 1 WHERE MaHP = 'HP001';
COMMIT;
SELECT 'Session A commit: SiSo = 31' AS SessionA_Commit;

-- [Bước 4] SESSION B: Ghi (30 + 1 = 31) → GHI ĐÈ lên A!
START TRANSACTION;
UPDATE Demo_SiSo SET SiSoHienTai = @sisoB + 1 WHERE MaHP = 'HP001';
COMMIT;
SELECT 'Session B commit: SiSo = 31 (GHI ĐÈ!)' AS SessionB_Commit;

SELECT 'KẾT QUẢ SAI - Mong đợi 32, thực tế:' AS KetQua;
SELECT SiSoHienTai FROM Demo_SiSo WHERE MaHP = 'HP001';

-- ✅ CÁCH FIX: Dùng UPDATE nguyên tử thay vì READ rồi WRITE
SELECT '--- FIX Lost Update ---' AS Fix;
UPDATE Demo_SiSo SET SiSoHienTai = 30 WHERE MaHP = 'HP001'; -- reset
START TRANSACTION;
    UPDATE Demo_SiSo SET SiSoHienTai = SiSoHienTai + 1 WHERE MaHP = 'HP001';
COMMIT;
START TRANSACTION;
    UPDATE Demo_SiSo SET SiSoHienTai = SiSoHienTai + 1 WHERE MaHP = 'HP001';
COMMIT;
SELECT 'KẾT QUẢ ĐÚNG sau fix - Mong đợi 32, thực tế:' AS Fix_KetQua;
SELECT SiSoHienTai FROM Demo_SiSo WHERE MaHP = 'HP001';

-- Reset
UPDATE Demo_SiSo SET SiSoHienTai = 30 WHERE MaHP = 'HP001';

-- ============================================================
-- ⚠️  LỖI 2: DIRTY READ (Đọc dữ liệu bẩn/rác)
-- ============================================================
-- MÔ TẢ: SV_A đang sửa điểm nhưng chưa COMMIT.
--        SV_B đọc được điểm chưa xác nhận đó.
--        SV_A ROLLBACK → dữ liệu B đọc là SAI (rác)!
-- ============================================================

SELECT '=== LỖI 2: DIRTY READ ===' AS TenLoi;

-- Tạo bảng điểm demo
DROP TABLE IF EXISTS Demo_Diem;
CREATE TABLE Demo_Diem (
    MaDK    INT PRIMARY KEY,
    MaSV    VARCHAR(10),
    DiemTB  DECIMAL(4,2)
) ENGINE=InnoDB;
INSERT INTO Demo_Diem VALUES (1, 'SV001', 7.50);

-- SESSION A: Thay đổi điểm nhưng CHƯA commit
START TRANSACTION;
UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
SELECT 'Session A: Đã UPDATE DiemTB=9.00 (chưa COMMIT)' AS SessionA;

-- SESSION B: Đọc với mức cô lập READ UNCOMMITTED → thấy dữ liệu bẩn
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT MaSV, DiemTB AS 'Session B doc (DU LIEU BAN):' FROM Demo_Diem WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Khôi phục mặc định

-- SESSION A: ROLLBACK → điểm quay về 7.5
ROLLBACK;
SELECT 'Session A: ROLLBACK! Điểm thực tế vẫn là:' AS SessionA_Rollback;
SELECT DiemTB FROM Demo_Diem WHERE MaDK = 1;
SELECT 'Session B đã đọc DiemTB=9.00 nhưng thực tế là 7.50 → DỮ LIỆU BẨN!' AS KetLuan;

-- ✅ CÁCH FIX: Dùng READ COMMITTED hoặc cao hơn
SELECT '--- FIX Dirty Read: Dùng READ COMMITTED ---' AS Fix;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Session B sẽ không thấy dữ liệu chưa commit nữa
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ============================================================
-- ⚠️  LỖI 3: NON-REPEATABLE READ (Không đọc lại được)
-- ============================================================
-- MÔ TẢ: Trong cùng 1 transaction, SV_A đọc điểm 2 lần,
--        nhưng SV_B đã commit thay đổi giữa 2 lần đọc.
--        → Kết quả 2 lần đọc KHÁC NHAU!
-- ============================================================

SELECT '=== LỖI 3: NON-REPEATABLE READ ===' AS TenLoi;

UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1; -- reset

-- SESSION B: Set isolation thấp để demo
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SESSION A: Bắt đầu transaction, đọc lần 1
START TRANSACTION;
SELECT DiemTB AS 'Session A - Lan doc 1:' FROM Demo_Diem WHERE MaDK = 1;
-- DiemTB = 7.50

    -- SESSION B (giả lập): Trong lúc A chưa kết thúc, B sửa và COMMIT
    UPDATE Demo_Diem SET DiemTB = 9.00 WHERE MaDK = 1;
    -- B commit ngay lập tức (auto-commit)
    SELECT 'Session B: Đã sửa DiemTB=9.00 và COMMIT' AS SessionB;

-- SESSION A: Đọc lần 2 trong CÙNG transaction → KẾT QUẢ KHÁC!
SELECT DiemTB AS 'Session A - Lan doc 2 (KHAC ROI!):' FROM Demo_Diem WHERE MaDK = 1;
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ✅ CÁCH FIX: Dùng REPEATABLE READ (mặc định MySQL InnoDB)
SELECT '--- FIX Non-repeatable Read: Dùng REPEATABLE READ ---' AS Fix;
UPDATE Demo_Diem SET DiemTB = 7.50 WHERE MaDK = 1;
-- Với REPEATABLE READ, Session A sẽ luôn thấy snapshot tại thời điểm bắt đầu transaction

-- ============================================================
-- ⚠️  LỖI 4: PHANTOM READ (Bóng ma)
-- ============================================================
-- MÔ TẢ: Session A đếm số SV đăng ký HP001 = 30.
--        Session B INSERT thêm 1 SV và COMMIT.
--        Session A đếm lại = 31 → XUẤT HIỆN "BÓNG MA"!
-- ============================================================

SELECT '=== LỖI 4: PHANTOM READ ===' AS TenLoi;

-- Tạo bảng DK demo
DROP TABLE IF EXISTS Demo_DangKy;
CREATE TABLE Demo_DangKy (
    MaDK    INT AUTO_INCREMENT PRIMARY KEY,
    MaSV    VARCHAR(10),
    MaHP    VARCHAR(10)
) ENGINE=InnoDB;

-- Thêm 30 dòng mẫu
INSERT INTO Demo_DangKy (MaSV, MaHP)
SELECT CONCAT('SV', LPAD(n, 3, '0')), 'HP001'
FROM (
    SELECT @rownum := @rownum + 1 AS n
    FROM information_schema.columns, (SELECT @rownum := 0) r
    LIMIT 30
) nums;

-- SESSION A: Đọc lần 1
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- Dễ tái hiện phantom
START TRANSACTION;
SELECT COUNT(*) AS 'Session A - Lan 1 (30 SV):' FROM Demo_DangKy WHERE MaHP = 'HP001';

    -- SESSION B: INSERT thêm 1 SV mới và COMMIT
    INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001');
    SELECT 'Session B: Đã thêm SV999 vào HP001 và COMMIT' AS SessionB;

-- SESSION A: Đọc lần 2 → xuất hiện BÓNG MA (31)!
SELECT COUNT(*) AS 'Session A - Lan 2 (31 - BONG MA!):' FROM Demo_DangKy WHERE MaHP = 'HP001';
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ✅ CÁCH FIX: Dùng SERIALIZABLE
SELECT '--- FIX Phantom Read: Dùng SERIALIZABLE ---' AS Fix;
DELETE FROM Demo_DangKy WHERE MaSV = 'SV999';

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT COUNT(*) AS 'Session A (SERIALIZABLE) - Lan 1:' FROM Demo_DangKy WHERE MaHP = 'HP001';
-- Session B sẽ BỊ BLOCK khi cố INSERT vào tập dữ liệu A đang đọc
-- INSERT INTO Demo_DangKy (MaSV, MaHP) VALUES ('SV999', 'HP001'); -- BLOCKED!
SELECT COUNT(*) AS 'Session A (SERIALIZABLE) - Lan 2 (giong lan 1):' FROM Demo_DangKy WHERE MaHP = 'HP001';
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ============================================================
-- ⚠️  LỖI 5: DEADLOCK (Bế tắc khóa)
-- ============================================================
-- MÔ TẢ: Session A khóa HP001 rồi cần HP002.
--        Session B khóa HP002 rồi cần HP001.
--        → Hai session chờ nhau mãi → DEADLOCK!
--
-- *** CÁCH DEMO DEADLOCK CẦN 2 SESSION THỰC SỰ ***
-- Mở 2 tab Query trong MySQL Workbench:
-- ============================================================

SELECT '=== LỖI 5: DEADLOCK ===' AS TenLoi;
SELECT '** Cần chạy trên 2 tab MySQL Workbench riêng biệt **' AS HuongDan;

-- Giải thích script để chạy:
SELECT '
--- Tab 1 (Session A) --- chạy lần lượt:
USE QuanLyDKHP;
START TRANSACTION;
SELECT * FROM Demo_SiSo WHERE MaHP = "HP001" FOR UPDATE;  -- Khóa HP001
-- (Chờ 5 giây rồi chạy tiếp)
SELECT * FROM Demo_SiSo WHERE MaHP = "HP002" FOR UPDATE;  -- Cần HP002 (đang bị B khóa → DEADLOCK)
COMMIT;

--- Tab 2 (Session B) --- chạy SAU khi A đã chạy dòng 1:
USE QuanLyDKHP;
START TRANSACTION;
SELECT * FROM Demo_SiSo WHERE MaHP = "HP002" FOR UPDATE;  -- Khóa HP002
SELECT * FROM Demo_SiSo WHERE MaHP = "HP001" FOR UPDATE;  -- Cần HP001 (đang bị A khóa → DEADLOCK)
COMMIT;

-- MySQL sẽ tự phát hiện DEADLOCK và ROLLBACK 1 session (victim).
-- Thông báo: ERROR 1213: Deadlock found when trying to get lock; try restarting transaction
' AS ScriptDeadlock;

-- ✅ CÁCH FIX DEADLOCK:
SELECT '
--- FIX Deadlock: ---
1. Luôn khóa tài nguyên theo THỨ TỰ NHẤT ĐỊNH (VD: luôn khóa HP có MaHP nhỏ trước)
2. Dùng timeout ngắn: SET innodb_lock_wait_timeout = 5;
3. Bắt lỗi và thử lại transaction trong ứng dụng
4. Dùng SELECT ... FOR UPDATE chỉ khi thực sự cần thiết
' AS CachFix;

-- Demo fix: Cả 2 session đều khóa theo thứ tự MaHP nhỏ → lớn
START TRANSACTION;
SELECT * FROM Demo_SiSo WHERE MaHP IN ('HP001','HP002') ORDER BY MaHP FOR UPDATE;
UPDATE Demo_SiSo SET SiSoHienTai = SiSoHienTai + 1 WHERE MaHP = 'HP001';
UPDATE Demo_SiSo SET SiSoHienTai = SiSoHienTai + 1 WHERE MaHP = 'HP002';
COMMIT;
SELECT 'Fix Deadlock: Khóa đồng thời nhiều row theo thứ tự cố định' AS Fix_KetQua;

-- ============================================================
-- BẢNG TỔNG KẾT 5 LỖI TRANSACTION
-- ============================================================
SELECT '========== TỔNG KẾT 5 LỖI TRANSACTION ==========' AS Info;
SELECT
    Loi, TenLoi, MoTa, MucCoLapFix
FROM (
    SELECT 1 AS stt, 'Loi 1' AS Loi, 'Lost Update'           AS TenLoi,
           'Hai T cùng đọc-ghi 1 dòng, T sau ghi đè T trước' AS MoTa,
           'UPDATE nguyên tử (SET x = x + 1)'                 AS MucCoLapFix
    UNION ALL SELECT 2,'Loi 2','Dirty Read',
           'Đọc được dữ liệu chưa commit của T khác',
           'READ COMMITTED trở lên'
    UNION ALL SELECT 3,'Loi 3','Non-repeatable Read',
           'Đọc 2 lần trong 1 T, kết quả khác nhau',
           'REPEATABLE READ trở lên'
    UNION ALL SELECT 4,'Loi 4','Phantom Read',
           'Đọc 2 lần, lần sau thấy thêm/bớt dòng',
           'SERIALIZABLE'
    UNION ALL SELECT 5,'Loi 5','Deadlock',
           'Hai T chờ nhau giải phóng lock → bế tắc',
           'Khóa theo thứ tự cố định + retry logic'
) t ORDER BY stt;

-- Bảng mức cô lập vs lỗi
SELECT '========== MỨC CÔ LẬP vs LỖI ==========' AS Info;
SELECT
    MucCoLap,
    DirtyRead       AS 'Dirty Read',
    NonRepeatRead   AS 'Non-repeat Read',
    PhantomRead     AS 'Phantom Read'
FROM (
    SELECT 'READ UNCOMMITTED' AS MucCoLap,'CÓ THỂ'  AS DirtyRead,'CÓ THỂ'    AS NonRepeatRead,'CÓ THỂ' AS PhantomRead
    UNION ALL SELECT 'READ COMMITTED',   'Ngăn chặn','CÓ THỂ',                'CÓ THỂ'
    UNION ALL SELECT 'REPEATABLE READ',  'Ngăn chặn','Ngăn chặn',             'CÓ THỂ'
    UNION ALL SELECT 'SERIALIZABLE',     'Ngăn chặn','Ngăn chặn',             'Ngăn chặn'
) t;

SELECT '7 file SQL đã hoàn thành! Chạy theo thứ tự 01 -> 07.' AS ThongBao;
