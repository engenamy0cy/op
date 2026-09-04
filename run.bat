@echo off
cd /d %~dp0

call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64

echo === Python ===
python race_python.py

echo.
echo === C++ ===
cl /EHsc /I "%TEMP%\sqlite3\sqlite-amalgamation-3450100" race_cpp.cpp /link /LIBPATH:"%TEMP%\sqlite3\sqlite-amalgamation-3450100" sqlite3.lib
race_cpp.exe

del /q race_cpp.exe 2>nul
del /q race_cpp.obj 2>nul

echo.
pause
