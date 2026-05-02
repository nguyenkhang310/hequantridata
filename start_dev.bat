@echo off
chcp 65001 > nul
echo Khoi dong UTH Portal (Dev Mode)...

:: Backend Flask
start "UTH Backend" cmd /k "python api.py"

:: Frontend Node.js
start "UTH Frontend" cmd /k "cd frontend && npm run dev"

:: Doi 8 giay cho server khoi dong
timeout /t 8 /nobreak > nul

:: Mo trinh duyet
start http://localhost:8080

echo Da khoi dong! Mo trinh duyet tai http://localhost:8080
