@echo off

echo %DATE% %TIME% -----Start 01.retrieve_before.bat-----

REM �g�D�ւ̃��O�C��
Call login_org_sfdx_url.bat login

REM �G���[����і߂�l��1�̏ꍇ�͏����I��
if %ERRORLEVEL% equ 1 (
    echo %DATE% %TIME% ���O�C���Ɏ��s���܂����B �������I�����܂��B
	goto end
)

REM ���s���Ă���o�b�`�t�@�C���̃f�B���N�g���p�X���擾����
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.ini��ǂݍ���
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
  set %%i=%%j
)

echo %DATE% %TIME% retrieve���E�E�E

REM �t�H���_���ύX�p�ɍ����̓������擾���Đ��`����
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%

REM retrieve start
Call sf project retrieve start --api-version %SoapApiVersion% --manifest %batch_dir%\retrievemanifest\package.xml --target-metadata-dir %batch_dir%\01.retrieved_before --unzip --target-org %SfUserName% --zip-file-name %today%_%currenttime%_number.zip
if %errorlevel% neq 0 (
	echo %DATE% %TIME% retrieve�����s���܂����B �������I�����܂��B
	goto endwithlogout
)

REM retrive�����t�H���_�����擾����
set "target_folder=%batch_dir%\01.retrieved_before\%today%_%currenttime%_number"

REM retrive�����t�H���_�̗L���m�F
IF exist "%target_folder%" (
	echo %DATE% %TIME% retrieve�������^�f�[�^���u%target_folder%�v�Ɋi�[���܂����B
) else (
    echo %DATE% %TIME% retrieve�������^�f�[�^�̊i�[�Ɏ��s���܂����B�������I�����܂��B
	goto endwithlogout
)

:endwithlogout

REM �g�D���烍�O�A�E�g
Call logout_org.bat

:end

echo -----End 01.retrieve_before.bat-----
cmd /k