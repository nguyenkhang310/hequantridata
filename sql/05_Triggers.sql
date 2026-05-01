-- ============================================================
-- FILE: 05_Triggers.sql
-- MỤC ĐÍCH: Tự động hóa tác vụ, bảo vệ dữ liệu, ghi log
-- ============================================================

USE QuanLyDKHP;
DELIMITER $$

-- ============================================================
-- TRIGGER 1: trg_BEFORE_DangKy_KiemTra
-- BEFORE INSERT on DangKyHocPhan
-- Tự động kiểm tra trùng lịch TRƯỚC KHI đăng ký
-- (Lớp bảo vệ thứ 2, sau SP)
-- ============================================================
DROP TRIGGER IF EXISTS trg_BEFORE_DangKy_KiemTra$$
CREATE TRIGGER trg_BEFORE_DangKy_KiemTra
BEFORE INSERT ON DangKyHocPhan
FOR EACH ROW
BEGIN
    DECLARE v_TrungLich   TINYINT DEFAULT 0;
    DECLARE v_TrangThaiHP VARCHAR(20);
    DECLARE v_SiSoHT      INT;
    DECLARE v_SiSoMax     INT;

    -- Kiểm tra trạng thái học phần
    SELECT TrangThai, SiSoHienTai, SiSoToiDa
    INTO   v_TrangThaiHP, v_SiSoHT, v_SiSoMax
    FROM HocPhan WHERE MaHP = NEW.MaHP;

    IF v_TrangThaiHP != 'MoDangKy' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Học phần đã đóng đăng ký!';
    END IF;

    IF v_SiSoHT >= v_SiSoMax THEN
        SIGNAL SQLSTATE '45001'
            SET MESSAGE_TEXT = 'Học phần đã đầy, không thể đăng ký thêm!';
    END IF;

    -- Kiểm tra trùng lịch
    SET v_TrungLich = f_KiemTraTrungLich(NEW.MaSV, NEW.MaHP);
    IF v_TrungLich = 1 THEN
        SIGNAL SQLSTATE '45002'
            SET MESSAGE_TEXT = 'Lịch học bị trùng với học phần đã đăng ký!';
    END IF;
END$$

-- ============================================================
-- TRIGGER 2: trg_AFTER_DangKy_CapNhatSiSo
-- AFTER INSERT on DangKyHocPhan
-- Tự động tăng sĩ số và ghi log khi đăng ký thành công
-- ============================================================
DROP TRIGGER IF EXISTS trg_AFTER_DangKy_CapNhatSiSo$$
CREATE TRIGGER trg_AFTER_DangKy_CapNhatSiSo
AFTER INSERT ON DangKyHocPhan
FOR EACH ROW
BEGIN
    -- Cập nhật sĩ số học phần
    UPDATE HocPhan
    SET SiSoHienTai = SiSoHienTai + 1
    WHERE MaHP = NEW.MaHP;

    -- Ghi log hoạt động
    INSERT INTO LogHoatDong (MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi, GhiChu)
    VALUES (
        NEW.MaSV, 'SinhVien', 'DANG_KY_HP',
        'DangKyHocPhan', NEW.MaHP,
        CONCAT('[TRIGGER] SV ', NEW.MaSV, ' đăng ký HP ', NEW.MaHP, ' lúc ', NOW())
    );
END$$

-- ============================================================
-- TRIGGER 3: trg_AFTER_HuyDangKy_CapNhatSiSo
-- AFTER UPDATE on DangKyHocPhan (khi TrangThai -> 'HuyBo')
-- Tự động giảm sĩ số và ghi log khi hủy đăng ký
-- ============================================================
DROP TRIGGER IF EXISTS trg_AFTER_HuyDangKy_CapNhatSiSo$$
CREATE TRIGGER trg_AFTER_HuyDangKy_CapNhatSiSo
AFTER UPDATE ON DangKyHocPhan
FOR EACH ROW
BEGIN
    -- Chỉ xử lý khi trạng thái chuyển sang HuyBo
    IF NEW.TrangThai = 'HuyBo' AND OLD.TrangThai = 'DaDuyet' THEN
        -- Giảm sĩ số
        UPDATE HocPhan
        SET SiSoHienTai = SiSoHienTai - 1
        WHERE MaHP = NEW.MaHP AND SiSoHienTai > 0;

        -- Ghi log
        INSERT INTO LogHoatDong (MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi, GhiChu)
        VALUES (
            NEW.MaSV, 'SinhVien', 'HUY_DK_HP',
            'DangKyHocPhan', NEW.MaHP,
            CONCAT('[TRIGGER] SV ', NEW.MaSV, ' hủy HP ', NEW.MaHP, ' lúc ', NOW())
        );
    END IF;
END$$

-- ============================================================
-- TRIGGER 4: trg_BEFORE_XoaHocPhan_BaoVe
-- BEFORE DELETE on HocPhan
-- Ngăn xóa học phần khi đã có sinh viên đăng ký
-- ============================================================
DROP TRIGGER IF EXISTS trg_BEFORE_XoaHocPhan_BaoVe$$
CREATE TRIGGER trg_BEFORE_XoaHocPhan_BaoVe
BEFORE DELETE ON HocPhan
FOR EACH ROW
BEGIN
    DECLARE v_SoSVDangKy INT DEFAULT 0;

    SELECT COUNT(*) INTO v_SoSVDangKy
    FROM DangKyHocPhan
    WHERE MaHP = OLD.MaHP AND TrangThai = 'DaDuyet';

    IF v_SoSVDangKy > 0 THEN
        SIGNAL SQLSTATE '45003'
            SET MESSAGE_TEXT = 'Không thể xóa học phần vì đã có sinh viên đăng ký!';
    END IF;
END$$

-- ============================================================
-- TRIGGER 5: trg_AFTER_CapNhatDiem_GhiLog
-- AFTER INSERT/UPDATE on BangDiem
-- Ghi log mỗi khi có thay đổi điểm số
-- ============================================================
DROP TRIGGER IF EXISTS trg_AFTER_InsertDiem_GhiLog$$
CREATE TRIGGER trg_AFTER_InsertDiem_GhiLog
AFTER INSERT ON BangDiem
FOR EACH ROW
BEGIN
    DECLARE v_MaSV VARCHAR(10);
    DECLARE v_MaHP VARCHAR(10);

    SELECT dk.MaSV, dk.MaHP INTO v_MaSV, v_MaHP
    FROM DangKyHocPhan dk WHERE dk.MaDK = NEW.MaDK;

    INSERT INTO LogHoatDong (MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi, GhiChu)
    VALUES (
        v_MaSV, 'GiaoVien', 'NHAP_DIEM',
        'BangDiem', NEW.MaDK,
        CONCAT('[TRIGGER] Nhập điểm SV=', v_MaSV, ' HP=', v_MaHP,
               ' DiemTB=', NEW.DiemTB, ' XepLoai=', NEW.XepLoai)
    );
END$$

DROP TRIGGER IF EXISTS trg_AFTER_UpdateDiem_GhiLog$$
CREATE TRIGGER trg_AFTER_UpdateDiem_GhiLog
AFTER UPDATE ON BangDiem
FOR EACH ROW
BEGIN
    DECLARE v_MaSV VARCHAR(10);
    DECLARE v_MaHP VARCHAR(10);

    SELECT dk.MaSV, dk.MaHP INTO v_MaSV, v_MaHP
    FROM DangKyHocPhan dk WHERE dk.MaDK = NEW.MaDK;

    INSERT INTO LogHoatDong (MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi, GhiChu)
    VALUES (
        v_MaSV, 'GiaoVien', 'SUA_DIEM',
        'BangDiem', NEW.MaDK,
        CONCAT('[TRIGGER] Sửa điểm SV=', v_MaSV, ' HP=', v_MaHP,
               ' DiemTB: ', OLD.DiemTB, ' -> ', NEW.DiemTB)
    );
END$$

-- ============================================================
-- TRIGGER 6: trg_BEFORE_XoaSinhVien_BaoVe
-- BEFORE DELETE on SinhVien
-- Ngăn xóa SV đang có đăng ký hợp lệ
-- ============================================================
DROP TRIGGER IF EXISTS trg_BEFORE_XoaSinhVien_BaoVe$$
CREATE TRIGGER trg_BEFORE_XoaSinhVien_BaoVe
BEFORE DELETE ON SinhVien
FOR EACH ROW
BEGIN
    DECLARE v_Count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_Count
    FROM DangKyHocPhan
    WHERE MaSV = OLD.MaSV AND TrangThai = 'DaDuyet';

    IF v_Count > 0 THEN
        SIGNAL SQLSTATE '45004'
            SET MESSAGE_TEXT = 'Không thể xóa sinh viên đang có đăng ký học phần!';
    END IF;

    -- Ghi log
    INSERT INTO LogHoatDong (MaNguoiDung, VaiTro, HanhDong, BangTacDong, MaBanGhi, GhiChu)
    VALUES (
        OLD.MaSV, 'Admin', 'XOA_SINH_VIEN',
        'SinhVien', OLD.MaSV,
        CONCAT('[TRIGGER] Xóa sinh viên: ', OLD.HoTen, ' lúc ', NOW())
    );
END$$

DELIMITER ;

-- ============================================================
-- KIỂM TRA TRIGGERS
-- ============================================================
SHOW TRIGGERS FROM QuanLyDKHP;

-- Test Trigger 4: Thử xóa học phần đã có SV đăng ký (phải báo lỗi)
-- DELETE FROM HocPhan WHERE MaHP = 'HP001'; -- Sẽ báo lỗi

-- Test Trigger 2: Đăng ký mới (Trigger sẽ cập nhật sĩ số tự động)
-- INSERT INTO DangKyHocPhan(MaSV, MaHP) VALUES ('SV015', 'HP001');
-- SELECT SiSoHienTai FROM HocPhan WHERE MaHP = 'HP001'; -- Tự tăng

SELECT '6 Triggers đã tạo thành công!' AS ThongBao;
