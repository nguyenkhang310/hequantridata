from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import hashlib
import hmac
import json
import os
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

AUTH_SECRET = os.environ.get('UTH_AUTH_SECRET', 'uth-portal-dev-secret')

def _b64encode(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).decode('ascii').rstrip('=')

def _b64decode(raw: str) -> bytes:
    return base64.urlsafe_b64decode(raw + '=' * (-len(raw) % 4))

def create_token(user_id: str, role: str) -> str:
    payload = _b64encode(json.dumps({'id': user_id, 'role': role}, separators=(',', ':')).encode('utf-8'))
    signature = hmac.new(AUTH_SECRET.encode('utf-8'), payload.encode('ascii'), hashlib.sha256).digest()
    return f'{payload}.{_b64encode(signature)}'

def get_auth_user():
    header = request.headers.get('Authorization', '')
    if not header.startswith('Bearer '):
        return None
    token = header.split(' ', 1)[1].strip()
    try:
        payload, signature = token.split('.', 1)
        expected = hmac.new(AUTH_SECRET.encode('utf-8'), payload.encode('ascii'), hashlib.sha256).digest()
        if not hmac.compare_digest(_b64decode(signature), expected):
            return None
        data = json.loads(_b64decode(payload).decode('utf-8'))
        if data.get('role') not in ('student', 'teacher') or not data.get('id'):
            return None
        return data
    except Exception:
        return None

def require_auth(expected_role=None, expected_id=None):
    user = get_auth_user()
    if not user:
        return None, (jsonify({"success": False, "message": "Chưa đăng nhập hoặc phiên không hợp lệ"}), 401)
    if expected_role and user.get('role') != expected_role:
        return None, (jsonify({"success": False, "message": "Không đúng quyền truy cập"}), 403)
    if expected_id and user.get('id') != expected_id:
        return None, (jsonify({"success": False, "message": "Không được truy cập dữ liệu của người dùng khác"}), 403)
    return user, None

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
    uid = (data.get('id') or '').strip().upper()
    pwd = data.get('password')
    frontend_role = data.get('role')
    if frontend_role not in ('student', 'teacher'):
        return jsonify({"success": False, "message": "Vai trò không hợp lệ"}), 400
    role = 'SinhVien' if frontend_role == 'student' else 'GiaoVien'
    db = get_db()
    cursor = db.cursor()
    try:
        result = cursor.callproc('sp_DangNhap', (uid, pwd, role, 0, '', ''))
        ok, name, msg = result[3], result[4], result[5]
        if ok == 1:
            token = create_token(uid, frontend_role)
            return jsonify({"success": True, "user": {"id": uid, "name": name, "role": frontend_role, "faculty": "CNTT", "token": token}})
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
    _, auth_error = require_auth('student', uid)
    if auth_error:
        return auth_error
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.callproc('sp_XemBangDiem', (uid,))
        results = list(cursor.stored_results())
        gpa, standing, credits, registered = 0, 'Chưa có', 0, 0

        # Consume result set 0 (chi tiết bảng điểm) — bắt buộc trước khi đọc rs tiếp theo
        if len(results) > 0:
            results[0].fetchall()

        # Chỉ đếm đăng ký DaDuyet (không tính HuyBo)
        cursor2 = db.cursor()
        cursor2.execute(
            "SELECT COUNT(*) FROM DangKyHocPhan WHERE MaSV=%s AND TrangThai='DaDuyet'",
            (uid,)
        )
        r = cursor2.fetchone()
        registered = r[0] if r else 0
        cursor2.close()

        # Lấy GPA từ result set 1
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
    _, auth_error = require_auth('student')
    if auth_error:
        return auth_error
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
              AND (hp.NgayBatDauDK IS NULL OR CURDATE() >= hp.NgayBatDauDK)
              AND (hp.NgayKetThucDK IS NULL OR CURDATE() <= hp.NgayKetThucDK)
            GROUP BY hp.MaHP, mh.TenMH, mh.SoTinChi, gv.HoTen, hp.SiSoHienTai,
                     hp.SiSoToiDa, hp.TrangThai, hp.HocKy, hp.NamHoc
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
                "status": "full" if r['SiSoHienTai'] >= r['SiSoToiDa'] else "open"
            })
        return jsonify(courses)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close(); db.close()

@app.route('/api/student/register', methods=['POST'])
def register_course():
    user, auth_error = require_auth('student')
    if auth_error:
        return auth_error
    data = request.json
    uid = user['id']
    course_id = (data.get('courseId') or '').strip().upper()
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

@app.route('/api/student/unregister', methods=['POST'])
def unregister_course():
    user, auth_error = require_auth('student')
    if auth_error:
        return auth_error
    data = request.json
    uid = user['id']
    course_id = (data.get('courseId') or '').strip().upper()
    db = get_db()
    cursor = db.cursor()
    try:
        result = cursor.callproc('sp_HuyDangKyHocPhan', (uid, course_id, 0, ''))
        ok, msg = result[2], result[3]
        if ok == 1:
            db.commit()
            return jsonify({"success": True, "message": msg})
        return jsonify({"success": False, "message": msg}), 400
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        cursor.close(); db.close()

@app.route('/api/student/my-courses/<uid>', methods=['GET'])
def get_my_courses(uid):
    """Trả về danh sách mã học phần sinh viên đã đăng ký (DaDuyet)"""
    _, auth_error = require_auth('student', uid)
    if auth_error:
        return auth_error
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute(
            "SELECT MaHP FROM DangKyHocPhan WHERE MaSV=%s AND TrangThai='DaDuyet'",
            (uid,)
        )
        rows = cursor.fetchall()
        return jsonify([r[0] for r in rows])
    except Exception as e:
        return jsonify([])
    finally:
        cursor.close(); db.close()

@app.route('/api/student/schedule/<uid>', methods=['GET'])
def student_schedule(uid):
    _, auth_error = require_auth('student', uid)
    if auth_error:
        return auth_error
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
    _, auth_error = require_auth('student', uid)
    if auth_error:
        return auth_error
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
    _, auth_error = require_auth('teacher', uid)
    if auth_error:
        return auth_error
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
    user, auth_error = require_auth('teacher')
    if auth_error:
        return auth_error
    data = request.json
    student_id = (data.get('studentId') or '').strip().upper()
    course_id = (data.get('courseId') or '').strip().upper()
    db = get_db()
    cursor = db.cursor()
    try:
        # Find MaDK from studentId and courseId
        cursor.execute(
            "SELECT MaDK FROM DangKyHocPhan WHERE MaSV=%s AND MaHP=%s AND TrangThai='DaDuyet'",
            (student_id, course_id)
        )
        row = cursor.fetchone()
        if not row:
            return jsonify({"success": False, "message": "Không tìm thấy đăng ký hợp lệ"}), 404
        madk = row[0]
        result = cursor.callproc(
            'sp_CapNhatDiem',
            (user['id'], madk, data['cc'], data['gk'], data['ck'], 0, '')
        )
        ok, msg = result[5], result[6]
        if ok == 1:
            db.commit()
            return jsonify({"success": True, "message": msg})
        db.rollback()
        return jsonify({"success": False, "message": msg}), 403
    except Exception as e:
        db.rollback()
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        cursor.close(); db.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)
