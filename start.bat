@echo off
cd /d "%~dp0"
call flutter pub get
start "Library API" cmd /k node api/mock-server.js --port 8080 --origin http://localhost:5555 --ttl 60
call flutter run -d chrome --web-port=5555 --web-hostname=localhost --dart-define=API_BASE_URL=http://localhost:8080/api
pause
