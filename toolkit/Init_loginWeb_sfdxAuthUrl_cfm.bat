@echo off

echo %DATE% %TIME% ����g�D�ւ̔F�؁E���O�C����SfdxAuthUrl�̊m�F

REM ���s���Ă���o�b�`�t�@�C���̃f�B���N�g���p�X���擾����
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.ini��ǂݍ���
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
  set %%i=%%j
)

REM salseforce�փ��O�C�� chrome�ŊJ��
Call sf org login web --instance-url %SfMyDomain% --browser chrome

if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% login����Error���������܂����B�������I�����܂��B
	pause
    goto :end
)

REM Sfdx Auth Url�m�F
Call sf org display --target-org %SfUserName% --verbose

if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% �g�D�̏��\������Error���������܂����B�������I�����܂��B
    pause
	goto :end
) else {
	pause
}

Call logout_org.bat

:end