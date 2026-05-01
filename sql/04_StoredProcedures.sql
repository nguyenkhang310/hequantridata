-- ============================================================
-- FILE: 04_StoredProcedures.sql
-- MỤC ĐÍCH: Đóng gói toàn bộ logic nghiệp vụ CRUD hệ thống
-- ============================================================

USE QuanLyDKHP;
DELIMITER $$

-- ============================================================
-- SP 1: sp_DangNhap
-- Đăng nhập cho sinh viên hoặc giáo viên
-- ============================================================
DROP PROCEDURE IF EXISTS sp_DangNhap$$
CREATE PROCEDURE sp_DangNhap(
    IN  p_MaNguoiDung VARCHAR(10),
    IN  p_MatKhau     VARCHAR(100),
    IN  p_VaiTro      ENUM('SinhVien','GiaoVien'),
    OUT p_ThanhCong   TINYINT,
    OUT p_HoTen       VARCHAR(100),
    OUT p_ThongBao    VARCHAR(200)
)
COMMENT 'Xác thực đăng nhập sinh viên hoặc giáo viên'
BEGIN
    DECLARE v_MatKhauDB VARCHAR(255);
    DECLARE v_HoTen     VARCHAR(100);

    IF p_VaiTro = 'SinhVien' THEN
        SELECT MatKhau, HoTen INTO v_MatKhauDB, v_HoTen
        FROM SinhVien WHERE MaSV = p_MaNguoiDung;
    ELSE
        SELECT MatKhau, HoTen INTO v_MatKhauDB, v_HoTen
        FROM GiaoVien WHERE MaGV = p_MaNguoiDung;
    END IF;

    IF v_MatKhauDB IS NULL THEN
        SET p_ThanhCong = 0;
        SET p_HoTen     = NULL;
        SET p_ThongBao  = 'Tài khoản không tồn tại!';
    ELSEIF v_MatKhauDB != SHA2(p_MatKhau, 256) THEN
        SET p_ThanhCong = 0;
        SET p_HoTen     = NULL;
        SET p_ThongBao  = 'Sai mật khẩu!';
    ELSE
        SET p_ThanhCong = 1;
        SET p_HoTen     = v_HoTen;
        SET p_ThongBao  = CONCAT('Chào mừng, ', v_HoTen, '!');
        -- Ghi log
        INSERT INTO LogHoatDong(MaNguoiDung, VaiTro, HanhDong, BangTacDong, GhiChu)
        VALUES (p_MaNguoiDung, p_VaiTro, 'DANG_NHAP', NULL, 'Đăng nhập thành công');
    END IF;
END$$

-- ============================================================
-- SP 2: sp_DangKyHocPhan
-- Đăng ký học phần cho sinh viên (có kiểm tra đầy đủ)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_DangKyHocPhan$$
CREATE PROCEDURE sp_DangKyHocPhan(
    IN  p_MaSV      VARCHAR(10),
    IN  p_MaHP      VARCHAR(10),
    OUT p_ThanhCong TINYINT,
    OUT p_ThongBao  VARCHAR(300)
)
COMMENT 'Đăng ký học phần cho sinh viên - kiểm tra đầy đủ ràng buộc'
BEGIN
    DECLARE v_SiSoHT    INT;
    DECLARE v_SiSoMax   INT;
    DECLARE v_TrangThai VARCHAR(20);
    DECLARE v_DaDK      INT DEFAULT 0;
    DECLARE v_TrungLich TINYINT DEFAULT 0;
    DECLARE v_TongTC    INT DEFAULT 0;
    DECLARE v_MaxTC     INT DEFAULT 25; -- Giới hạn 25 tín chỉ/học kỳ
    DECLARE v_HocKy     TINYINT;
    DECLARE v_NamHoc    VARCHAR(9);

    -- Lấy thông tin học phần
    SELECT SiSoHienTai, SiSoToiDa, TrangThai, HocKy, NamHoc
    INTO   v_SiSoHT, v_SiSoMax, v_TrangThai, v_HocKy, v_NamHoc
    FROM HocPhan WHERE MaHP = p_MaHP;

    -- Kiểm tra học phần tồn tại
    IF v_TrangThai IS NULL THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = 'Học phần không tồn tại!';

    -- Kiểm tra học phần còn mở đăng ký
    ELSEIF v_TrangThai != 'MoDangKy' THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = 'Học phần đã đóng đăng ký!';

    -- Kiểm tra sĩ số
    ELSEIF v_SiSoHT >= v_SiSoMax THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = CONCAT('Học phần đã đầy! (', v_SiSoHT, '/', v_SiSoMax, ')');

    ELSE
        -- Kiểm tra đã đăng ký chưa
        SELECT COUNT(*) INTO v_DaDK
        FROM DangKyHocPhan
        WHERE MaSV = p_MaSV AND MaHP = p_MaHP AND TrangThai = 'DaDuyet';

        IF v_DaDK > 0 THEN
            SET p_ThanhCong = 0;
            SET p_ThongBao  = 'Bạn đã đăng ký học phần này rồi!';

        ELSE
            -- Kiểm tra trùng lịch
            SET v_TrungLich = f_KiemTraTrungLich(p_MaSV, p_MaHP);

            IF v_TrungLich = 1 THEN
                SET p_ThanhCong = 0;
                SET p_ThongBao  = 'Bị trùng lịch với học phần đã đăng ký!';

            ELSE
                -- Kiểm tra giới hạn tín chỉ
                SET v_TongTC = f_TongTinChiDaDangKy(p_MaSV, v_HocKy, v_NamHoc);

                IF v_TongTC >= v_MaxTC THEN
                    SET p_ThanhCong = 0;
                    SET p_ThongBao  = CONCAT('Đã đạt giới hạn ', v_MaxTC, ' tín chỉ/học kỳ!');
                ELSE
                    -- Tất cả OK → thực hiện đăng ký
                    INSERT INTO DangKyHocPhan (MaSV, MaHP) VALUES (p_MaSV, p_MaHP);
                    UPDATE HocPhan SET SiSoHienTai = SiSoHienTai + 1 WHERE MaHP = p_MaHP;

                    -- Ghi log
                    INSERT INTO LogHoatDong(MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi, GhiChu)
                    VALUES (p_MaSV, 'SinhVien', 'DANG_KY_HP', 'DangKyHocPhan', p_MaHP,
                            CONCAT('Đăng ký học phần ', p_MaHP, ' thành công'));

                    SET p_ThanhCong = 1;
                    SET p_ThongBao  = CONCAT('Đăng ký học phần ', p_MaHP, ' thành công!');
                END IF;
            END IF;
        END IF;
    END IF;
END$$

-- ============================================================
-- SP 3: sp_HuyDangKyHocPhan
-- Hủy đăng ký học phần
-- ============================================================
DROP PROCEDURE IF EXISTS sp_HuyDangKyHocPhan$$
CREATE PROCEDURE sp_HuyDangKyHocPhan(
    IN  p_MaSV      VARCHAR(10),
    IN  p_MaHP      VARCHAR(10),
    OUT p_ThanhCong TINYINT,
    OUT p_ThongBao  VARCHAR(200)
)
COMMENT 'Hủy đăng ký học phần của sinh viên'
BEGIN
    DECLARE v_MaDK    INT;
    DECLARE v_TrangThai VARCHAR(20);

    SELECT MaDK, TrangThai INTO v_MaDK, v_TrangThai
    FROM DangKyHocPhan
    WHERE MaSV = p_MaSV AND MaHP = p_MaHP;

    IF v_MaDK IS NULL THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = 'Không tìm thấy đăng ký!';
    ELSEIF v_TrangThai = 'HuyBo' THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = 'Đăng ký đã bị hủy trước đó!';
    ELSEIF v_TrangThai = 'HoanThanh' THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = 'Không thể hủy môn đã hoàn thành!';
    ELSE
        UPDATE DangKyHocPhan SET TrangThai = 'HuyBo' WHERE MaDK = v_MaDK;
        UPDATE HocPhan SET SiSoHienTai = SiSoHienTai - 1 WHERE MaHP = p_MaHP;

        INSERT INTO LogHoatDong(MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi, GhiChu)
        VALUES (p_MaSV, 'SinhVien', 'HUY_DK_HP', 'DangKyHocPhan', p_MaHP,
                CONCAT('Hủy đăng ký học phần ', p_MaHP));

        SET p_ThanhCong = 1;
        SET p_ThongBao  = 'Hủy đăng ký thành công!';
    END IF;
END$$

-- ============================================================
-- SP 4: sp_XemDanhSachHocPhan
-- Xem danh sách học phần đang mở đăng ký
-- ============================================================
DROP PROCEDURE IF EXISTS sp_XemDanhSachHocPhan$$
CREATE PROCEDURE sp_XemDanhSachHocPhan(
    IN p_HocKy  TINYINT,
    IN p_NamHoc VARCHAR(9)
)
COMMENT 'Xem danh sách học phần đang mở đăng ký trong học kỳ'
BEGIN
    SELECT 
        hp.MaHP,
        mh.TenMH,
        mh.SoTinChi,
        gv.HoTen        AS TenGiaoVien,
        hp.SiSoHienTai,
        hp.SiSoToiDa,
        (hp.SiSoToiDa - hp.SiSoHienTai) AS ConLai,
        hp.TrangThai,
        GROUP_CONCAT(
            CONCAT(lh.Thu, ' T', lh.TietBD, '-', lh.TietKT, ' P.', lh.Phong)
            SEPARATOR ' | '
        ) AS LichHoc
    FROM HocPhan hp
    JOIN MonHoc  mh ON hp.MaMH = mh.MaMH
    LEFT JOIN GiaoVien gv ON hp.MaGV = gv.MaGV
    LEFT JOIN LichHoc  lh ON hp.MaHP = lh.MaHP
    WHERE hp.HocKy  = p_HocKy
      AND hp.NamHoc = p_NamHoc
      AND hp.TrangThai = 'MoDangKy'
    GROUP BY hp.MaHP, mh.TenMH, mh.SoTinChi,
             gv.HoTen, hp.SiSoHienTai, hp.SiSoToiDa, hp.TrangThai
    ORDER BY mh.TenMH;
END$$

-- ============================================================
-- SP 5: sp_XemLichHocSinhVien
-- Xem thời khóa biểu của sinh viên
-- ============================================================
DROP PROCEDURE IF EXISTS sp_XemLichHocSinhVien$$
CREATE PROCEDURE sp_XemLichHocSinhVien(
    IN p_MaSV   VARCHAR(10),
    IN p_HocKy  TINYINT,
    IN p_NamHoc VARCHAR(9)
)
COMMENT 'Xem thời khóa biểu của sinh viên theo học kỳ'
BEGIN
    SELECT
        lh.Thu,
        lh.TietBD,
        lh.TietKT,
        lh.Phong,
        mh.TenMH,
        hp.MaHP,
        gv.HoTen AS TenGiaoVien
    FROM LichHoc lh
    JOIN HocPhan        hp ON lh.MaHP = hp.MaHP
    JOIN MonHoc         mh ON hp.MaMH = mh.MaMH
    JOIN DangKyHocPhan  dk ON hp.MaHP = dk.MaHP
    LEFT JOIN GiaoVien  gv ON hp.MaGV = gv.MaGV
    WHERE dk.MaSV       = p_MaSV
      AND dk.TrangThai  = 'DaDuyet'
      AND hp.HocKy      = p_HocKy
      AND hp.NamHoc     = p_NamHoc
    ORDER BY 
        FIELD(lh.Thu,'Thu2','Thu3','Thu4','Thu5','Thu6','Thu7','ChuNhat'),
        lh.TietBD;
END$$

-- ============================================================
-- SP 6: sp_XemBangDiem
-- Xem bảng điểm toàn bộ của sinh viên
-- ============================================================
DROP PROCEDURE IF EXISTS sp_XemBangDiem$$
CREATE PROCEDURE sp_XemBangDiem(IN p_MaSV VARCHAR(10))
COMMENT 'Xem toàn bộ bảng điểm và GPA của sinh viên'
BEGIN
    -- Chi tiết điểm từng môn
    SELECT
        hp.HocKy,
        hp.NamHoc,
        mh.MaMH,
        mh.TenMH,
        mh.SoTinChi,
        bd.DiemCC,
        bd.DiemGiuaKy,
        bd.DiemCuoiKy,
        bd.DiemTB,
        bd.XepLoai
    FROM BangDiem bd
    JOIN DangKyHocPhan dk ON bd.MaDK = dk.MaDK
    JOIN HocPhan       hp ON dk.MaHP = hp.MaHP
    JOIN MonHoc        mh ON hp.MaMH = mh.MaMH
    WHERE dk.MaSV = p_MaSV
    ORDER BY hp.NamHoc, hp.HocKy, mh.TenMH;

    -- Tóm tắt GPA
    SELECT
        f_TinhGPA(p_MaSV)                       AS GPA_Thang4,
        f_XepLoaiHocLuc(f_TinhGPA(p_MaSV))     AS XepLoai,
        COUNT(bd.MaBD)                           AS TongMonCoDiem,
        SUM(mh.SoTinChi)                         AS TongTinChi
    FROM BangDiem bd
    JOIN DangKyHocPhan dk ON bd.MaDK = dk.MaDK
    JOIN HocPhan       hp ON dk.MaHP = hp.MaHP
    JOIN MonHoc        mh ON hp.MaMH = mh.MaMH
    WHERE dk.MaSV = p_MaSV;
END$$

-- ============================================================
-- SP 7: sp_CapNhatDiem
-- Giáo viên cập nhật điểm cho sinh viên
-- ============================================================
DROP PROCEDURE IF EXISTS sp_CapNhatDiem$$
CREATE PROCEDURE sp_CapNhatDiem(
    IN  p_MaGV        VARCHAR(10),
    IN  p_MaDK        INT,
    IN  p_DiemCC      DECIMAL(4,2),
    IN  p_DiemGiuaKy  DECIMAL(4,2),
    IN  p_DiemCuoiKy  DECIMAL(4,2),
    OUT p_ThanhCong   TINYINT,
    OUT p_ThongBao    VARCHAR(200)
)
COMMENT 'Giáo viên nhập/cập nhật điểm cho sinh viên'
BEGIN
    DECLARE v_MaGV_HP VARCHAR(10);

    -- Xác nhận giáo viên có quyền chấm điểm học phần này không
    SELECT hp.MaGV INTO v_MaGV_HP
    FROM DangKyHocPhan dk
    JOIN HocPhan hp ON dk.MaHP = hp.MaHP
    WHERE dk.MaDK = p_MaDK;

    IF v_MaGV_HP IS NULL THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = 'Không tìm thấy đăng ký!';
    ELSEIF v_MaGV_HP != p_MaGV THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = 'Bạn không có quyền chấm điểm học phần này!';
    ELSE
        INSERT INTO BangDiem (MaDK, DiemCC, DiemGiuaKy, DiemCuoiKy)
        VALUES (p_MaDK, p_DiemCC, p_DiemGiuaKy, p_DiemCuoiKy)
        ON DUPLICATE KEY UPDATE
            DiemCC      = p_DiemCC,
            DiemGiuaKy  = p_DiemGiuaKy,
            DiemCuoiKy  = p_DiemCuoiKy;

        INSERT INTO LogHoatDong(MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi)
        VALUES (p_MaGV, 'GiaoVien', 'CAP_NHAT_DIEM', 'BangDiem', p_MaDK);

        SET p_ThanhCong = 1;
        SET p_ThongBao  = 'Cập nhật điểm thành công!';
    END IF;
END$$

-- ============================================================
-- SP 8: sp_ThemSinhVien
-- Admin thêm sinh viên mới
-- ============================================================
DROP PROCEDURE IF EXISTS sp_ThemSinhVien$$
CREATE PROCEDURE sp_ThemSinhVien(
    IN  p_MaSV      VARCHAR(10),
    IN  p_HoTen     VARCHAR(100),
    IN  p_NgaySinh  DATE,
    IN  p_GioiTinh  ENUM('Nam','Nu','Khac'),
    IN  p_Email     VARCHAR(100),
    IN  p_Lop       VARCHAR(20),
    IN  p_KhoaHoc   VARCHAR(20),
    OUT p_ThanhCong TINYINT,
    OUT p_ThongBao  VARCHAR(200)
)
COMMENT 'Admin thêm sinh viên mới vào hệ thống'
BEGIN
    DECLARE v_Ton INT DEFAULT 0;
    SELECT COUNT(*) INTO v_Ton FROM SinhVien WHERE MaSV = p_MaSV;

    IF v_Ton > 0 THEN
        SET p_ThanhCong = 0;
        SET p_ThongBao  = CONCAT('Mã sinh viên ', p_MaSV, ' đã tồn tại!');
    ELSE
        INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, Email, Lop, KhoaHoc, MatKhau)
        VALUES (p_MaSV, p_HoTen, p_NgaySinh, p_GioiTinh, p_Email, p_Lop, p_KhoaHoc,
                SHA2('sv123456', 256));
        SET p_ThanhCong = 1;
        SET p_ThongBao  = CONCAT('Thêm sinh viên ', p_HoTen, ' thành công! Mật khẩu mặc định: sv123456');
    END IF;
END$$

-- ============================================================
-- SP 9: sp_ThongKeSinhVienTheoHP
-- Danh sách sinh viên trong một học phần
-- ============================================================
DROP PROCEDURE IF EXISTS sp_ThongKeSinhVienTheoHP$$
CREATE PROCEDURE sp_ThongKeSinhVienTheoHP(IN p_MaHP VARCHAR(10))
COMMENT 'Xem danh sách sinh viên đã đăng ký một học phần'
BEGIN
    SELECT
        sv.MaSV,
        sv.HoTen,
        sv.Lop,
        sv.Email,
        dk.NgayDK,
        dk.TrangThai,
        COALESCE(bd.DiemTB, 'Chưa có') AS DiemTB
    FROM DangKyHocPhan dk
    JOIN SinhVien sv ON dk.MaSV = sv.MaSV
    LEFT JOIN BangDiem bd ON dk.MaDK = bd.MaDK
    WHERE dk.MaHP = p_MaHP
    ORDER BY sv.HoTen;
END$$

-- ============================================================
-- SP 10: sp_DoiMatKhau
-- Sinh viên/Giáo viên đổi mật khẩu
-- ============================================================
DROP PROCEDURE IF EXISTS sp_DoiMatKhau$$
CREATE PROCEDURE sp_DoiMatKhau(
    IN  p_MaNguoiDung VARCHAR(10),
    IN  p_VaiTro      ENUM('SinhVien','GiaoVien'),
    IN  p_MatKhauCu   VARCHAR(100),
    IN  p_MatKhauMoi  VARCHAR(100),
    OUT p_ThanhCong   TINYINT,
    OUT p_ThongBao    VARCHAR(200)
)
COMMENT 'Đổi mật khẩu người dùng'
BEGIN
    DECLARE v_MatKhauDB VARCHAR(255);

    IF p_VaiTro = 'SinhVien' THEN
        SELECT MatKhau INTO v_MatKhauDB FROM SinhVien WHERE MaSV = p_MaNguoiDung;
    ELSE
        SELECT MatKhau INTO v_MatKhauDB FROM GiaoVien WHERE MaGV = p_MaNguoiDung;
    END IF;

    IF v_MatKhauDB IS NULL THEN
        SET p_ThanhCong = 0; SET p_ThongBao = 'Tài khoản không tồn tại!';
    ELSEIF v_MatKhauDB != SHA2(p_MatKhauCu, 256) THEN
        SET p_ThanhCong = 0; SET p_ThongBao = 'Mật khẩu cũ không đúng!';
    ELSEIF LENGTH(p_MatKhauMoi) < 6 THEN
        SET p_ThanhCong = 0; SET p_ThongBao = 'Mật khẩu mới phải có ít nhất 6 ký tự!';
    ELSE
        IF p_VaiTro = 'SinhVien' THEN
            UPDATE SinhVien SET MatKhau = SHA2(p_MatKhauMoi, 256) WHERE MaSV = p_MaNguoiDung;
        ELSE
            UPDATE GiaoVien SET MatKhau = SHA2(p_MatKhauMoi, 256) WHERE MaGV = p_MaNguoiDung;
        END IF;
        SET p_ThanhCong = 1; SET p_ThongBao = 'Đổi mật khẩu thành công!';
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- KIỂM TRA STORED PROCEDURES
-- ============================================================
CALL sp_XemDanhSachHocPhan(1, '2025-2026');

SET @ok=0; SET @msg='';
CALL sp_DangNhap('SV001', 'sv123456', 'SinhVien', @ok, @ten, @msg);
SELECT @ok AS ThanhCong, @ten AS HoTen, @msg AS ThongBao;

CALL sp_XemBangDiem('SV001');
CALL sp_XemLichHocSinhVien('SV001', 1, '2025-2026');
CALL sp_ThongKeSinhVienTheoHP('HP001');

SELECT '10 Stored Procedures đã tạo thành công!' AS ThongBao;
