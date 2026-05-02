"""
UTH Portal - Launcher
Khoi dong Backend (Flask) va Frontend (Node.js), hien thi web trong cua so Desktop.
Yeu cau: Python 3.x, Node.js, MySQL dang chay voi DB QuanLyDKHP.
"""
import os
import sys
import subprocess
import threading
import time
import webview
import multiprocessing

if getattr(sys, 'frozen', False):
    # Đang chạy từ file .exe
    BASE_DIR = os.path.dirname(sys.executable)
else:
    # Đang chạy từ code Python
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))

FRONTEND_DIR = os.path.join(BASE_DIR, "frontend")

# Detect npm - check common locations on Windows
def find_npm():
    candidates = [
        "npm.cmd",
        r"C:\Program Files\nodejs\npm.cmd",
        r"C:\Program Files (x86)\nodejs\npm.cmd",
        os.path.join(os.environ.get("APPDATA", ""), r"npm\npm.cmd"),
        os.path.join(os.environ.get("ProgramFiles", ""), r"nodejs\npm.cmd"),
    ]
    for npm in candidates:
        try:
            # shell=True required for .cmd files on Windows
            subprocess.run([npm, "--version"], capture_output=True, timeout=5, shell=True)
            return npm
        except Exception:
            continue
    return None

NPM = find_npm()

def start_backend():
    """Start Flask API server directly in a thread to prevent fork bomb"""
    import api
    # Tắt use_reloader để ngăn Flask tạo process mới (tránh lỗi trên exe)
    api.app.run(port=5000, debug=False, use_reloader=False)

def start_frontend():
    """Start Node.js dev server"""
    if not NPM:
        return
    env = os.environ.copy()
    env["PATH"] = r"C:\Program Files\nodejs;" + env.get("PATH", "")
    subprocess.Popen(
        [NPM, "run", "dev"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        cwd=FRONTEND_DIR,
        env=env,
        shell=True
    )

def wait_for_server(url, timeout=30):
    """Wait until server is ready"""
    import urllib.request
    from urllib.error import HTTPError
    start = time.time()
    while time.time() - start < timeout:
        try:
            urllib.request.urlopen(url, timeout=2)
            return True
        except HTTPError:
            # Server responds (even if 405 Method Not Allowed), means it's UP
            return True
        except Exception:
            time.sleep(0.5)
    return False

def main():
    multiprocessing.freeze_support()
    # Start backend
    t1 = threading.Thread(target=start_backend, daemon=True)
    t1.start()

    # Start frontend
    t2 = threading.Thread(target=start_frontend, daemon=True)
    t2.start()

    # Show loading window while waiting
    loading_html = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8">
    <title>UTH Portal - Khởi động...</title>
    <style>
        body {
            margin: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background: linear-gradient(135deg, #0f4c75, #1b6ca8);
            font-family: 'Segoe UI', sans-serif;
            color: white;
        }
        .logo { font-size: 56px; margin-bottom: 16px; }
        h1 { font-size: 24px; margin: 0 0 8px 0; }
        p { font-size: 14px; opacity: 0.7; margin: 0 0 32px 0; }
        .spinner {
            width: 40px; height: 40px;
            border: 4px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .status { font-size: 12px; opacity: 0.6; margin-top: 16px; }
    </style>
    </head>
    <body>
        <div class="logo">🎓</div>
        <h1>UTH Portal</h1>
        <p>Hệ thống Quản lý Đăng ký Học phần</p>
        <div class="spinner"></div>
        <div class="status">Đang khởi động hệ thống, vui lòng chờ...</div>
    </body>
    </html>
    """

    window = webview.create_window(
        'Hệ Thống Đăng Ký Học Phần - UTH',
        html=loading_html,
        width=1366,
        height=768,
        min_size=(1024, 600)
    )

    def on_loaded():
        # Wait for both servers to be ready
        wait_for_server("http://localhost:5000/api/login", timeout=15)
        wait_for_server("http://localhost:8080", timeout=30)
        # Navigate to the actual app
        window.load_url("http://localhost:8080")

    threading.Thread(target=on_loaded, daemon=True).start()
    webview.start()

if __name__ == '__main__':
    main()
