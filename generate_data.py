import mysql.connector
import random
import datetime

db = mysql.connector.connect(
    host='localhost', user='root', password='Nguyenkhang@123', database='QuanLyDKHP'
)
cursor = db.cursor()

# Collect SQL lines to write to file
sql_lines = []
sql_lines.append("-- ============================================================")
sql_lines.append("-- FILE: 02_SampleData.sql")
sql_lines.append("-- MUC DICH: Du lieu mau 500 sinh vien (tu dong tao boi generate_data.py)")
sql_lines.append("-- ============================================================")
sql_lines.append("")
sql_lines.append("USE QuanLyDKHP;")
sql_lines.append("")
sql_lines.append("SET FOREIGN_KEY_CHECKS = 0;")
sql_lines.append("TRUNCATE TABLE BangDiem;")
sql_lines.append("TRUNCATE TABLE LogHoatDong;")
sql_lines.append("TRUNCATE TABLE DangKyHocPhan;")
sql_lines.append("TRUNCATE TABLE LichHoc;")
sql_lines.append("TRUNCATE TABLE HocPhan;")
sql_lines.append("TRUNCATE TABLE MonHoc;")
sql_lines.append("TRUNCATE TABLE SinhVien;")
sql_lines.append("TRUNCATE TABLE GiaoVien;")
sql_lines.append("SET FOREIGN_KEY_CHECKS = 1;")
sql_lines.append("")

# === RESET DATA ===
cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
for tbl in ["BangDiem","LogHoatDong","DangKyHocPhan","LichHoc","HocPhan","MonHoc","SinhVien","GiaoVien"]:
    cursor.execute(f"TRUNCATE TABLE {tbl}")
cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
db.commit()

# === DATA POOLS ===
ho_list = ["Nguyen","Tran","Le","Pham","Hoang","Huynh","Phan","Vu","Vo","Dang","Bui","Do","Ho","Ngo","Duong","Ly"]
dem_nam = ["Van","Huu","Duc","Minh","Quoc","Thanh","Dinh","Ngoc","Tuan","Hoang"]
dem_nu  = ["Thi","Ngoc","Thu","Phuong","Bich","Hong","Kim","Thanh","Thao"]
ten_nam = ["An","Anh","Bao","Cuong","Dung","Dat","Hai","Hung","Huy","Khoa","Kien","Khanh","Long","Minh","Nam","Phong","Phuc","Quang","Son","Tai","Tam","Thai","Thang","Thinh","Tri","Tuan","Viet"]
ten_nu  = ["An","Anh","Chau","Chi","Diep","Duyen","Ha","Han","Hoa","Huong","Huyen","Lan","Linh","Ly","Mai","Nga","Ngan","Nhi","Nhung","Oanh","Quyen","Tam","Thao","Thi","Thu","Thuy","Tien","Trang","Tram","Uyen","Van","Yen"]
dia_chi = ["TP.HCM","Binh Duong","Dong Nai","Vung Tau","Long An","Tien Giang","Ben Tre","Can Tho","Tay Ninh","Binh Phuoc","Dong Thap","Vinh Long","An Giang","Kien Giang","Ca Mau"]
khoa_list = ["CNTT","KT","CK","DIEN","XD"]
lop_suffix = ["K22A","K22B","K22C","K23A","K23B","K21A","K21B"]
thu_map = ["Thu2","Thu3","Thu4","Thu5","Thu6","Thu7"]

def gen_name(male):
    ho = random.choice(ho_list)
    if male:
        return f"{ho} {random.choice(dem_nam)} {random.choice(ten_nam)}"
    return f"{ho} {random.choice(dem_nu)} {random.choice(ten_nu)}"

# === GIAO VIEN (20) ===
print("Inserting GiaoVien...")
for i in range(1, 21):
    magv = f"GV{i:03d}"
    male = random.choice([True, False])
    ht   = gen_name(male)
    ns   = datetime.date(random.randint(1970,1990), random.randint(1,12), random.randint(1,28))
    gt   = "Nam" if male else "Nu"
    email = f"gv{i:03d}@uth.edu.vn"
    sdt  = f"0901{random.randint(100000,999999)}"
    khoa = random.choice(["Cong nghe Thong tin","Co khi","Kinh te","Dien - Dien tu","Xay dung"])
    hocvi= random.choice(["ThacSi","TienSi","GiaoSu"])
    cursor.execute(
        "INSERT INTO GiaoVien(MaGV,HoTen,NgaySinh,GioiTinh,Email,SoDT,KhoaBoMon,HocVi,MatKhau) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,SHA2('gv123456',256))",
        (magv, ht, ns, gt, email, sdt, khoa, hocvi)
    )
db.commit()

# === SINH VIEN (500) ===
print("Inserting SinhVien (500)...")
sv_ids = []
for i in range(1, 501):
    masv = f"SV{i:03d}"
    sv_ids.append(masv)
    male = random.choice([True, False])
    ht   = gen_name(male)
    ns   = datetime.date(random.randint(2001,2005), random.randint(1,12), random.randint(1,28))
    gt   = "Nam" if male else "Nu"
    dc   = random.choice(dia_chi)
    email= f"sv{i:03d}@sv.uth.edu.vn"
    sdt  = f"0912{random.randint(100000,999999)}"
    lop  = f"{random.choice(khoa_list)}-{random.choice(lop_suffix)}"
    cursor.execute(
        "INSERT INTO SinhVien(MaSV,HoTen,NgaySinh,GioiTinh,DiaChi,Email,SoDT,Lop,KhoaHoc,MatKhau) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,'2022-2026',SHA2('sv123456',256))",
        (masv, ht, ns, gt, dc, email, sdt, lop)
    )
db.commit()

# === MON HOC (20) ===
print("Inserting MonHoc...")
mon_data = [
    ("MH001","Toan Cao Cap A1",3,45,0),("MH002","Vat ly Dai Cuong",3,30,15),
    ("MH003","Nhap mon Lap trinh",3,30,15),("MH004","Ky thuat Lap trinh",3,30,15),
    ("MH005","Cau truc Du lieu & Giai thuat",4,45,15),("MH006","Co so Du lieu",3,30,15),
    ("MH007","Mang May tinh",3,30,15),("MH008","Lap trinh Huong doi tuong",3,30,15),
    ("MH009","He Dieu hanh",3,30,15),("MH010","Phan tich Thiet ke He thong",3,30,15),
    ("MH011","Tri tue Nhan tao",3,30,15),("MH012","Lap trinh Web",3,15,30),
    ("MH013","Lap trinh Di dong",3,15,30),("MH014","An toan Thong tin",3,30,15),
    ("MH015","Kinh te Chinh tri",2,30,0),("MH016","Triet hoc Mac-Lenin",3,45,0),
    ("MH017","Phap luat Dai cuong",2,30,0),("MH018","Tieng Anh 1",3,30,15),
    ("MH019","Tieng Anh 2",3,30,15),("MH020","Tieng Anh 3",3,30,15),
]
for m in mon_data:
    cursor.execute(
        "INSERT INTO MonHoc(MaMH,TenMH,SoTinChi,SoTietLT,SoTietTH) VALUES(%s,%s,%s,%s,%s)",
        m
    )
db.commit()

# === HOC PHAN (50) ===
print("Inserting HocPhan (50)...")
hp_ids = []
for i in range(1, 51):
    mahp = f"HP{i:03d}"
    hp_ids.append(mahp)
    mamh = f"MH{random.randint(1,20):03d}"
    magv = f"GV{random.randint(1,20):03d}"
    hocky = random.choice([1,2,3])
    namhoc = random.choice(["2022-2023","2023-2024","2024-2025"])
    siso = 600  # Du lon de chua 500 SV
    bd = datetime.date(2023, 7, 1)
    kt = datetime.date(2023, 8, 15)
    cursor.execute(
        "INSERT INTO HocPhan(MaHP,MaMH,MaGV,HocKy,NamHoc,SiSoToiDa,NgayBatDauDK,NgayKetThucDK,TrangThai) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,'MoDangKy')",
        (mahp, mamh, magv, hocky, namhoc, siso, bd, kt)
    )
db.commit()

# === LICH HOC ===
print("Inserting LichHoc...")
for hp in hp_ids:
    thu = random.choice(thu_map)
    tiet_bd = random.choice([1, 4, 7, 10])
    tiet_kt = tiet_bd + 2
    phong = f"A{random.randint(1,5)}.{random.randint(1,9):02d}"
    cursor.execute(
        "INSERT INTO LichHoc(MaHP,Thu,TietBD,TietKT,Phong) VALUES(%s,%s,%s,%s,%s)",
        (hp, thu, tiet_bd, tiet_kt, phong)
    )
db.commit()

# Load lich hoc cua tung HP vao dict de check trung
print("Loading LichHoc to check conflicts...")
cursor.execute("SELECT MaHP, Thu, TietBD, TietKT FROM LichHoc")
lich_hp = {}  # MaHP -> (Thu, TietBD, TietKT)
for row in cursor.fetchall():
    lich_hp[row[0]] = (row[1], row[2], row[3])

# === DANG KY HOC PHAN (moi SV dky 4-7 mon, khong trung lich) ===
print("Inserting DangKyHocPhan...")
dk_records = []  # (MaDK, MaSV, MaHP)
for sv in sv_ids:
    so_mon = random.randint(4, 7)
    random.shuffle(hp_ids)
    used_slots = set()  # set of (Thu, range of tiet)
    registered = []
    for hp in hp_ids:
        if len(registered) >= so_mon:
            break
        if hp not in lich_hp:
            continue
        thu, tiet_bd, tiet_kt = lich_hp[hp]
        slot = (thu, tiet_bd, tiet_kt)
        if slot in used_slots:
            continue
        # Check no overlap
        conflict = False
        for (uthu, ubd, ukt) in used_slots:
            if uthu == thu and not (tiet_kt < ubd or tiet_bd > ukt):
                conflict = True
                break
        if conflict:
            continue
        used_slots.add(slot)
        registered.append(hp)
        ngay = datetime.datetime(2023, random.randint(7,8), random.randint(1,28), random.randint(8,20), 0, 0)
        cursor.execute(
            "INSERT INTO DangKyHocPhan(MaSV,MaHP,NgayDK,TrangThai) VALUES(%s,%s,%s,'DaDuyet')",
            (sv, hp, ngay)
        )
        dk_records.append((cursor.lastrowid, sv, hp))
db.commit()
print(f"  -> {len(dk_records)} records DangKyHocPhan")

# === BANG DIEM ===
print("Inserting BangDiem...")
for (madk, masv, mahp) in dk_records:
    cc = round(random.uniform(6.5, 10.0), 2)
    gk = round(random.uniform(5.0, 10.0), 2)
    ck = round(random.uniform(4.0, 10.0), 2)
    cursor.execute(
        "INSERT INTO BangDiem(MaDK,DiemCC,DiemGiuaKy,DiemCuoiKy) VALUES(%s,%s,%s,%s)",
        (madk, cc, gk, ck)
    )
db.commit()

# === FINAL COUNT ===
print("\n=== KET QUA ===")
for tbl in ["SinhVien","GiaoVien","MonHoc","HocPhan","LichHoc","DangKyHocPhan","BangDiem"]:
    cursor.execute(f"SELECT COUNT(*) FROM {tbl}")
    print(f"  {tbl:20s}: {cursor.fetchone()[0]:,} records")

cursor.close()
db.close()
print("\nDone! Database da co du lieu KHUNG!")
