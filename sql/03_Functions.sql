-- ============================================================
-- FILE: 03_Functions.sql
-- MỤC ĐÍCH: Các hàm tính toán dùng chung trong hệ thống
-- Yêu cầu: Công cụ tính toán (tính điểm, GPA, mã hóa,...)
-- ============================================================

USE QuanLyDKHP;

DELIMITER $$

-- ============================================================
-- FUNCTION 1: f_HashPassword
-- Mục đích: Mã hóa mật khẩu bằng SHA2-256 trước khi lưu
-- Input:    p_MatKhau (mật khẩu gốc)
-- Output:   Chuỗi hash 64 ký tự
-- ============================================================
DROP FUNCTION IF EXISTS f_HashPassword$$
CREATE FUNCTION f_HashPassword(p_MatKhau VARCHAR(100))
RETURNS VARCHAR(255)
DETERMINISTIC
COMMENT 'Mã hóa mật khẩu bằng SHA2-256'
BEGIN
    RETURN SHA2(p_MatKhau, 256);
END$$

-- ============================================================
-- FUNCTION 2: f_TinhDiemTB
-- Mục đích: Tính điểm trung bình có trọng số của môn học
-- Công thức: CC*10% + GiuaKy*30% + CuoiKy*60%
-- Input:    p_DiemCC, p_DiemGiuaKy, p_DiemCuoiKy
-- Output:   Điểm trung bình (DECIMAL 4,2)
-- ============================================================
DROP FUNCTION IF EXISTS f_TinhDiemTB$$
CREATE FUNCTION f_TinhDiemTB(
    p_DiemCC      DECIMAL(4,2),
    p_DiemGiuaKy  DECIMAL(4,2),
    p_DiemCuoiKy  DECIMAL(4,2)
)
RETURNS DECIMAL(4,2)
DETERMINISTIC
COMMENT 'Tính điểm TB = CC*10% + GK*30% + CK*60%'
BEGIN
    DECLARE v_DiemTB DECIMAL(4,2);
    SET v_DiemTB = ROUND(p_DiemCC * 0.10 + p_DiemGiuaKy * 0.30 + p_DiemCuoiKy * 0.60, 2);
    RETURN v_DiemTB;
END$$

-- ============================================================
-- FUNCTION 3: f_TinhGPA
-- Mục đích: Tính điểm GPA theo thang 4.0 của sinh viên
-- Công thức: Tính trung bình có trọng số theo số tín chỉ
-- Input:    p_MaSV (mã sinh viên)
-- Output:   GPA (DECIMAL 3,2) - thang 4.0
-- ============================================================
DROP FUNCTION IF EXISTS f_TinhGPA$$
CREATE FUNCTION f_TinhGPA(p_MaSV VARCHAR(10))
RETURNS DECIMAL(3,2)
READS SQL DATA
COMMENT 'Tính GPA thang 4.0 của sinh viên'
BEGIN
    DECLARE v_GPA          DECIMAL(5,4) DEFAULT 0;
    DECLARE v_TongTinChi   INT          DEFAULT 0;
    DECLARE v_TongDiem     DECIMAL(10,4) DEFAULT 0;

    -- Lấy tổng (điểm × tín chỉ) và tổng tín chỉ của tất cả môn đã hoàn thành
    SELECT 
        SUM(bd.DiemTB * mh.SoTinChi),
        SUM(mh.SoTinChi)
    INTO v_TongDiem, v_TongTinChi
    FROM BangDiem bd
    JOIN DangKyHocPhan dk ON bd.MaDK = dk.MaDK
    JOIN HocPhan       hp ON dk.MaHP = hp.MaHP
    JOIN MonHoc        mh ON hp.MaMH = mh.MaMH
    WHERE dk.MaSV = p_MaSV
      AND bd.DiemTB IS NOT NULL;

    -- Nếu chưa có điểm nào
    IF v_TongTinChi = 0 OR v_TongTinChi IS NULL THEN
        RETURN 0.00;
    END IF;

    -- Quy đổi sang thang 4.0
    SET v_GPA = ROUND((v_TongDiem / v_TongTinChi) * 4.0 / 10.0, 2);
    RETURN v_GPA;
END$$

-- ============================================================
-- FUNCTION 4: f_XepLoaiHocLuc
-- Mục đích: Xếp loại học lực dựa trên GPA thang 4.0
-- Input:    p_GPA (điểm GPA thang 4.0)
-- Output:   Loại học lực (Xuất sắc/Giỏi/Khá/Trung bình/Yếu/Kém)
-- ============================================================
DROP FUNCTION IF EXISTS f_XepLoaiHocLuc$$
CREATE FUNCTION f_XepLoaiHocLuc(p_GPA DECIMAL(3,2))
RETURNS VARCHAR(20)
DETERMINISTIC
COMMENT 'Xếp loại học lực theo GPA thang 4.0'
BEGIN
    CASE
        WHEN p_GPA >= 3.60 THEN RETURN 'Xuất sắc';
        WHEN p_GPA >= 3.20 THEN RETURN 'Giỏi';
        WHEN p_GPA >= 2.50 THEN RETURN 'Khá';
        WHEN p_GPA >= 2.00 THEN RETURN 'Trung bình';
        WHEN p_GPA >= 1.00 THEN RETURN 'Yếu';
        ELSE RETURN 'Kém';
    END CASE;
END$$

-- ============================================================
-- FUNCTION 5: f_KiemTraTrungLich
-- Mục đích: Kiểm tra xem sinh viên có bị trùng lịch khi
--           đăng ký một học phần mới hay không
-- Input:    p_MaSV, p_MaHP (học phần muốn đăng ký)
-- Output:   1 = BỊ TRÙNG, 0 = KHÔNG TRÙNG
-- ============================================================
DROP FUNCTION IF EXISTS f_KiemTraTrungLich$$
CREATE FUNCTION f_KiemTraTrungLich(
    p_MaSV VARCHAR(10),
    p_MaHP VARCHAR(10)
)
RETURNS TINYINT(1)
READS SQL DATA
COMMENT 'Kiểm tra trùng lịch học khi đăng ký học phần mới'
BEGIN
    DECLARE v_TrungLich INT DEFAULT 0;

    -- So sánh lịch học của HP mới với tất cả HP sinh viên đã đăng ký
    -- Trùng lịch khi: cùng ngày trong tuần VÀ thời gian giao nhau
    SELECT COUNT(*)
    INTO v_TrungLich
    FROM LichHoc lh_moi
    -- Lịch của học phần muốn đăng ký
    JOIN LichHoc lh_cu 
        ON lh_moi.Thu = lh_cu.Thu
        -- Kiểm tra khoảng thời gian giao nhau
        AND lh_moi.TietBD < lh_cu.TietKT
        AND lh_moi.TietKT > lh_cu.TietBD
    -- Các học phần sinh viên đang học
    JOIN DangKyHocPhan dk ON lh_cu.MaHP = dk.MaHP
    WHERE lh_moi.MaHP = p_MaHP
      AND dk.MaSV    = p_MaSV
      AND dk.TrangThai = 'DaDuyet';

    RETURN IF(v_TrungLich > 0, 1, 0);
END$$

-- ============================================================
-- FUNCTION 6: f_TongTinChiDaDangKy
-- Mục đích: Tính tổng số tín chỉ sinh viên đã đăng ký
--           trong một học kỳ cụ thể
-- Input:    p_MaSV, p_HocKy, p_NamHoc
-- Output:   Tổng số tín chỉ (INT)
-- ============================================================
DROP FUNCTION IF EXISTS f_TongTinChiDaDangKy$$
CREATE FUNCTION f_TongTinChiDaDangKy(
    p_MaSV   VARCHAR(10),
    p_HocKy  TINYINT,
    p_NamHoc VARCHAR(9)
)
RETURNS INT
READS SQL DATA
COMMENT 'Tính tổng tín chỉ sinh viên đăng ký trong học kỳ'
BEGIN
    DECLARE v_TongTC INT DEFAULT 0;

    SELECT COALESCE(SUM(mh.SoTinChi), 0)
    INTO v_TongTC
    FROM DangKyHocPhan dk
    JOIN HocPhan hp ON dk.MaHP = hp.MaHP
    JOIN MonHoc  mh ON hp.MaMH = mh.MaMH
    WHERE dk.MaSV       = p_MaSV
      AND hp.HocKy      = p_HocKy
      AND hp.NamHoc     = p_NamHoc
      AND dk.TrangThai  = 'DaDuyet';

    RETURN v_TongTC;
END$$

DELIMITER ;

-- ============================================================
-- KIỂM TRA FUNCTIONS
-- ============================================================
SELECT 'Kiểm tra f_HashPassword:' AS Test,
       f_HashPassword('sv123456') AS KetQua;

SELECT 'Kiểm tra f_TinhDiemTB (9.5, 8.0, 8.5):' AS Test,
       f_TinhDiemTB(9.5, 8.0, 8.5) AS KetQua;

SELECT 'Kiểm tra f_TinhGPA (SV001):' AS Test,
       f_TinhGPA('SV001') AS GPA,
       f_XepLoaiHocLuc(f_TinhGPA('SV001')) AS XepLoai;

SELECT 'Kiểm tra f_KiemTraTrungLich (SV001 - HP002):' AS Test,
       f_KiemTraTrungLich('SV001', 'HP002') AS TrungLich_1Thi0Khong;

SELECT 'Kiểm tra f_TongTinChi (SV001, HK1, 2025-2026):' AS Test,
       f_TongTinChiDaDangKy('SV001', 1, '2025-2026') AS TongTinChi;

SELECT '6 Functions đã tạo thành công!' AS ThongBao;
