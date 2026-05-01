-- ============================================================
-- FILE: 06_Views.sql
-- MỤC ĐÍCH: Góc nhìn tổng hợp sẵn sàng truy vấn nhanh
-- ============================================================

USE QuanLyDKHP;

-- ============================================================
-- VIEW 1: vw_BangDiemTongHop
-- Bảng điểm đầy đủ của tất cả sinh viên
-- ============================================================
DROP VIEW IF EXISTS vw_BangDiemTongHop;
CREATE VIEW vw_BangDiemTongHop AS
SELECT
    sv.MaSV,
    sv.HoTen           AS TenSinhVien,
    sv.Lop,
    hp.HocKy,
    hp.NamHoc,
    mh.MaMH,
    mh.TenMH,
    mh.SoTinChi,
    gv.HoTen           AS TenGiaoVien,
    bd.DiemCC,
    bd.DiemGiuaKy,
    bd.DiemCuoiKy,
    bd.DiemTB,
    bd.XepLoai,
    dk.TrangThai       AS TrangThaiDK
FROM DangKyHocPhan dk
JOIN SinhVien   sv ON dk.MaSV = sv.MaSV
JOIN HocPhan    hp ON dk.MaHP = hp.MaHP
JOIN MonHoc     mh ON hp.MaMH = mh.MaMH
LEFT JOIN GiaoVien gv ON hp.MaGV = gv.MaGV
LEFT JOIN BangDiem bd ON dk.MaDK = bd.MaDK;

-- ============================================================
-- VIEW 2: vw_LichHocTongHop
-- Thời khóa biểu tổng hợp tất cả sinh viên
-- ============================================================
DROP VIEW IF EXISTS vw_LichHocTongHop;
CREATE VIEW vw_LichHocTongHop AS
SELECT
    sv.MaSV,
    sv.HoTen           AS TenSinhVien,
    sv.Lop,
    hp.HocKy,
    hp.NamHoc,
    mh.TenMH,
    lh.Thu,
    lh.TietBD,
    lh.TietKT,
    lh.Phong,
    gv.HoTen           AS TenGiaoVien
FROM DangKyHocPhan dk
JOIN SinhVien  sv ON dk.MaSV = sv.MaSV
JOIN HocPhan   hp ON dk.MaHP = hp.MaHP
JOIN MonHoc    mh ON hp.MaMH = mh.MaMH
JOIN LichHoc   lh ON hp.MaHP = lh.MaHP
LEFT JOIN GiaoVien gv ON hp.MaGV = gv.MaGV
WHERE dk.TrangThai = 'DaDuyet';

-- ============================================================
-- VIEW 3: vw_ThongKeHocPhan
-- Thống kê sĩ số và tình trạng từng học phần
-- ============================================================
DROP VIEW IF EXISTS vw_ThongKeHocPhan;
CREATE VIEW vw_ThongKeHocPhan AS
SELECT
    hp.MaHP,
    mh.TenMH,
    mh.SoTinChi,
    gv.HoTen                                AS TenGiaoVien,
    hp.HocKy,
    hp.NamHoc,
    hp.SiSoToiDa,
    hp.SiSoHienTai,
    (hp.SiSoToiDa - hp.SiSoHienTai)        AS SoChoConLai,
    ROUND(hp.SiSoHienTai / hp.SiSoToiDa * 100, 1) AS TyLeLap_Pct,
    hp.TrangThai,
    COUNT(bd.MaBD)                          AS SoSVCoDiem,
    ROUND(AVG(bd.DiemTB), 2)               AS DiemTB_Lop
FROM HocPhan hp
JOIN MonHoc mh        ON hp.MaMH = mh.MaMH
LEFT JOIN GiaoVien gv ON hp.MaGV = gv.MaGV
LEFT JOIN DangKyHocPhan dk ON hp.MaHP = dk.MaHP
LEFT JOIN BangDiem  bd ON dk.MaDK = bd.MaDK
GROUP BY hp.MaHP, mh.TenMH, mh.SoTinChi,
         gv.HoTen, hp.HocKy, hp.NamHoc,
         hp.SiSoToiDa, hp.SiSoHienTai, hp.TrangThai;

-- ============================================================
-- VIEW 4: vw_XepHangSinhVien
-- Bảng xếp hạng GPA toàn trường
-- ============================================================
DROP VIEW IF EXISTS vw_XepHangSinhVien;
CREATE VIEW vw_XepHangSinhVien AS
SELECT
    sv.MaSV,
    sv.HoTen,
    sv.Lop,
    sv.KhoaHoc,
    COUNT(bd.MaBD)                              AS TongMonDaHoc,
    SUM(mh.SoTinChi)                            AS TongTinChi,
    ROUND(AVG(bd.DiemTB), 2)                   AS DiemTBTongThe,
    ROUND(AVG(bd.DiemTB) * 4.0 / 10.0, 2)    AS GPA_Thang4,
    CASE
        WHEN AVG(bd.DiemTB) * 4.0 / 10.0 >= 3.60 THEN 'Xuất sắc'
        WHEN AVG(bd.DiemTB) * 4.0 / 10.0 >= 3.20 THEN 'Giỏi'
        WHEN AVG(bd.DiemTB) * 4.0 / 10.0 >= 2.50 THEN 'Khá'
        WHEN AVG(bd.DiemTB) * 4.0 / 10.0 >= 2.00 THEN 'Trung bình'
        ELSE 'Yếu'
    END                                         AS XepLoaiHocLuc
FROM SinhVien sv
LEFT JOIN DangKyHocPhan dk ON sv.MaSV = dk.MaSV AND dk.TrangThai = 'DaDuyet'
LEFT JOIN BangDiem  bd ON dk.MaDK = bd.MaDK
LEFT JOIN HocPhan   hp ON dk.MaHP = hp.MaHP
LEFT JOIN MonHoc    mh ON hp.MaMH = mh.MaMH
GROUP BY sv.MaSV, sv.HoTen, sv.Lop, sv.KhoaHoc;

-- ============================================================
-- VIEW 5: vw_LogHoatDongChiTiet
-- Nhật ký hoạt động có thông tin chi tiết người dùng
-- ============================================================
DROP VIEW IF EXISTS vw_LogHoatDongChiTiet;
CREATE VIEW vw_LogHoatDongChiTiet AS
SELECT
    log.MaLog,
    log.ThoiGian,
    log.VaiTro,
    log.MaNguoiDung,
    COALESCE(sv.HoTen, gv.HoTen, 'Hệ thống') AS TenNguoiDung,
    log.HanhDong,
    log.BangTacDong,
    log.MaBanGhi,
    log.GhiChu
FROM LogHoatDong log
LEFT JOIN SinhVien  sv ON log.MaNguoiDung = sv.MaSV AND log.VaiTro = 'SinhVien'
LEFT JOIN GiaoVien  gv ON log.MaNguoiDung = gv.MaGV AND log.VaiTro = 'GiaoVien'
ORDER BY log.ThoiGian DESC;

-- ============================================================
-- KIỂM TRA VIEWS
-- ============================================================
SELECT '--- VIEW 1: Bảng điểm tổng hợp ---' AS Info;
SELECT * FROM vw_BangDiemTongHop WHERE MaSV = 'SV001';

SELECT '--- VIEW 2: Lịch học tổng hợp ---' AS Info;
SELECT * FROM vw_LichHocTongHop WHERE MaSV = 'SV001' ORDER BY Thu, TietBD;

SELECT '--- VIEW 3: Thống kê học phần ---' AS Info;
SELECT * FROM vw_ThongKeHocPhan;

SELECT '--- VIEW 4: Xếp hạng sinh viên ---' AS Info;
SELECT * FROM vw_XepHangSinhVien ORDER BY GPA_Thang4 DESC;

SELECT '5 Views đã tạo thành công!' AS ThongBao;
