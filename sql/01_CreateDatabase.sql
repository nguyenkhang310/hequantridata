-- ============================================================
-- HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU
-- ĐỀ TÀI: QUẢN LÝ SINH VIÊN ĐĂNG KÝ HỌC PHẦN TÍN CHỈ
-- Trường: Đại học Giao Thông Vận Tải TP.HCM (UTH)
-- Phiên bản: 1.0
-- Ngày tạo: 2026-05-01
-- ============================================================

-- Xóa và tạo lại database
DROP DATABASE IF EXISTS QuanLyDKHP;
CREATE DATABASE QuanLyDKHP 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE QuanLyDKHP;

-- ============================================================
-- BẢNG 1: GiaoVien
-- Lưu thông tin giáo viên / giảng viên
-- ============================================================
CREATE TABLE GiaoVien (
    MaGV        VARCHAR(10)     NOT NULL,
    HoTen       VARCHAR(100)    NOT NULL,
    NgaySinh    DATE,
    GioiTinh    ENUM('Nam','Nu','Khac')          DEFAULT 'Nam',
    Email       VARCHAR(100)    UNIQUE,
    SoDT        VARCHAR(15),
    KhoaBoMon   VARCHAR(100),
    HocVi       VARCHAR(50)                     DEFAULT 'ThacSi',
    MatKhau     VARCHAR(255)    NOT NULL,
    NgayTao     DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_GiaoVien PRIMARY KEY (MaGV)
) ENGINE=InnoDB COMMENT='Bảng lưu thông tin giáo viên';

-- ============================================================
-- BẢNG 2: SinhVien
-- Lưu thông tin sinh viên
-- ============================================================
CREATE TABLE SinhVien (
    MaSV        VARCHAR(10)     NOT NULL,
    HoTen       VARCHAR(100)    NOT NULL,
    NgaySinh    DATE,
    GioiTinh    ENUM('Nam','Nu','Khac')          DEFAULT 'Nam',
    DiaChi      VARCHAR(200),
    Email       VARCHAR(100)    UNIQUE,
    SoDT        VARCHAR(15),
    Lop         VARCHAR(20),
    KhoaHoc     VARCHAR(20),
    MatKhau     VARCHAR(255)    NOT NULL,
    NgayTao     DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_SinhVien PRIMARY KEY (MaSV)
) ENGINE=InnoDB COMMENT='Bảng lưu thông tin sinh viên';

-- ============================================================
-- BẢNG 3: MonHoc
-- Lưu danh sách môn học trong chương trình đào tạo
-- ============================================================
CREATE TABLE MonHoc (
    MaMH        VARCHAR(10)     NOT NULL,
    TenMH       VARCHAR(100)    NOT NULL,
    SoTinChi    INT             NOT NULL,
    SoTietLT    INT             NOT NULL DEFAULT 30,
    SoTietTH    INT             NOT NULL DEFAULT 0,
    MoTa        TEXT,
    CONSTRAINT PK_MonHoc PRIMARY KEY (MaMH),
    CONSTRAINT CHK_TinChi CHECK (SoTinChi >= 1 AND SoTinChi <= 10)
) ENGINE=InnoDB COMMENT='Bảng danh mục môn học';

-- ============================================================
-- BẢNG 4: HocPhan
-- Mỗi học phần là 1 lớp mở của môn học trong học kỳ cụ thể
-- ============================================================
CREATE TABLE HocPhan (
    MaHP            VARCHAR(10)     NOT NULL,
    MaMH            VARCHAR(10)     NOT NULL,
    MaGV            VARCHAR(10),
    HocKy           TINYINT         NOT NULL,
    NamHoc          VARCHAR(9)      NOT NULL,
    SiSoToiDa       INT             NOT NULL DEFAULT 50,
    SiSoHienTai     INT             NOT NULL DEFAULT 0,
    NgayBatDauDK    DATE,
    NgayKetThucDK   DATE,
    TrangThai       ENUM('MoDangKy','DongDangKy','DangHoc','KetThuc') DEFAULT 'MoDangKy',
    CONSTRAINT PK_HocPhan       PRIMARY KEY (MaHP),
    CONSTRAINT FK_HP_MonHoc     FOREIGN KEY (MaMH) REFERENCES MonHoc(MaMH)
                                    ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT FK_HP_GiaoVien   FOREIGN KEY (MaGV) REFERENCES GiaoVien(MaGV)
                                    ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT CHK_SiSo         CHECK (SiSoHienTai <= SiSoToiDa AND SiSoHienTai >= 0),
    CONSTRAINT CHK_HocKy        CHECK (HocKy IN (1, 2, 3))
) ENGINE=InnoDB COMMENT='Bảng học phần (lớp học mỗi học kỳ)';

-- ============================================================
-- BẢNG 5: LichHoc
-- Thời khóa biểu chi tiết của từng học phần
-- ============================================================
CREATE TABLE LichHoc (
    MaLich      INT             NOT NULL AUTO_INCREMENT,
    MaHP        VARCHAR(10)     NOT NULL,
    Thu         ENUM('Thu2','Thu3','Thu4','Thu5','Thu6','Thu7','ChuNhat') NOT NULL,
    TietBD      TINYINT         NOT NULL,
    TietKT      TINYINT         NOT NULL,
    Phong       VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_LichHoc       PRIMARY KEY (MaLich),
    CONSTRAINT FK_Lich_HocPhan  FOREIGN KEY (MaHP) REFERENCES HocPhan(MaHP)
                                    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CHK_Tiet         CHECK (TietBD >= 1 AND TietKT <= 15 AND TietBD < TietKT)
) ENGINE=InnoDB COMMENT='Bảng thời khóa biểu học phần';

-- ============================================================
-- BẢNG 6: DangKyHocPhan
-- Lưu thông tin sinh viên đăng ký học phần nào
-- ============================================================
CREATE TABLE DangKyHocPhan (
    MaDK        INT             NOT NULL AUTO_INCREMENT,
    MaSV        VARCHAR(10)     NOT NULL,
    MaHP        VARCHAR(10)     NOT NULL,
    NgayDK      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    TrangThai   ENUM('DaDuyet','HuyBo','HoanThanh') DEFAULT 'DaDuyet',
    CONSTRAINT PK_DangKy            PRIMARY KEY (MaDK),
    CONSTRAINT FK_DK_SinhVien       FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV)
                                        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT FK_DK_HocPhan        FOREIGN KEY (MaHP) REFERENCES HocPhan(MaHP)
                                        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT UQ_DangKy            UNIQUE (MaSV, MaHP)
) ENGINE=InnoDB COMMENT='Bảng đăng ký học phần của sinh viên';

-- ============================================================
-- BẢNG 7: BangDiem
-- Lưu điểm của sinh viên trong từng học phần đã đăng ký
-- ============================================================
CREATE TABLE BangDiem (
    MaBD        INT             NOT NULL AUTO_INCREMENT,
    MaDK        INT             NOT NULL,
    DiemCC      DECIMAL(4,2)    NOT NULL DEFAULT 0.00,
    DiemGiuaKy  DECIMAL(4,2)    NOT NULL DEFAULT 0.00,
    DiemCuoiKy  DECIMAL(4,2)    NOT NULL DEFAULT 0.00,
    DiemTB      DECIMAL(4,2)    GENERATED ALWAYS AS 
                    (ROUND(DiemCC * 0.10 + DiemGiuaKy * 0.30 + DiemCuoiKy * 0.60, 2)) STORED,
    XepLoai     VARCHAR(2)      GENERATED ALWAYS AS (
                    CASE 
                        WHEN (DiemCC * 0.10 + DiemGiuaKy * 0.30 + DiemCuoiKy * 0.60) >= 8.5 THEN 'A'
                        WHEN (DiemCC * 0.10 + DiemGiuaKy * 0.30 + DiemCuoiKy * 0.60) >= 7.0 THEN 'B'
                        WHEN (DiemCC * 0.10 + DiemGiuaKy * 0.30 + DiemCuoiKy * 0.60) >= 5.5 THEN 'C'
                        WHEN (DiemCC * 0.10 + DiemGiuaKy * 0.30 + DiemCuoiKy * 0.60) >= 4.0 THEN 'D'
                        ELSE 'F'
                    END) STORED,
    NgayCapNhat DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    GhiChu      VARCHAR(200),
    CONSTRAINT PK_BangDiem      PRIMARY KEY (MaBD),
    CONSTRAINT FK_BD_DangKy     FOREIGN KEY (MaDK) REFERENCES DangKyHocPhan(MaDK)
                                    ON DELETE CASCADE,
    CONSTRAINT UQ_BangDiem      UNIQUE (MaDK),
    CONSTRAINT CHK_DiemCC       CHECK (DiemCC BETWEEN 0 AND 10),
    CONSTRAINT CHK_DiemGK       CHECK (DiemGiuaKy BETWEEN 0 AND 10),
    CONSTRAINT CHK_DiemCK       CHECK (DiemCuoiKy BETWEEN 0 AND 10)
) ENGINE=InnoDB COMMENT='Bảng điểm sinh viên theo từng học phần';

-- ============================================================
-- BẢNG 8: LogHoatDong
-- Ghi lại mọi hành động của người dùng (audit trail)
-- ============================================================
CREATE TABLE LogHoatDong (
    MaLog       INT             NOT NULL AUTO_INCREMENT,
    MaNguoiDung VARCHAR(10),
    VaiTro      ENUM('SinhVien','GiaoVien','Admin') DEFAULT 'SinhVien',
    HanhDong    VARCHAR(100)    NOT NULL,
    BangTacDong VARCHAR(50),
    MaBanGhi    VARCHAR(50),
    ThoiGian    DATETIME        DEFAULT CURRENT_TIMESTAMP,
    GhiChu      TEXT,
    CONSTRAINT PK_Log PRIMARY KEY (MaLog)
) ENGINE=InnoDB COMMENT='Bảng ghi log hoạt động hệ thống';

-- ============================================================
-- HIỂN THỊ CẤU TRÚC ĐÃ TẠO
-- ============================================================
SHOW TABLES;
SELECT 'Database QuanLyDKHP tạo thành công!' AS ThongBao;
