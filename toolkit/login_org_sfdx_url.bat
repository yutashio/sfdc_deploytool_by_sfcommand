@echo off

echo %DATE% %TIME% -----Start login_org_sfdx_url.bat-----

REM ���s���Ă���o�b�`�t�@�C���̃f�B���N�g���p�X���擾����
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.ini��ǂݍ���
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
  set %%i=%%j
)

REM ���O�C���J�n
Call sf org login sfdx-url --sfdx-url-file %batch_dir%\config\%SfdxAuthUrl% 2>&1

if "%~1"=="" (
    rem ���������݂��Ȃ��ꍇ�́Acmd /k�R�}���h�����s
	if %errorlevel% neq 0 (
    	echo Login failed!
	) else (
		echo Login successful
	)
	cmd /k
) else (
    rem ���������݂���ꍇ�́A�Ȃɂ����Ȃ�
	if %errorlevel% neq 0 (
    	echo Login failed!
		rem �G���[�̏ꍇ��1��ԋp
		exit /b 1
	) else (
		echo Login successful
	)
)

echo %DATE% %TIME% -----End login_org_sfdx_url.bat-----