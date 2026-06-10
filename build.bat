@echo off
setlocal enabledelayedexpansion
title Astranyx Optimizer - Build Tool v3.0
color 0D
cls

echo.
echo  ============================================================
echo   ASTRANYX OPTIMIZER v3.0  --  EXE Builder
echo  ============================================================
echo.

REM ── Always work from the folder where build.bat lives ────────
cd /d "%~dp0"

REM ── STEP 1: Check Python ─────────────────────────────────────
echo  [STEP 1/5] Checking Python installation...
echo.
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo  [FAIL] Python not found.
    echo.
    echo  Download Python from:  https://python.org/downloads
    echo  During install, check: "Add Python to PATH"
    echo  Then restart your PC and run this again.
    echo.
    pause >nul & exit /b 1
)
for /f "tokens=*" %%v in ('python --version 2^>^&1') do set PY_VER=%%v
echo  [OK] Found: %PY_VER%
echo.

REM ── STEP 2: Upgrade pip ──────────────────────────────────────
echo  [STEP 2/5] Upgrading pip...
echo.
python -m pip install --upgrade pip --quiet
echo  [OK] pip ready.
echo.

REM ── STEP 3: Install PyQt6 ────────────────────────────────────
echo  [STEP 3/5] Installing PyQt6 (requires internet)...
echo  This may take 1-2 minutes on first run...
echo.
python -m pip install PyQt6 --quiet
if %errorlevel% neq 0 (
    echo  [FAIL] PyQt6 install failed.
    echo  Check your internet connection and try:
    echo    python -m pip install PyQt6
    echo.
    pause >nul & exit /b 1
)
echo  [OK] PyQt6 ready.
echo.

REM ── STEP 4: Install PyInstaller ──────────────────────────────
echo  [STEP 4/5] Installing PyInstaller...
echo.
python -m pip install pyinstaller --quiet
if %errorlevel% neq 0 (
    echo  [FAIL] PyInstaller install failed.
    echo  Try manually:  python -m pip install pyinstaller
    echo.
    pause >nul & exit /b 1
)
echo  [OK] PyInstaller ready.
echo.

REM ── STEP 5: Locate source + icon, then build ─────────────────
echo  [STEP 5/5] Building Astranyx Optimizer v3.0 EXE...
echo  This takes 2-4 minutes. Do NOT close this window.
echo.

set "SRC="
if exist "%~dp0astranyx_optimizer.py"     set "SRC=%~dp0astranyx_optimizer.py"
if exist "%~dp0src\astranyx_optimizer.py" set "SRC=%~dp0src\astranyx_optimizer.py"

if not defined SRC (
    echo  [FAIL] Cannot find astranyx_optimizer.py
    echo.
    echo  Place build.bat next to astranyx_optimizer.py and re-run.
    echo.
    pause >nul & exit /b 1
)
echo  [OK] Source : %SRC%

set "ICO="
if exist "%~dp0assets\astranyx.ico" set "ICO=%~dp0assets\astranyx.ico"
if exist "%~dp0astranyx.ico"        set "ICO=%~dp0astranyx.ico"

if defined ICO (
    echo  [OK] Icon   : %ICO%
    set "ICO_FLAG=--icon "%ICO%""
) else (
    echo  [INFO] No icon file found — building without custom icon.
    set "ICO_FLAG="
)
echo.

REM ── Run PyInstaller (--windowed = no console = no popups) ────
python -m PyInstaller ^
    --onefile ^
    --windowed ^
    --name "Astranyx Optimizer" ^
    --uac-admin ^
    %ICO_FLAG% ^
    --clean ^
    --noconfirm ^
    --distpath "%~dp0dist" ^
    --workpath "%~dp0build_tmp" ^
    --specpath "%~dp0build_tmp" ^
    "%SRC%"

if %errorlevel% neq 0 (
    echo.
    echo  [FAIL] PyInstaller failed.
    echo.
    echo  Solutions:
    echo    1. Right-click build.bat  ^>  Run as Administrator
    echo    2. Temporarily disable antivirus
    echo    3. Run:  python -m pip install --upgrade pyinstaller
    echo.
    pause >nul & exit /b 1
)

echo.
echo  ============================================================
echo   BUILD SUCCESSFUL!  Astranyx Optimizer v3.0
echo  ============================================================
echo.
echo  EXE location:
echo    %~dp0dist\Astranyx Optimizer.exe
echo.
echo  ============================================================
echo.

start "" "%~dp0dist"
pause >nul
exit /b 0
