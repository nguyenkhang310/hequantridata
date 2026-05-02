import os
import json
import customtkinter as ctk
import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector

# Cấu hình Database
CONFIG_FILE = "db_config.json"

def load_config():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except:
            pass
    return {'host': 'localhost', 'user': 'root', 'password': 'Nguyenkhang@123', 'database': 'QuanLyDKHP'}

def save_config(config):
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=4)

DB_CONFIG = load_config()

# Cài đặt giao diện hiện đại
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class UTHApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        self.title("UTH - Hệ Thống Quản Lý Đào Tạo Tín Chỉ")
        self.geometry("1200x750")
        self.minsize(1000, 600)
        
        self.user_id = None
        self.user_name = None
        self.user_role = None
        
        self.setup_treeview_style()
        self.show_login_screen()

    def setup_treeview_style(self):
        self.style = ttk.Style(self)
        self.style.theme_use("default")
        self.style.configure("Treeview",
                        background="#2B2B2B",
                        foreground="white",
                        rowheight=35,
                        fieldbackground="#2B2B2B",
                        bordercolor="#343638",
                        borderwidth=0,
                        font=('Segoe UI', 11))
        self.style.map('Treeview', background=[('selected', '#1F538D')])
        self.style.configure("Treeview.Heading",
                        background="#3A3A3A",
                        foreground="white",
                        relief="flat",
                        font=('Segoe UI', 12, 'bold'))
        self.style.map("Treeview.Heading", background=[('active', '#1F538D')])
        # Add tags for alternating row colors
        self.style.configure("Treeview", rowheight=35)

    def connect_db(self):
        try:
            return mysql.connector.connect(**DB_CONFIG)
        except Exception as e:
            msg = messagebox.askyesno("Lỗi Database", f"Không thể kết nối CSDL: {e}\n\nBạn có muốn mở cài đặt kết nối không?")
            if msg:
                self.show_db_settings()
            return None

    def clear_window(self):
        for widget in self.winfo_children():
            widget.destroy()

    def show_db_settings(self):
        top = ctk.CTkToplevel(self)
        top.title("Cài đặt Cơ sở dữ liệu")
        top.geometry("400x400")
        top.transient(self)
        top.grab_set()

        ctk.CTkLabel(top, text="CẤU HÌNH DATABASE", font=ctk.CTkFont(size=20, weight="bold")).pack(pady=20)

        frame = ctk.CTkFrame(top, fg_color="transparent")
        frame.pack(fill="both", expand=True, padx=20)

        entries = {}
        row = 0
        for key in ['host', 'user', 'password', 'database']:
            ctk.CTkLabel(frame, text=key.capitalize() + ":", font=ctk.CTkFont(size=14)).grid(row=row, column=0, sticky="w", pady=10)
            ent = ctk.CTkEntry(frame, width=200, show="*" if key == "password" else "", font=ctk.CTkFont(size=14))
            ent.grid(row=row, column=1, pady=10, padx=10)
            ent.insert(0, DB_CONFIG.get(key, ""))
            entries[key] = ent
            row += 1

        def save():
            for key in entries:
                DB_CONFIG[key] = entries[key].get()
            save_config(DB_CONFIG)
            messagebox.showinfo("Thành công", "Đã lưu cấu hình. Vui lòng thử lại!")
            top.destroy()

        ctk.CTkButton(top, text="LƯU", command=save, width=200, height=40, font=ctk.CTkFont(weight="bold")).pack(pady=20)

    def show_login_screen(self):
        self.clear_window()
        
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)
        
        login_frame = ctk.CTkFrame(self, width=450, height=550, corner_radius=20)
        login_frame.grid(row=0, column=0, padx=20, pady=20)
        login_frame.grid_propagate(False)
        
        btn_settings = ctk.CTkButton(login_frame, text="⚙️", width=30, height=30, fg_color="transparent", hover_color="#444444", command=self.show_db_settings)
        btn_settings.place(x=400, y=10)
        
        ctk.CTkLabel(login_frame, text="UTH PORTAL", font=ctk.CTkFont(family="Segoe UI", size=36, weight="bold"), text_color="#3498db").pack(pady=(50, 5))
        ctk.CTkLabel(login_frame, text="Hệ Thống Quản Lý Đào Tạo", font=ctk.CTkFont(family="Segoe UI", size=16)).pack(pady=(0, 40))
        
        self.ent_user = ctk.CTkEntry(login_frame, width=320, height=50, placeholder_text="Mã số sinh viên / giảng viên", font=ctk.CTkFont(size=14))
        self.ent_user.pack(pady=10)
        
        self.ent_pass = ctk.CTkEntry(login_frame, width=320, height=50, placeholder_text="Mật khẩu", show="*", font=ctk.CTkFont(size=14))
        self.ent_pass.pack(pady=10)
        
        self.role_var = ctk.StringVar(value="SinhVien")
        role_frame = ctk.CTkFrame(login_frame, fg_color="transparent")
        role_frame.pack(pady=20)
        
        ctk.CTkRadioButton(role_frame, text="Sinh Viên", variable=self.role_var, value="SinhVien", font=ctk.CTkFont(size=14)).pack(side="left", padx=20)
        ctk.CTkRadioButton(role_frame, text="Giảng Viên", variable=self.role_var, value="GiaoVien", font=ctk.CTkFont(size=14)).pack(side="left", padx=20)
        
        btn_login = ctk.CTkButton(login_frame, text="ĐĂNG NHẬP", width=320, height=50, font=ctk.CTkFont(size=16, weight="bold"), command=self.do_login, corner_radius=10)
        btn_login.pack(pady=(20, 10))

    def do_login(self):
        uid = self.ent_user.get().strip()
        pwd = self.ent_pass.get()
        role = self.role_var.get()
        
        if not uid or not pwd:
            messagebox.showwarning("Thông báo", "Vui lòng nhập đủ tài khoản và mật khẩu!")
            return
            
        db = self.connect_db()
        if not db: return
        cursor = db.cursor()
        
        try:
            result = cursor.callproc('sp_DangNhap', (uid, pwd, role, 0, '', ''))
            ok = result[3]
            name = result[4]
            msg = result[5]
            
            if ok == 1:
                self.user_id = uid
                self.user_name = name
                self.user_role = role
                if role == 'SinhVien':
                    self.show_dashboard_sinhvien()
                else:
                    self.show_dashboard_giaovien()
            else:
                messagebox.showerror("Lỗi Đăng Nhập", msg)
        except Exception as e:
            messagebox.showerror("Lỗi", str(e))
        finally:
            cursor.close()
            db.close()

    def create_dashboard_layout(self, title):
        self.clear_window()
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)
        
        self.sidebar_frame = ctk.CTkFrame(self, width=280, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(7, weight=1)
        
        ctk.CTkLabel(self.sidebar_frame, text="UTH", font=ctk.CTkFont(size=32, weight="bold"), text_color="#3498db").grid(row=0, column=0, padx=20, pady=(30, 0), sticky="w")
        ctk.CTkLabel(self.sidebar_frame, text="Quản Lý Đào Tạo", font=ctk.CTkFont(size=16)).grid(row=1, column=0, padx=20, pady=(0, 30), sticky="w")
        
        user_frame = ctk.CTkFrame(self.sidebar_frame, fg_color="#333333", corner_radius=10)
        user_frame.grid(row=2, column=0, padx=15, pady=(0, 30), sticky="ew")
        ctk.CTkLabel(user_frame, text=f"👤 {self.user_name}", font=ctk.CTkFont(size=16, weight="bold")).pack(pady=(15, 0), padx=15, anchor="w")
        ctk.CTkLabel(user_frame, text=f"ID: {self.user_id}", font=ctk.CTkFont(size=13, slant="italic"), text_color="gray").pack(pady=(0, 15), padx=15, anchor="w")
        
        self.main_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.main_frame.grid(row=0, column=1, sticky="nsew", padx=30, pady=30)
        
        header_frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        header_frame.pack(fill="x", pady=(0, 30))
        
        self.view_title = ctk.CTkLabel(header_frame, text=title, font=ctk.CTkFont(size=28, weight="bold"))
        self.view_title.pack(side="left")
        
        self.content_frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        self.content_frame.pack(fill="both", expand=True)
        
        self.sidebar_btns = []
        self.btn_row = 3

    def add_sidebar_btn(self, text, command, is_danger=False):
        color = "#c0392b" if is_danger else "transparent"
        hover = "#e74c3c" if is_danger else "#333333"
        fg_color = "white"
        
        btn = ctk.CTkButton(self.sidebar_frame, text=text, fg_color=color, hover_color=hover, text_color=fg_color,
                            font=ctk.CTkFont(size=15, weight="bold"), anchor="w", height=50, corner_radius=8,
                            command=lambda b=text, c=command: self.handle_sidebar_click(b, c))
        
        if is_danger:
            btn.grid(row=8, column=0, padx=15, pady=20, sticky="sew")
        else:
            btn.grid(row=self.btn_row, column=0, padx=15, pady=5, sticky="ew")
            self.btn_row += 1
            self.sidebar_btns.append(btn)
            
    def handle_sidebar_click(self, btn_text, command):
        for btn in self.sidebar_btns:
            btn.configure(fg_color="transparent")
            if btn.cget("text") == btn_text:
                btn.configure(fg_color="#1F538D")
                
        for widget in self.content_frame.winfo_children():
            widget.destroy()
            
        command()

    # --- CHỨC NĂNG SINH VIÊN ---
    def show_dashboard_sinhvien(self):
        self.create_dashboard_layout("Bảng Điều Khiển Sinh Viên")
        
        self.add_sidebar_btn("🏠 Tổng Quan", self.view_sv_home)
        self.add_sidebar_btn("📝 Đăng Ký Học Phần", self.view_sv_dangky)
        self.add_sidebar_btn("📅 Thời Khóa Biểu", self.view_sv_lichhoc)
        self.add_sidebar_btn("📊 Kết Quả Học Tập", self.view_sv_bangdiem)
        self.add_sidebar_btn("🔑 Đổi Mật Khẩu", self.view_doi_matkhau)
        self.add_sidebar_btn("🚪 Đăng Xuất", self.show_login_screen, is_danger=True)
        
        self.handle_sidebar_click("🏠 Tổng Quan", self.view_sv_home)

    def view_sv_home(self):
        self.view_title.configure(text="🏠 Tổng Quan Sinh Viên")
        
        db = self.connect_db()
        if not db: return
        cursor = db.cursor()
        
        gpa = "0.0"
        xeploai = "Chưa có"
        tong_tc = 0
        
        try:
            cursor.callproc('sp_XemBangDiem', (self.user_id,))
            results = cursor.stored_results()
            rs_chitiet = next(results) # discard
            rs_tonghop = next(results)
            summary = rs_tonghop.fetchone()
            if summary and summary[0] is not None:
                gpa = summary[0]
                xeploai = summary[1]
                tong_tc = summary[3]
        except Exception:
            pass
        finally:
            cursor.close()
            db.close()
            
        sum_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="transparent")
        sum_frame.pack(fill="x", pady=20)
        
        def create_stat_card(parent, title, value, color):
            card = ctk.CTkFrame(parent, corner_radius=10, fg_color=color)
            card.pack(side="left", expand=True, fill="both", padx=10, ipadx=10, ipady=25)
            ctk.CTkLabel(card, text=title, font=ctk.CTkFont(size=16), text_color="white").pack()
            ctk.CTkLabel(card, text=value, font=ctk.CTkFont(size=32, weight="bold"), text_color="white").pack(pady=(10, 0))

        create_stat_card(sum_frame, "Điểm Trung Bình Tích Lũy", str(gpa), "#1F538D")
        create_stat_card(sum_frame, "Xếp Loại Học Lực", str(xeploai), "#27ae60")
        create_stat_card(sum_frame, "Số Tín Chỉ Tích Lũy", str(tong_tc), "#e67e22")
        
        info_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="#2B2B2B")
        info_frame.pack(fill="both", expand=True, pady=20, padx=10)
        ctk.CTkLabel(info_frame, text=f"Chào mừng sinh viên {self.user_name} (MSSV: {self.user_id}) đến với Hệ thống Quản lý Đào tạo UTH.", font=ctk.CTkFont(size=18)).pack(pady=40)
        ctk.CTkLabel(info_frame, text="Vui lòng sử dụng menu bên trái để thao tác.", font=ctk.CTkFont(size=16, slant="italic"), text_color="gray").pack()

    def view_sv_dangky(self):
        self.view_title.configure(text="📝 Đăng Ký Học Phần (HK1 - 2025/2026)")
        
        ctrl_frame = ctk.CTkFrame(self.content_frame, corner_radius=15)
        ctrl_frame.pack(fill="x", pady=(0, 20))
        
        ctk.CTkLabel(ctrl_frame, text="Mã Học Phần:", font=ctk.CTkFont(size=16, weight="bold")).pack(side="left", padx=(30, 15), pady=25)
        ent_mahp = ctk.CTkEntry(ctrl_frame, width=220, height=45, font=ctk.CTkFont(size=15), placeholder_text="VD: HP001")
        ent_mahp.pack(side="left", padx=10, pady=25)
        
        def call_sp(sp_name, success_msg_prefix):
            mahp = ent_mahp.get().strip().upper()
            if not mahp:
                messagebox.showwarning("Lỗi", "Vui lòng nhập Mã Học Phần!")
                return
            if sp_name == 'sp_HuyDangKyHocPhan' and not messagebox.askyesno("Xác nhận", f"Bạn muốn hủy lớp {mahp}?"):
                return
                
            db = self.connect_db()
            if not db: return
            cursor = db.cursor()
            try:
                result = cursor.callproc(sp_name, (self.user_id, mahp, 0, ''))
                if result[2] == 1:
                    db.commit()
                    messagebox.showinfo("Thành công", result[3])
                    ent_mahp.delete(0, tk.END)
                    load_data()
                else:
                    messagebox.showerror("Lỗi", result[3])
            except Exception as e:
                messagebox.showerror("Lỗi", str(e))
            finally:
                cursor.close()
                db.close()

        ctk.CTkButton(ctrl_frame, text="Đăng Ký (+)", fg_color="#27ae60", hover_color="#2ecc71", font=ctk.CTkFont(weight="bold", size=14),
                      width=130, height=45, corner_radius=8, command=lambda: call_sp('sp_DangKyHocPhan', 'Đăng ký')).pack(side="left", padx=10, pady=25)
        ctk.CTkButton(ctrl_frame, text="Hủy Đăng Ký (-)", fg_color="#c0392b", hover_color="#e74c3c", font=ctk.CTkFont(weight="bold", size=14),
                      width=130, height=45, corner_radius=8, command=lambda: call_sp('sp_HuyDangKyHocPhan', 'Hủy')).pack(side="left", padx=10, pady=25)
        
        ctk.CTkButton(ctrl_frame, text="🔄 Làm mới", fg_color="#3498db", hover_color="#2980b9", font=ctk.CTkFont(weight="bold", size=14),
                      width=110, height=45, corner_radius=8, command=lambda: load_data()).pack(side="right", padx=30, pady=25)

        ctk.CTkLabel(self.content_frame, text="💡 Gợi ý: Click đúp vào môn học bên dưới để điền mã tự động", text_color="gray", font=ctk.CTkFont(slant="italic")).pack(anchor="w", pady=(0, 10))

        tree_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="transparent")
        tree_frame.pack(fill="both", expand=True)
        
        columns = ("MaHP", "TenMH", "SoTC", "TenGV", "SiSo", "TrangThai", "LichHoc")
        tree = ttk.Treeview(tree_frame, columns=columns, show="headings")
        tree.tag_configure('oddrow', background='#2B2B2B')
        tree.tag_configure('evenrow', background='#323232')
        
        tree.heading("MaHP", text="Mã HP")
        tree.heading("TenMH", text="Tên Môn Học")
        tree.heading("SoTC", text="TC")
        tree.heading("TenGV", text="Giảng Viên")
        tree.heading("SiSo", text="Sĩ Số")
        tree.heading("TrangThai", text="Trạng Thái")
        tree.heading("LichHoc", text="Lịch Học")
        
        tree.column("MaHP", width=80, anchor=tk.CENTER)
        tree.column("TenMH", width=250)
        tree.column("SoTC", width=50, anchor=tk.CENTER)
        tree.column("TenGV", width=180)
        tree.column("SiSo", width=100, anchor=tk.CENTER)
        tree.column("TrangThai", width=120, anchor=tk.CENTER)
        tree.column("LichHoc", width=300)
        
        scrollbar = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=tree.yview)
        tree.configure(yscroll=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        tree.pack(side="left", fill="both", expand=True)
        
        def on_double_click(event):
            item = tree.selection()
            if item:
                ent_mahp.delete(0, tk.END)
                ent_mahp.insert(0, tree.item(item[0], "values")[0])
        tree.bind("<Double-1>", on_double_click)
        
        def load_data():
            for row in tree.get_children(): tree.delete(row)
            db = self.connect_db()
            if not db: return
            cursor = db.cursor()
            try:
                cursor.callproc('sp_XemDanhSachHocPhan', (1, '2025-2026'))
                for result in cursor.stored_results():
                    rows = result.fetchall()
                    for i, row in enumerate(rows):
                        siso_str = f"{row[4]}/{row[5]}"
                        display_row = (row[0], row[1], row[2], row[3] or 'Chưa phân công', siso_str, row[7], row[8])
                        tag = 'evenrow' if i % 2 == 0 else 'oddrow'
                        tree.insert("", tk.END, values=display_row, tags=(tag,))
            finally:
                cursor.close()
                db.close()
        load_data()

    def view_sv_lichhoc(self):
        self.view_title.configure(text="📅 Thời Khóa Biểu (HK1 - 2025/2026)")
        
        tree_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="transparent")
        tree_frame.pack(fill="both", expand=True)
        
        columns = ("Thu", "Tiet", "Phong", "TenMH", "MaHP", "GiangVien")
        tree = ttk.Treeview(tree_frame, columns=columns, show="headings")
        tree.tag_configure('oddrow', background='#2B2B2B')
        tree.tag_configure('evenrow', background='#323232')
        
        tree.heading("Thu", text="Thứ")
        tree.heading("Tiet", text="Tiết Học")
        tree.heading("Phong", text="Phòng")
        tree.heading("TenMH", text="Tên Môn Học")
        tree.heading("MaHP", text="Mã HP")
        tree.heading("GiangVien", text="Giảng Viên")
        
        tree.column("Thu", width=100, anchor=tk.CENTER)
        tree.column("Tiet", width=120, anchor=tk.CENTER)
        tree.column("Phong", width=120, anchor=tk.CENTER)
        tree.column("TenMH", width=300)
        tree.column("MaHP", width=100, anchor=tk.CENTER)
        tree.column("GiangVien", width=250)
        
        scrollbar = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=tree.yview)
        tree.configure(yscroll=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        tree.pack(side="left", fill="both", expand=True)
        
        db = self.connect_db()
        if not db: return
        cursor = db.cursor()
        try:
            cursor.callproc('sp_XemLichHocSinhVien', (self.user_id, 1, '2025-2026'))
            for result in cursor.stored_results():
                rows = result.fetchall()
                for i, row in enumerate(rows):
                    tiet_str = f"Tiết {row[1]} - {row[2]}"
                    tag = 'evenrow' if i % 2 == 0 else 'oddrow'
                    tree.insert("", tk.END, values=(row[0], tiet_str, row[3], row[4], row[5], row[6] or ''), tags=(tag,))
        finally:
            cursor.close()
            db.close()

    def view_sv_bangdiem(self):
        self.view_title.configure(text="📊 Kết Quả Học Tập Tích Lũy")
        
        sum_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="transparent")
        sum_frame.pack(fill="x", pady=(0, 20))
        
        card1 = ctk.CTkFrame(sum_frame, corner_radius=10, fg_color="#1F538D")
        card1.pack(side="left", expand=True, fill="both", padx=10, ipadx=10, ipady=15)
        self.lbl_gpa = ctk.CTkLabel(card1, text="GPA: --", font=ctk.CTkFont(size=24, weight="bold"), text_color="white")
        self.lbl_gpa.pack(expand=True)
        
        card2 = ctk.CTkFrame(sum_frame, corner_radius=10, fg_color="#27ae60")
        card2.pack(side="left", expand=True, fill="both", padx=10, ipadx=10, ipady=15)
        self.lbl_xeploai = ctk.CTkLabel(card2, text="Xếp Loại: --", font=ctk.CTkFont(size=24, weight="bold"), text_color="white")
        self.lbl_xeploai.pack(expand=True)
        
        card3 = ctk.CTkFrame(sum_frame, corner_radius=10, fg_color="#e67e22")
        card3.pack(side="left", expand=True, fill="both", padx=10, ipadx=10, ipady=15)
        self.lbl_tc = ctk.CTkLabel(card3, text="Số Tín Chỉ: --", font=ctk.CTkFont(size=24, weight="bold"), text_color="white")
        self.lbl_tc.pack(expand=True)
        
        tree_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="transparent")
        tree_frame.pack(fill="both", expand=True, pady=(10, 0))
        
        columns = ("HK", "MaMH", "TenMH", "TC", "DiemCC", "DiemGK", "DiemCK", "DiemTB", "XepLoai")
        tree = ttk.Treeview(tree_frame, columns=columns, show="headings")
        tree.tag_configure('oddrow', background='#2B2B2B')
        tree.tag_configure('evenrow', background='#323232')
        
        tree.heading("HK", text="Học Kỳ")
        tree.heading("MaMH", text="Mã MH")
        tree.heading("TenMH", text="Tên Môn Học")
        tree.heading("TC", text="TC")
        tree.heading("DiemCC", text="CC (10%)")
        tree.heading("DiemGK", text="GK (30%)")
        tree.heading("DiemCK", text="CK (60%)")
        tree.heading("DiemTB", text="Hệ 10")
        tree.heading("XepLoai", text="Hệ Chữ")
        
        for col in columns:
            if col != "TenMH": tree.column(col, width=80, anchor=tk.CENTER)
        tree.column("TenMH", width=280)
        
        scrollbar = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=tree.yview)
        tree.configure(yscroll=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        tree.pack(side="left", fill="both", expand=True)
        
        db = self.connect_db()
        if not db: return
        cursor = db.cursor()
        try:
            cursor.callproc('sp_XemBangDiem', (self.user_id,))
            results = cursor.stored_results()
            
            rs_chitiet = next(results)
            rows = rs_chitiet.fetchall()
            for i, row in enumerate(rows):
                hk_str = f"HK{row[0]} ({row[1]})"
                tag = 'evenrow' if i % 2 == 0 else 'oddrow'
                tree.insert("", tk.END, values=(hk_str, row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9]), tags=(tag,))
                
            rs_tonghop = next(results)
            summary = rs_tonghop.fetchone()
            if summary and summary[0] is not None:
                self.lbl_gpa.configure(text=f"GPA: {summary[0]} / 4.0")
                self.lbl_xeploai.configure(text=f"Xếp Loại: {summary[1]}")
                self.lbl_tc.configure(text=f"Số Tín Chỉ: {summary[3]}")
        except Exception:
            pass
        finally:
            cursor.close()
            db.close()

    # --- CHỨC NĂNG GIÁO VIÊN ---
    def show_dashboard_giaovien(self):
        self.create_dashboard_layout("Bảng Điều Khiển Giảng Viên")
        
        self.add_sidebar_btn("🏠 Tổng Quan", self.view_gv_home)
        self.add_sidebar_btn("📚 Quản Lý Lớp Dạy", self.view_gv_lophoc)
        self.add_sidebar_btn("🔑 Đổi Mật Khẩu", self.view_doi_matkhau)
        self.add_sidebar_btn("🚪 Đăng Xuất", self.show_login_screen, is_danger=True)
        
        self.handle_sidebar_click("🏠 Tổng Quan", self.view_gv_home)

    def view_gv_home(self):
        self.view_title.configure(text="🏠 Tổng Quan Giảng Viên")
        
        db = self.connect_db()
        if not db: return
        cursor = db.cursor()
        total_classes = 0
        try:
            cursor.execute("SELECT COUNT(*) FROM HocPhan WHERE MaGV = %s", (self.user_id,))
            total_classes = cursor.fetchone()[0]
        except Exception:
            pass
        finally:
            cursor.close()
            db.close()
            
        sum_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="transparent")
        sum_frame.pack(fill="x", pady=20)
        
        card = ctk.CTkFrame(sum_frame, corner_radius=10, fg_color="#1F538D")
        card.pack(side="left", expand=True, fill="both", padx=10, ipadx=10, ipady=25)
        ctk.CTkLabel(card, text="Tổng Số Lớp Đang Giảng Dạy", font=ctk.CTkFont(size=16), text_color="white").pack()
        ctk.CTkLabel(card, text=str(total_classes), font=ctk.CTkFont(size=32, weight="bold"), text_color="white").pack(pady=(10, 0))
        
        info_frame = ctk.CTkFrame(self.content_frame, corner_radius=15, fg_color="#2B2B2B")
        info_frame.pack(fill="both", expand=True, pady=20, padx=10)
        ctk.CTkLabel(info_frame, text=f"Kính chào Thầy/Cô {self.user_name}.", font=ctk.CTkFont(size=18)).pack(pady=40)
        ctk.CTkLabel(info_frame, text="Sử dụng menu bên trái để quản lý lớp dạy và cập nhật điểm.", font=ctk.CTkFont(size=16, slant="italic"), text_color="gray").pack()

    def view_gv_lophoc(self):
        self.view_title.configure(text="📚 Quản Lý Lớp & Cập Nhật Điểm Sinh Viên")
        
        frame_classes = ctk.CTkFrame(self.content_frame, corner_radius=15, height=250)
        frame_classes.pack(fill="x", pady=(0, 15))
        frame_classes.pack_propagate(False)
        
        header_cls = ctk.CTkFrame(frame_classes, fg_color="transparent")
        header_cls.pack(fill="x", padx=20, pady=(15, 10))
        ctk.CTkLabel(header_cls, text="Các Học Phần Đang Giảng Dạy", font=ctk.CTkFont(size=16, weight="bold")).pack(side="left")
        ctk.CTkButton(header_cls, text="🔄 Làm mới", width=100, height=30, command=lambda: load_classes()).pack(side="right")
        
        tree_cls_frame = ctk.CTkFrame(frame_classes, fg_color="transparent")
        tree_cls_frame.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        
        cols_cls = ("MaHP", "TenMH", "HocKy", "NamHoc", "SiSo", "TrangThai")
        tree_cls = ttk.Treeview(tree_cls_frame, columns=cols_cls, show="headings")
        tree_cls.tag_configure('oddrow', background='#2B2B2B')
        tree_cls.tag_configure('evenrow', background='#323232')
        
        tree_cls.heading("MaHP", text="Mã HP")
        tree_cls.heading("TenMH", text="Tên Môn Học")
        tree_cls.heading("HocKy", text="Học Kỳ")
        tree_cls.heading("NamHoc", text="Năm Học")
        tree_cls.heading("SiSo", text="Sĩ Số Thực Tế")
        tree_cls.heading("TrangThai", text="Trạng Thái")
        
        for c in cols_cls:
            if c != "TenMH": tree_cls.column(c, width=120, anchor=tk.CENTER)
        tree_cls.column("TenMH", width=350)
        
        scroll_cls = ttk.Scrollbar(tree_cls_frame, orient=tk.VERTICAL, command=tree_cls.yview)
        tree_cls.configure(yscroll=scroll_cls.set)
        scroll_cls.pack(side="right", fill="y")
        tree_cls.pack(side="left", fill="both", expand=True)
        
        frame_st = ctk.CTkFrame(self.content_frame, corner_radius=15)
        frame_st.pack(fill="both", expand=True)
        
        header_st = ctk.CTkFrame(frame_st, fg_color="transparent")
        header_st.pack(fill="x", padx=20, pady=15)
        
        lbl_st_title = ctk.CTkLabel(header_st, text="🎓 Danh sách Sinh Viên (Vui lòng chọn 1 lớp ở trên)", font=ctk.CTkFont(size=16, weight="bold"), text_color="#f39c12")
        lbl_st_title.pack(side="left")
        
        btn_nhapdiem = ctk.CTkButton(header_st, text="📝 Nhập / Cập Nhật Điểm", state="disabled", width=180, height=40, font=ctk.CTkFont(weight="bold", size=14), fg_color="#27ae60")
        btn_nhapdiem.pack(side="right")
        
        tree_st_frame = ctk.CTkFrame(frame_st, fg_color="transparent")
        tree_st_frame.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        
        cols_st = ("MaSV", "HoTen", "Lop", "DiemCC", "DiemGK", "DiemCK", "DiemTB")
        tree_st = ttk.Treeview(tree_st_frame, columns=cols_st, show="headings")
        tree_st.tag_configure('oddrow', background='#2B2B2B')
        tree_st.tag_configure('evenrow', background='#323232')
        
        tree_st.heading("MaSV", text="Mã SV")
        tree_st.heading("HoTen", text="Họ Tên")
        tree_st.heading("Lop", text="Lớp")
        tree_st.heading("DiemCC", text="Chuyên Cần")
        tree_st.heading("DiemGK", text="Giữa Kỳ")
        tree_st.heading("DiemCK", text="Cuối Kỳ")
        tree_st.heading("DiemTB", text="Điểm Tổng")
        
        for c in cols_st:
            if c != "HoTen": tree_st.column(c, width=100, anchor=tk.CENTER)
        tree_st.column("HoTen", width=250)
        
        scroll_st = ttk.Scrollbar(tree_st_frame, orient=tk.VERTICAL, command=tree_st.yview)
        tree_st.configure(yscroll=scroll_st.set)
        scroll_st.pack(side="right", fill="y")
        tree_st.pack(side="left", fill="both", expand=True)
        
        def load_classes():
            for r in tree_cls.get_children(): tree_cls.delete(r)
            for r in tree_st.get_children(): tree_st.delete(r)
            lbl_st_title.configure(text="🎓 Danh sách Sinh Viên (Vui lòng chọn 1 lớp ở trên)", text_color="#f39c12")
            btn_nhapdiem.configure(state="disabled")
            
            db = self.connect_db()
            if db:
                cursor = db.cursor()
                try:
                    cursor.execute("""
                        SELECT hp.MaHP, mh.TenMH, hp.HocKy, hp.NamHoc, hp.SiSoHienTai, hp.TrangThai
                        FROM HocPhan hp JOIN MonHoc mh ON hp.MaMH = mh.MaMH
                        WHERE hp.MaGV = %s
                    """, (self.user_id,))
                    rows = cursor.fetchall()
                    for i, row in enumerate(rows):
                        tag = 'evenrow' if i % 2 == 0 else 'oddrow'
                        tree_cls.insert("", tk.END, values=row, tags=(tag,))
                finally:
                    cursor.close()
                    db.close()
                    
        load_classes()
                
        def on_class_select(event):
            sel = tree_cls.selection()
            if not sel: return
            mahp = tree_cls.item(sel[0], "values")[0]
            tenmh = tree_cls.item(sel[0], "values")[1]
            lbl_st_title.configure(text=f"🎓 Sinh Viên Lớp: {mahp} ({tenmh})", text_color="#3498db")
            
            for r in tree_st.get_children(): tree_st.delete(r)
            btn_nhapdiem.configure(state="disabled")
            
            db = self.connect_db()
            if not db: return
            cursor = db.cursor(dictionary=True)
            try:
                query = """
                    SELECT sv.MaSV, sv.HoTen, sv.Lop, 
                           bd.DiemCC, bd.DiemGiuaKy, bd.DiemCuoiKy, bd.DiemTB, dk.MaDK
                    FROM DangKyHocPhan dk
                    JOIN SinhVien sv ON dk.MaSV = sv.MaSV
                    LEFT JOIN BangDiem bd ON dk.MaDK = bd.MaDK
                    WHERE dk.MaHP = %s AND dk.TrangThai = 'DaDuyet'
                    ORDER BY sv.MaSV
                """
                cursor.execute(query, (mahp,))
                rows = cursor.fetchall()
                for i, row in enumerate(rows):
                    tag = 'evenrow' if i % 2 == 0 else 'oddrow'
                    tree_st.insert("", tk.END, values=(
                        row['MaSV'], row['HoTen'], row['Lop'],
                        row['DiemCC'] if row['DiemCC'] is not None else '-',
                        row['DiemGiuaKy'] if row['DiemGiuaKy'] is not None else '-',
                        row['DiemCuoiKy'] if row['DiemCuoiKy'] is not None else '-',
                        row['DiemTB'] if row['DiemTB'] is not None else '-'
                    ), tags=(tag, row['MaDK']))
            finally:
                cursor.close()
                db.close()
                
        tree_cls.bind("<<TreeviewSelect>>", on_class_select)
        
        def on_st_select(event):
            if tree_st.selection():
                btn_nhapdiem.configure(state="normal")
            else:
                btn_nhapdiem.configure(state="disabled")
        tree_st.bind("<<TreeviewSelect>>", on_st_select)
        
        def show_grade_dialog():
            sel_st = tree_st.selection()
            if not sel_st: return
            item = tree_st.item(sel_st[0])
            madk = tree_st.item(sel_st[0], "tags")[1]
            masv = item["values"][0]
            hoten = item["values"][1]
            
            curr_cc = item["values"][3]
            curr_gk = item["values"][4]
            curr_ck = item["values"][5]
            
            top = ctk.CTkToplevel(self)
            top.title("Nhập Điểm Sinh Viên")
            top.geometry("450x450")
            top.transient(self)
            top.grab_set()
            
            ctk.CTkLabel(top, text="CẬP NHẬT ĐIỂM", font=ctk.CTkFont(size=24, weight="bold"), text_color="#3498db").pack(pady=(30, 5))
            ctk.CTkLabel(top, text=f"{masv} - {hoten}", font=ctk.CTkFont(size=16, slant="italic")).pack(pady=(0, 30))
            
            frame_entries = ctk.CTkFrame(top, fg_color="transparent")
            frame_entries.pack()
            
            ctk.CTkLabel(frame_entries, text="Điểm Chuyên Cần (10%):", font=ctk.CTkFont(size=15)).grid(row=0, column=0, pady=15, padx=15, sticky="e")
            ent_cc = ctk.CTkEntry(frame_entries, width=120, height=40, font=ctk.CTkFont(size=14))
            ent_cc.grid(row=0, column=1, pady=15, padx=10)
            if str(curr_cc) != '-': ent_cc.insert(0, str(curr_cc))
            
            ctk.CTkLabel(frame_entries, text="Điểm Giữa Kỳ (30%):", font=ctk.CTkFont(size=15)).grid(row=1, column=0, pady=15, padx=15, sticky="e")
            ent_gk = ctk.CTkEntry(frame_entries, width=120, height=40, font=ctk.CTkFont(size=14))
            ent_gk.grid(row=1, column=1, pady=15, padx=10)
            if str(curr_gk) != '-': ent_gk.insert(0, str(curr_gk))
            
            ctk.CTkLabel(frame_entries, text="Điểm Cuối Kỳ (60%):", font=ctk.CTkFont(size=15)).grid(row=2, column=0, pady=15, padx=15, sticky="e")
            ent_ck = ctk.CTkEntry(frame_entries, width=120, height=40, font=ctk.CTkFont(size=14))
            ent_ck.grid(row=2, column=1, pady=15, padx=10)
            if str(curr_ck) != '-': ent_ck.insert(0, str(curr_ck))
            
            def save_grades():
                try:
                    cc = float(ent_cc.get() or 0)
                    gk = float(ent_gk.get() or 0)
                    ck = float(ent_ck.get() or 0)
                    if not (0<=cc<=10 and 0<=gk<=10 and 0<=ck<=10):
                        raise ValueError("Out of bounds")
                except ValueError:
                    messagebox.showerror("Lỗi", "Điểm không hợp lệ! Vui lòng nhập số từ 0.0 đến 10.0")
                    return
                
                db = self.connect_db()
                if not db: return
                cursor = db.cursor()
                try:
                    result = cursor.callproc('sp_CapNhatDiem', (self.user_id, madk, cc, gk, ck, 0, ''))
                    if result[5] == 1:
                        db.commit()
                        messagebox.showinfo("Thành công", result[6])
                        top.destroy()
                        on_class_select(None)
                    else:
                        messagebox.showerror("Lỗi", result[6])
                finally:
                    cursor.close()
                    db.close()
                    
            ctk.CTkButton(top, text="LƯU ĐIỂM", fg_color="#27ae60", hover_color="#2ecc71", font=ctk.CTkFont(weight="bold", size=16), width=180, height=50, corner_radius=10, command=save_grades).pack(pady=40)
            
        btn_nhapdiem.configure(command=show_grade_dialog)
        tree_st.bind("<Double-1>", lambda e: show_grade_dialog() if btn_nhapdiem.cget('state') == "normal" else None)

    # --- CHUNG ---
    def view_doi_matkhau(self):
        self.view_title.configure(text="🔑 Đổi Mật Khẩu Cá Nhân")
        
        container = ctk.CTkFrame(self.content_frame, corner_radius=20, width=600)
        container.pack(pady=60)
        
        inner_frame = ctk.CTkFrame(container, fg_color="transparent")
        inner_frame.pack(padx=50, pady=50)
        
        lbl_font = ctk.CTkFont(size=15, weight="bold")
        
        ctk.CTkLabel(inner_frame, text="Mật khẩu hiện tại:", font=lbl_font).grid(row=0, column=0, sticky="e", pady=20, padx=20)
        ent_old = ctk.CTkEntry(inner_frame, show="*", width=300, height=45, font=ctk.CTkFont(size=14))
        ent_old.grid(row=0, column=1, pady=20)
        
        ctk.CTkLabel(inner_frame, text="Mật khẩu mới:", font=lbl_font).grid(row=1, column=0, sticky="e", pady=20, padx=20)
        ent_new = ctk.CTkEntry(inner_frame, show="*", width=300, height=45, font=ctk.CTkFont(size=14))
        ent_new.grid(row=1, column=1, pady=20)
        
        ctk.CTkLabel(inner_frame, text="Xác nhận MK mới:", font=lbl_font).grid(row=2, column=0, sticky="e", pady=20, padx=20)
        ent_confirm = ctk.CTkEntry(inner_frame, show="*", width=300, height=45, font=ctk.CTkFont(size=14))
        ent_confirm.grid(row=2, column=1, pady=20)
        
        def do_change_pwd():
            old = ent_old.get()
            new = ent_new.get()
            conf = ent_confirm.get()
            
            if not old or not new or not conf:
                messagebox.showwarning("Lỗi", "Vui lòng nhập đủ thông tin!")
                return
            if new != conf:
                messagebox.showerror("Lỗi", "Xác nhận mật khẩu không khớp!")
                return
            if len(new) < 6:
                messagebox.showerror("Lỗi", "Mật khẩu mới phải có ít nhất 6 ký tự!")
                return
                
            db = self.connect_db()
            if not db: return
            cursor = db.cursor()
            try:
                res = cursor.callproc('sp_DoiMatKhau', (self.user_id, self.user_role, old, new, 0, ''))
                if res[4] == 1:
                    db.commit()
                    messagebox.showinfo("Thành công", res[5])
                    ent_old.delete(0, tk.END)
                    ent_new.delete(0, tk.END)
                    ent_confirm.delete(0, tk.END)
                else:
                    messagebox.showerror("Lỗi", res[5])
            finally:
                cursor.close()
                db.close()
                
        ctk.CTkButton(inner_frame, text="CẬP NHẬT MẬT KHẨU", font=ctk.CTkFont(size=16, weight="bold"), width=300, height=50, corner_radius=10, command=do_change_pwd).grid(row=3, column=1, pady=30, sticky="w")


if __name__ == "__main__":
    app = UTHApp()
    app.mainloop()
