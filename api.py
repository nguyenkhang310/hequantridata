from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Nguyenkhang@123',
    'database': 'QuanLyDKHP'
}

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

# Map Thu values from DB enum to display string
THU_MAP = {
    'Thu2': 'Thứ 2', 'Thu3': 'Thứ 3', 'Thu4': 'Thứ 4',
    'Thu5': 'Thứ 5', 'Thu6': 'Thứ 6', 'Thu7': 'Thứ 7', 'ChuNhat': 'Chủ nhật'
}

# Helper: get the active/latest academic year from DB
def get_active_year():
    db = get_db()
    c = db.cursor()
    c.execute("SELECT DISTINCT NamHoc FROM HocPhan ORDER BY NamHoc DESC LIMIT 1")
    row = c.fetchone()
    c.close(); db.close()
    return row[0] if row else '2023-2024'

# ============================================================
# AUTH
# ============================================================
@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    uid = data.get('id')
    pwd = data.get('password')
    role = 'SinhVien' if data.get('role') == 'student' else 'GiaoVien'
    db = get_db()
    cursor = db.cursor()
    try:
        result = cursor.callproc('sp_DangNhap', (uid, pwd, role, 0, '', ''))
        ok, name, msg = result[3], result[4], result[5]
        if ok == 1:
            return jsonify({"success": True, "user": {"id": uid, "name": name, "role": data.get('role'), "faculty": "CNTT"}})
        return jsonify({"success": False, "message": msg}), 401
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        cursor.close(); db.close()

# ============================================================
# STUDENT
# ============================================================
@app.route('/api/student/dashboard/<uid>', methods=['GET'])
def student_dashboard(uid):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.callproc('sp_XemBangDiem', (uid,))
        results = list(cursor.stored_results())
        gpa, standing, credits, registered = 0, 'Chưa có', 0, 0
        if len(results) > 0:
            registered = len(results[0].fetchall())
        if len(results) > 1:
            summary = results[1].fetchone()
            if summary:
                gpa = float(summary[0]) if summary[0] else 0
                standing = summary[1] or 'Chưa có'
                credits = int(summary[3]) if summary[3] else 0
        return jsonify({"gpa": gpa, "standing": standing, "credits": credits, "registered": registered})
    except Exception as e:
        return jsonify({"gpa": 0, "standing": "Lỗi", "credits": 0, "registered": 0})
    finally:
        cursor.close(); db.close()

@app.route('/api/student/courses', methods=['GET'])
def get_courses():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        # Get available courses across all terms
        cursor.execute("""
            SELECT hp.MaHP, mh.TenMH, mh.SoTinChi,
                   CONCAT(gv.HoTen) AS TenGiaoVien,
                   hp.SiSoHienTai, hp.SiSoToiDa, hp.TrangThai,
                   hp.HocKy, hp.NamHoc,
                   GROUP_CONCAT(CONCAT(lh.Thu,' T',lh.TietBD,'-',lh.TietKT,' ',lh.Phong) SEPARATOR ' | ') AS LichHoc
            FROM HocPhan hp
            JOIN MonHoc mh ON hp.MaMH = mh.MaMH
            LEFT JOIN GiaoVien gv ON hp.MaGV = gv.MaGV
            LEFT JOIN LichHoc lh ON hp.MaHP = lh.MaHP
            WHERE hp.TrangThai = 'MoDangKy'
            GROUP BY hp.MaHP
            ORDER BY mh.TenMH
        """)
        rows = cursor.fetchall()
        courses = []
        for r in rows:
            # Map Thu in schedule string
            lich = r['LichHoc'] or ''
            for k, v in THU_MAP.items():
                lich = lich.replace(k, v)
            courses.append({
                "code": r['MaHP'],
                "name": r['TenMH'],
                "credits": r['SoTinChi'],
                "teacher": r['TenGiaoVien'] or 'Chưa phân công',
                "enrolled": r['SiSoHienTai'],
                "capacity": r['SiSoToiDa'],
                "schedule": lich,
                "semester": f"HK{r['HocKy']} {r['NamHoc']}",
                "status": "open" if r['TrangThai'] == 'MoDangKy' else "full"
            })
        return jsonify(courses)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close(); db.close()

@app.route('/api/student/register', methods=['POST'])
def register_course():
    data = request.json
    uid = data.get('studentId')
    course_id = data.get('courseId')
    db = get_db()
    cursor = db.cursor()
    try:
        result = cursor.callproc('sp_DangKyHocPhan', (uid, course_id, 0, ''))
        ok, msg = result[2], result[3]
        if ok == 1:
            db.commit()
            return jsonify({"success": True, "message": msg})
        return jsonify({"success": False, "message": msg}), 400
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        cursor.close(); db.close()

@app.route('/api/student/schedule/<uid>', methods=['GET'])
def student_schedule(uid):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        # Query directly without worrying about academic year param
        cursor.execute("""
            SELECT lh.Thu, lh.TietBD, lh.TietKT, lh.Phong,
                   mh.TenMH, hp.MaHP, gv.HoTen AS TenGiaoVien,
                   hp.HocKy, hp.NamHoc
            FROM DangKyHocPhan dk
            JOIN HocPhan hp ON dk.MaHP = hp.MaHP
            JOIN MonHoc mh ON hp.MaMH = mh.MaMH
            LEFT JOIN GiaoVien gv ON hp.MaGV = gv.MaGV
            LEFT JOIN LichHoc lh ON hp.MaHP = lh.MaHP
            WHERE dk.MaSV = %s AND dk.TrangThai = 'DaDuyet'
            ORDER BY lh.Thu, lh.TietBD
        """, (uid,))
        rows = cursor.fetchall()
        schedule = []
        for r in rows:
            if r['Thu']:
                schedule.append({
                    "day": THU_MAP.get(r['Thu'], r['Thu']),
                    "period": f"Tiết {r['TietBD']}-{r['TietKT']}",
                    "room": r['Phong'],
                    "course": r['TenMH'],
                    "teacher": r['TenGiaoVien'] or '',
                    "semester": f"HK{r['HocKy']} {r['NamHoc']}"
                })
        return jsonify(schedule)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close(); db.close()

@app.route('/api/student/grades/<uid>', methods=['GET'])
def student_grades(uid):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT hp.HocKy, hp.NamHoc, mh.MaMH, mh.TenMH, mh.SoTinChi,
                   bd.DiemCC, bd.DiemGiuaKy, bd.DiemCuoiKy, bd.DiemTB, bd.XepLoai
            FROM BangDiem bd
            JOIN DangKyHocPhan dk ON bd.MaDK = dk.MaDK
            JOIN HocPhan hp ON dk.MaHP = hp.MaHP
            JOIN MonHoc mh ON hp.MaMH = mh.MaMH
            WHERE dk.MaSV = %s
            ORDER BY hp.NamHoc, hp.HocKy
        """, (uid,))
        rows = cursor.fetchall()
        grades = []
        for r in rows:
            grades.append({
                "semester": f"HK{r['HocKy']} {r['NamHoc']}",
                "code": r['MaMH'],
                "name": r['TenMH'],
                "credits": r['SoTinChi'],
                "cc": float(r['DiemCC']) if r['DiemCC'] else 0,
                "gk": float(r['DiemGiuaKy']) if r['DiemGiuaKy'] else 0,
                "ck": float(r['DiemCuoiKy']) if r['DiemCuoiKy'] else 0,
                "total": float(r['DiemTB']) if r['DiemTB'] else 0,
                "grade": r['XepLoai'] or 'F'
            })
        return jsonify(grades)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close(); db.close()

# ============================================================
# TEACHER
# ============================================================
@app.route('/api/teacher/classes/<uid>', methods=['GET'])
def get_teacher_classes(uid):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        # Get all courses this teacher teaches
        cursor.execute("""
            SELECT hp.MaHP, mh.TenMH, hp.HocKy, hp.NamHoc
            FROM HocPhan hp
            JOIN MonHoc mh ON hp.MaMH = mh.MaMH
            WHERE hp.MaGV = %s
        """, (uid,))
        classes_raw = cursor.fetchall()
        classes = []
        for cls in classes_raw:
            mahp = cls['MaHP']
            # Get students registered for this class
            cursor.execute("""
                SELECT sv.MaSV, sv.HoTen, sv.Lop,
                       bd.DiemCC, bd.DiemGiuaKy, bd.DiemCuoiKy
                FROM DangKyHocPhan dk
                JOIN SinhVien sv ON dk.MaSV = sv.MaSV
                LEFT JOIN BangDiem bd ON bd.MaDK = dk.MaDK
                WHERE dk.MaHP = %s AND dk.TrangThai = 'DaDuyet'
            """, (mahp,))
            students_raw = cursor.fetchall()
            students = [{
                "id": s['MaSV'],
                "name": s['HoTen'],
                "className": s['Lop'],
                "cc": float(s['DiemCC']) if s['DiemCC'] else 0,
                "gk": float(s['DiemGiuaKy']) if s['DiemGiuaKy'] else 0,
                "ck": float(s['DiemCuoiKy']) if s['DiemCuoiKy'] else 0,
            } for s in students_raw]
            classes.append({
                "id": mahp,
                "name": f"{cls['TenMH']} - HK{cls['HocKy']} {cls['NamHoc']}",
                "students": students
            })
        return jsonify(classes)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close(); db.close()

@app.route('/api/teacher/grade', methods=['POST'])
def update_grade():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        # Find MaDK from studentId and courseId
        cursor.execute(
            "SELECT MaDK FROM DangKyHocPhan WHERE MaSV=%s AND MaHP=%s",
            (data['studentId'], data['courseId'])
        )
        row = cursor.fetchone()
        if not row:
            return jsonify({"success": False, "message": "Không tìm thấy đăng ký"})
        madk = row[0]
        cursor.execute(
            "UPDATE BangDiem SET DiemCC=%s, DiemGiuaKy=%s, DiemCuoiKy=%s WHERE MaDK=%s",
            (data['cc'], data['gk'], data['ck'], madk)
        )
        db.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        cursor.close(); db.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)
