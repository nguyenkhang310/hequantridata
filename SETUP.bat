@echo off
chcp 65001 > nul
echo ============================================================
echo   UTH PORTAL - SETUP TU DONG
echo   He Thong Quan Ly Dang Ky Hoc Phan
echo ============================================================
echo.

:: ---- KIEM TRA PYTHON ----
echo [1/4] Kiem tra Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo    LỖI: Python chua duoc cai. Tai ve tai https://python.org
    echo    Sau do chay lai file nay.
    pause
    exit /b 1
)
python --version
echo    OK!

:: ---- CAI PYTHON PACKAGES ----
echo.
echo [2/4] Cai dat Python packages (Flask, pywebview, mysql-connector)...
pip install -r requirements.txt --quiet
if %errorlevel% neq 0 (
    echo    LỖI: Khong cai duoc packages. Kiem tra ket noi mang.
    pause
    exit /b 1
)
echo    OK!

:: ---- KIEM TRA NODE.JS ----
echo.
echo [3/4] Kiem tra Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo    LỖI: Node.js chua duoc cai. Tai ve tai https://nodejs.org (LTS version)
    echo    Sau do chay lai file nay.
    pause
    exit /b 1
)
node --version
npm --version
echo    OK!

:: ---- CAI NODE MODULES ----
echo.
echo [4/4] Cai dat Node.js modules cho frontend (co the mat 2-5 phut)...
cd frontend
npm install --silent
if %errorlevel% neq 0 (
    echo    LỖI: npm install that bai. Kiem tra ket noi mang.
    cd ..
    pause
    exit /b 1
)
cd ..
echo    OK!

:: ---- HOAN THANH ----
echo.
echo ============================================================
echo   CAI DAT HOAN TAT!
echo ============================================================
echo.
echo HUONG DAN CHAY CHUONG TRINH:
echo   Cach 1 (Don gian): Double-click vao UTH_Portal_Web.exe
echo   Cach 2 (Dev):      Chay start_dev.bat
echo.
echo LUU Y:
echo   - Bat MySQL Server truoc khi chay chuong trinh
echo   - Mo file api.py, sua mat khau MySQL cho dung
echo   - Lan dau chay SQL: vao sql/ chay tung file tu 01 den 06
echo.
pause
