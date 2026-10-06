@echo off
rem Build of the SAPI-1 port: build\flappy.com (CP/M) and build\flappy.hex (Intel HEX, from 0100h).
rem PASMO can be set in the environment, default E:\SAPI_GIT\Tools\pasmo-0.5.3\pasmo.exe.
setlocal
cd /d "%~dp0"
if "%PASMO%"=="" set PASMO=E:\SAPI_GIT\Tools\pasmo-0.5.3\pasmo.exe
if not exist build mkdir build
python tools\make_tables.py || exit /b 1
pushd sapi
"%PASMO%" --bin flappy_sapi.asm ..\build\flappy.com ..\build\flappy.sym || (popd & exit /b 1)
"%PASMO%" --hex flappy_sapi.asm ..\build\flappy.hex || (popd & exit /b 1)
popd
python tools\check_addr.py || exit /b 1
for %%f in (build\flappy.com) do set SIZE=%%~zf
set /a PAGES=(SIZE+255)/256
echo build\flappy.com: %SIZE% bytes, in CP/M: SAVE %PAGES% FLAPPY.COM
