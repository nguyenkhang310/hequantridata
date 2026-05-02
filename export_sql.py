"""
export_sql.py
Xuat du lieu tu MySQL ra file sql/02_SampleData.sql
Chay sau khi da co du lieu trong DB (sau generate_data.py)
"""
import mysql.connector

db = mysql.connector.connect(
    host='localhost', user='root', password='Nguyenkhang@123', database='QuanLyDKHP'
)
cursor = db.cursor()

lines = []
lines.append("-- ============================================================")
lines.append("-- FILE: 02_SampleData.sql  (AUTO-GENERATED)")
lines.append("-- MUC DICH: Du lieu mau day du - co the chay lai de reset DB")
lines.append("-- DUNG LENH: mysql -u root -p QuanLyDKHP < sql/02_SampleData.sql")
lines.append("-- ============================================================")
lines.append("")
lines.append("USE QuanLyDKHP;")
lines.append("SET FOREIGN_KEY_CHECKS = 0;")
for tbl in ["BangDiem","LogHoatDong","DangKyHocPhan","LichHoc","HocPhan","MonHoc","SinhVien","GiaoVien"]:
    lines.append(f"TRUNCATE TABLE {tbl};")
lines.append("SET FOREIGN_KEY_CHECKS = 1;")
lines.append("")

def escape(v):
    if v is None:
        return "NULL"
    s = str(v).replace("'", "''").replace("\\", "\\\\")
    return f"'{s}'"

def dump_table(table, cols, id_col=None):
    cursor.execute(f"SELECT {','.join(cols)} FROM {table}")
    rows = cursor.fetchall()
    if not rows:
        return
    lines.append(f"-- {table} ({len(rows)} records)")
    chunk = 200
    for i in range(0, len(rows), chunk):
        batch = rows[i:i+chunk]
        vals = ",\n".join("(" + ",".join(escape(c) for c in row) + ")" for row in batch)
        lines.append(f"INSERT INTO {table} ({','.join(cols)}) VALUES\n{vals};")
    lines.append("")
    print(f"  {table}: {len(rows)} records exported")

print("Exporting tables...")

# GiaoVien - export mat khau da hash (khong export ra ngoai SHA2, dung gia tri hash thang)
cursor.execute("SELECT MaGV,HoTen,NgaySinh,GioiTinh,Email,SoDT,KhoaBoMon,HocVi,MatKhau FROM GiaoVien")
rows = cursor.fetchall()
lines.append(f"-- GiaoVien ({len(rows)} records)")
for i in range(0, len(rows), 200):
    batch = rows[i:i+200]
    vals = ",\n".join("(" + ",".join(escape(c) for c in row) + ")" for row in batch)
    lines.append(f"INSERT INTO GiaoVien (MaGV,HoTen,NgaySinh,GioiTinh,Email,SoDT,KhoaBoMon,HocVi,MatKhau) VALUES\n{vals};")
lines.append("")
print(f"  GiaoVien: {len(rows)} records")

# SinhVien
cursor.execute("SELECT MaSV,HoTen,NgaySinh,GioiTinh,DiaChi,Email,SoDT,Lop,KhoaHoc,MatKhau FROM SinhVien")
rows = cursor.fetchall()
lines.append(f"-- SinhVien ({len(rows)} records)")
for i in range(0, len(rows), 200):
    batch = rows[i:i+200]
    vals = ",\n".join("(" + ",".join(escape(c) for c in row) + ")" for row in batch)
    lines.append(f"INSERT INTO SinhVien (MaSV,HoTen,NgaySinh,GioiTinh,DiaChi,Email,SoDT,Lop,KhoaHoc,MatKhau) VALUES\n{vals};")
lines.append("")
print(f"  SinhVien: {len(rows)} records")

dump_table("MonHoc", ["MaMH","TenMH","SoTinChi","SoTietLT","SoTietTH"])
dump_table("HocPhan", ["MaHP","MaMH","MaGV","HocKy","NamHoc","SiSoToiDa","NgayBatDauDK","NgayKetThucDK","TrangThai"])
dump_table("LichHoc", ["MaHP","Thu","TietBD","TietKT","Phong"])

# DangKyHocPhan - bo qua MaDK (auto_increment), de DB tu sinh
cursor.execute("SELECT MaSV,MaHP,NgayDK,TrangThai FROM DangKyHocPhan")
rows = cursor.fetchall()
lines.append(f"-- DangKyHocPhan ({len(rows)} records) - SET FK OFF de bypass trigger")
lines.append("SET FOREIGN_KEY_CHECKS = 0;")
# Phai insert ca MaDK de BangDiem tham chieu dung
cursor.execute("SELECT MaDK,MaSV,MaHP,NgayDK,TrangThai FROM DangKyHocPhan")
rows2 = cursor.fetchall()
for i in range(0, len(rows2), 200):
    batch = rows2[i:i+200]
    vals = ",\n".join("(" + ",".join(escape(c) for c in row) + ")" for row in batch)
    lines.append(f"INSERT INTO DangKyHocPhan (MaDK,MaSV,MaHP,NgayDK,TrangThai) VALUES\n{vals};")
lines.append("SET FOREIGN_KEY_CHECKS = 1;")
lines.append("")
print(f"  DangKyHocPhan: {len(rows2)} records")

# BangDiem - export MaDK thay vi tu tinh
cursor.execute("SELECT MaDK,DiemCC,DiemGiuaKy,DiemCuoiKy FROM BangDiem")
rows = cursor.fetchall()
lines.append(f"-- BangDiem ({len(rows)} records)")
for i in range(0, len(rows), 200):
    batch = rows[i:i+200]
    vals = ",\n".join("(" + ",".join(escape(c) for c in row) + ")" for row in batch)
    lines.append(f"INSERT INTO BangDiem (MaDK,DiemCC,DiemGiuaKy,DiemCuoiKy) VALUES\n{vals};")
lines.append("")
print(f"  BangDiem: {len(rows)} records")

# Ghi ra file
with open("sql/02_SampleData.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

cursor.close()
db.close()
print("\nDa ghi ra sql/02_SampleData.sql thanh cong!")
print("Bay gio chay file SQL nay se ra dung du lieu 500 SV!")
