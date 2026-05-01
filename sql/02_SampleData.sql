-- ============================================================
-- FILE: 02_SampleData.sql
-- MỤC ĐÍCH: Chèn dữ liệu mẫu đầy đủ để test hệ thống
-- Có thể chạy lại nhiều lần mà không bị lỗi duplicate
-- ============================================================

USE QuanLyDKHP;

-- Xóa dữ liệu cũ để tránh lỗi Duplicate Entry khi chạy lại
-- Tắt FK để TRUNCATE không bị chặn bởi ràng buộc
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE BangDiem;
TRUNCATE TABLE LogHoatDong;
TRUNCATE TABLE DangKyHocPhan;
TRUNCATE TABLE LichHoc;
TRUNCATE TABLE HocPhan;
TRUNCATE TABLE MonHoc;
TRUNCATE TABLE SinhVien;
TRUNCATE TABLE GiaoVien;
SET FOREIGN_KEY_CHECKS = 1;
SELECT 'Đã xóa dữ liệu cũ, bắt đầu insert mới...' AS ThongBao;

-- ============================================================
-- DỮ LIỆU: GiaoVien (10 giáo viên)
-- Mật khẩu mặc định: gv123456 (đã hash SHA2-256)
-- ============================================================
INSERT INTO GiaoVien (MaGV, HoTen, NgaySinh, GioiTinh, Email, SoDT, KhoaBoMon, HocVi, MatKhau) VALUES
('GV001', 'Nguyễn Văn An',     '1980-05-12', 'Nam', 'nvan@uth.edu.vn',   '0901111001', 'Công nghệ Thông tin',  'TienSi',   SHA2('gv123456', 256)),
('GV002', 'Trần Thị Bình',     '1975-08-20', 'Nu',  'ttbinh@uth.edu.vn', '0901111002', 'Công nghệ Thông tin',  'TienSi',   SHA2('gv123456', 256)),
('GV003', 'Lê Minh Châu',      '1985-03-15', 'Nam', 'lmchau@uth.edu.vn', '0901111003', 'Toán - Thống kê',      'ThacSi',   SHA2('gv123456', 256)),
('GV004', 'Phạm Thị Duyên',    '1978-11-30', 'Nu',  'ptduyen@uth.edu.vn','0901111004', 'Điện - Điện tử',       'TienSi',   SHA2('gv123456', 256)),
('GV005', 'Hoàng Văn Em',      '1990-07-22', 'Nam', 'hvem@uth.edu.vn',   '0901111005', 'Công nghệ Thông tin',  'ThacSi',   SHA2('gv123456', 256));

-- ============================================================
-- DỮ LIỆU: SinhVien (15 sinh viên)
-- Mật khẩu mặc định: sv123456 (đã hash SHA2-256)
-- ============================================================
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, DiaChi, Email, SoDT, Lop, KhoaHoc, MatKhau) VALUES
('SV001', 'Nguyễn Khang',       '2004-01-15', 'Nam', 'TP.HCM', 'khang@sv.uth.edu.vn',   '0912000001', 'CNTT-K22A', '2022-2026', SHA2('sv123456', 256)),
('SV002', 'Trần Thị Mai',       '2004-03-22', 'Nu',  'Bình Dương', 'mai@sv.uth.edu.vn',  '0912000002', 'CNTT-K22A', '2022-2026', SHA2('sv123456', 256)),
('SV003', 'Lê Văn Phúc',        '2003-07-08', 'Nam', 'Đồng Nai', 'phuc@sv.uth.edu.vn',  '0912000003', 'CNTT-K22B', '2022-2026', SHA2('sv123456', 256)),
('SV004', 'Phạm Ngọc Lan',      '2004-09-17', 'Nu',  'TP.HCM', 'lan@sv.uth.edu.vn',     '0912000004', 'CNTT-K22B', '2022-2026', SHA2('sv123456', 256)),
('SV005', 'Hoàng Văn Tài',      '2003-12-05', 'Nam', 'Vũng Tàu', 'tai@sv.uth.edu.vn',   '0912000005', 'CNTT-K22A', '2022-2026', SHA2('sv123456', 256)),
('SV006', 'Ngô Thị Hương',      '2004-02-28', 'Nu',  'TP.HCM', 'huong@sv.uth.edu.vn',   '0912000006', 'CNTT-K22A', '2022-2026', SHA2('sv123456', 256)),
('SV007', 'Đặng Minh Tuấn',     '2003-06-14', 'Nam', 'Long An', 'tuan@sv.uth.edu.vn',   '0912000007', 'CNTT-K22C', '2022-2026', SHA2('sv123456', 256)),
('SV008', 'Bùi Thị Yến',        '2004-04-10', 'Nu',  'Tiền Giang', 'yen@sv.uth.edu.vn', '0912000008', 'CNTT-K22C', '2022-2026', SHA2('sv123456', 256)),
('SV009', 'Vũ Quốc Hùng',       '2003-11-25', 'Nam', 'TP.HCM', 'hung@sv.uth.edu.vn',   '0912000009', 'CNTT-K22B', '2022-2026', SHA2('sv123456', 256)),
('SV010', 'Đinh Thị Thu',       '2004-08-03', 'Nu',  'Bình Thuận', 'thu@sv.uth.edu.vn', '0912000010', 'CNTT-K22A', '2022-2026', SHA2('sv123456', 256)),
('SV011', 'Lý Văn Đức',         '2003-05-19', 'Nam', 'Cần Thơ', 'duc@sv.uth.edu.vn',   '0912000011', 'CNTT-K22B', '2022-2026', SHA2('sv123456', 256)),
('SV012', 'Phan Thị Ngân',      '2004-07-11', 'Nu',  'Khánh Hòa', 'ngan@sv.uth.edu.vn','0912000012', 'CNTT-K22C', '2022-2026', SHA2('sv123456', 256)),
('SV013', 'Trương Minh Khoa',   '2003-03-30', 'Nam', 'TP.HCM', 'khoa@sv.uth.edu.vn',   '0912000013', 'CNTT-K22A', '2022-2026', SHA2('sv123456', 256)),
('SV014', 'Cao Ngọc Trinh',     '2004-10-20', 'Nu',  'Bình Dương', 'trinh@sv.uth.edu.vn','0912000014','CNTT-K22B', '2022-2026', SHA2('sv123456', 256)),
('SV015', 'Hồ Thanh Long',      '2003-09-08', 'Nam', 'An Giang', 'long@sv.uth.edu.vn',  '0912000015', 'CNTT-K22C', '2022-2026', SHA2('sv123456', 256));

-- ============================================================
-- DỮ LIỆU: MonHoc (10 môn học)
-- ============================================================
INSERT INTO MonHoc (MaMH, TenMH, SoTinChi, SoTietLT, SoTietTH, MoTa) VALUES
('CSDL',    'Cơ sở Dữ liệu',               3, 45, 0,  'Thiết kế và quản lý cơ sở dữ liệu quan hệ'),
('LTHDT',   'Lập trình Hướng đối tượng',   3, 30, 30, 'Lập trình OOP với Java'),
('CTDLGT',  'Cấu trúc Dữ liệu & Giải thuật',3,45, 0,  'Các cấu trúc dữ liệu và thuật toán cơ bản'),
('MMAN',    'Mạng Máy tính',               3, 45, 0,  'Nguyên lý hoạt động của mạng máy tính'),
('HQTCSDL', 'Hệ Quản trị Cơ sở Dữ liệu',  3, 30, 30, 'MySQL, Oracle - quản trị CSDL nâng cao'),
('PTTKHT',  'Phân tích Thiết kế Hệ thống', 3, 45, 0,  'Phân tích yêu cầu và thiết kế hệ thống'),
('KHOLIEU', 'Kho dữ liệu và Khai phá',     3, 45, 0,  'Data Warehouse và Data Mining'),
('ANTT',    'An toàn Thông tin',            3, 45, 0,  'Bảo mật hệ thống thông tin'),
('LTUDM',   'Lập trình Ứng dụng Di động',  3, 30, 30, 'Phát triển app Android/iOS'),
('TOANCB',  'Toán Cao cấp',                4, 60, 0,  'Giải tích - Đại số tuyến tính');

-- ============================================================
-- DỮ LIỆU: HocPhan (12 học phần - HK1 2025-2026)
-- ============================================================
INSERT INTO HocPhan (MaHP, MaMH, MaGV, HocKy, NamHoc, SiSoToiDa, SiSoHienTai, NgayBatDauDK, NgayKetThucDK, TrangThai) VALUES
('HP001', 'CSDL',    'GV001', 1, '2025-2026', 50, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP002', 'CSDL',    'GV002', 1, '2025-2026', 50, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP003', 'LTHDT',   'GV003', 1, '2025-2026', 45, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP004', 'CTDLGT',  'GV001', 1, '2025-2026', 50, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP005', 'MMAN',    'GV004', 1, '2025-2026', 40, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP006', 'HQTCSDL', 'GV002', 1, '2025-2026', 35, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP007', 'PTTKHT',  'GV005', 1, '2025-2026', 50, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP008', 'ANTT',    'GV004', 1, '2025-2026', 40, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP009', 'LTUDM',   'GV005', 1, '2025-2026', 30, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP010', 'TOANCB',  'GV003', 1, '2025-2026', 60, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP011', 'KHOLIEU', 'GV001', 1, '2025-2026', 35, 0, '2025-08-01', '2025-08-31', 'MoDangKy'),
('HP012', 'LTHDT',   'GV005', 1, '2025-2026', 45, 0, '2025-08-01', '2025-08-31', 'MoDangKy');

-- ============================================================
-- DỮ LIỆU: LichHoc (thời khóa biểu)
-- ============================================================
INSERT INTO LichHoc (MaHP, Thu, TietBD, TietKT, Phong) VALUES
('HP001', 'Thu2', 1,  3,  'A101'),
('HP001', 'Thu4', 1,  3,  'A101'),
('HP002', 'Thu3', 4,  6,  'A102'),
('HP002', 'Thu5', 4,  6,  'A102'),
('HP003', 'Thu2', 7,  9,  'B201'),
('HP003', 'Thu4', 7,  9,  'B201'),
('HP004', 'Thu3', 1,  3,  'A103'),
('HP004', 'Thu6', 1,  3,  'A103'),
('HP005', 'Thu5', 7,  9,  'C301'),
('HP005', 'Thu7', 1,  3,  'C301'),
('HP006', 'Thu2', 4,  6,  'B202'),
('HP006', 'Thu4', 4,  6,  'Lab01'),
('HP007', 'Thu3', 7,  9,  'A104'),
('HP007', 'Thu5', 1,  3,  'A104'),
('HP008', 'Thu6', 4,  6,  'C302'),
('HP009', 'Thu7', 4,  6,  'Lab02'),
('HP010', 'Thu2', 10, 12, 'A201'),
('HP010', 'Thu5', 10, 12, 'A201'),
('HP011', 'Thu4', 10, 12, 'B203'),
('HP012', 'Thu6', 7,  9,  'B204');

-- ============================================================
-- DỮ LIỆU: DangKyHocPhan (đăng ký mẫu)
-- Dùng Stored Procedure để đảm bảo trigger hoạt động đúng
-- (Sẽ insert trực tiếp ở đây để tạo dữ liệu ban đầu)
-- ============================================================
-- Tắt trigger tạm thời để insert dữ liệu mẫu không bị lỗi
-- (Trigger sẽ được tạo ở file 05_Triggers.sql)
INSERT INTO DangKyHocPhan (MaSV, MaHP, TrangThai) VALUES
('SV001', 'HP001', 'DaDuyet'),
('SV001', 'HP003', 'DaDuyet'),
('SV001', 'HP005', 'DaDuyet'),
('SV001', 'HP007', 'DaDuyet'),
('SV002', 'HP001', 'DaDuyet'),
('SV002', 'HP004', 'DaDuyet'),
('SV002', 'HP006', 'DaDuyet'),
('SV003', 'HP002', 'DaDuyet'),
('SV003', 'HP005', 'DaDuyet'),
('SV003', 'HP008', 'DaDuyet'),
('SV004', 'HP001', 'DaDuyet'),
('SV004', 'HP003', 'DaDuyet'),
('SV004', 'HP009', 'DaDuyet'),
('SV005', 'HP002', 'DaDuyet'),
('SV005', 'HP004', 'DaDuyet'),
('SV005', 'HP007', 'DaDuyet'),
('SV006', 'HP001', 'DaDuyet'),
('SV006', 'HP006', 'DaDuyet'),
('SV006', 'HP010', 'DaDuyet'),
('SV007', 'HP003', 'DaDuyet'),
('SV007', 'HP005', 'DaDuyet'),
('SV007', 'HP011', 'DaDuyet'),
('SV008', 'HP002', 'DaDuyet'),
('SV008', 'HP007', 'DaDuyet'),
('SV009', 'HP004', 'DaDuyet'),
('SV009', 'HP006', 'DaDuyet'),
('SV010', 'HP001', 'DaDuyet'),
('SV010', 'HP010', 'DaDuyet'),
('SV011', 'HP003', 'DaDuyet'),
('SV011', 'HP008', 'DaDuyet'),
('SV012', 'HP002', 'DaDuyet'),
('SV012', 'HP009', 'DaDuyet'),
('SV013', 'HP001', 'DaDuyet'),
('SV013', 'HP004', 'DaDuyet'),
('SV014', 'HP006', 'DaDuyet'),
('SV015', 'HP007', 'DaDuyet'),
('SV015', 'HP011', 'DaDuyet');

-- Cập nhật sĩ số hiện tại theo dữ liệu đã insert
-- (Tắt safe update mode tạm thời để UPDATE toàn bảng)
SET SQL_SAFE_UPDATES = 0;
UPDATE HocPhan hp
SET SiSoHienTai = (
    SELECT COUNT(*) FROM DangKyHocPhan dk
    WHERE dk.MaHP = hp.MaHP AND dk.TrangThai = 'DaDuyet'
);
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- DỮ LIỆU: BangDiem (điểm cho các sinh viên đã hoàn thành)
-- ============================================================
INSERT INTO BangDiem (MaDK, DiemCC, DiemGiuaKy, DiemCuoiKy) VALUES
(1,  9.5, 8.0, 8.5),  -- SV001 - HP001
(2,  8.0, 7.5, 7.0),  -- SV001 - HP003
(3,  7.0, 6.5, 7.5),  -- SV001 - HP005
(4,  9.0, 8.5, 9.0),  -- SV001 - HP007
(5,  8.5, 7.0, 7.5),  -- SV002 - HP001
(6,  7.5, 8.0, 8.0),  -- SV002 - HP004
(7,  6.0, 5.5, 6.0),  -- SV002 - HP006
(8,  9.0, 9.5, 9.5),  -- SV003 - HP002
(9,  7.0, 7.5, 8.0),  -- SV003 - HP005
(10, 8.0, 6.0, 5.5),  -- SV003 - HP008
(11, 8.5, 8.0, 8.5),  -- SV004 - HP001
(12, 9.5, 9.0, 9.5),  -- SV004 - HP003
(13, 7.5, 8.0, 7.5),  -- SV004 - HP009
(14, 6.5, 7.0, 6.5),  -- SV005 - HP002
(15, 8.0, 7.5, 8.0),  -- SV005 - HP004
(16, 9.0, 9.5, 9.0);  -- SV005 - HP007

SELECT 'Dữ liệu mẫu đã được chèn thành công!' AS ThongBao;
SELECT 'Tổng sinh viên:', COUNT(*) FROM SinhVien;
SELECT 'Tổng giáo viên:', COUNT(*) FROM GiaoVien;
SELECT 'Tổng môn học:', COUNT(*) FROM MonHoc;
SELECT 'Tổng học phần:', COUNT(*) FROM HocPhan;
SELECT 'Tổng đăng ký:', COUNT(*) FROM DangKyHocPhan;
