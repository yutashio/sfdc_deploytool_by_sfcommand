@echo off

echo %DATE% %TIME% -----Start logout_org.bat-----

REM ���s���Ă���o�b�`�t�@�C���̃f�B���N�g���p�X���擾����
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.ini��ǂݍ���
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
	set %%i=%%j
)

REM ���O�A�E�g
Call sf org logout --target-org %SfUserName% -p

echo %DATE% %TIME% -----End logout_org.bat-----