@echo off

:inputdeploy
set /p choice=deploy���J�n���܂���? (Y/N) 
if /i "%choice%"=="Y" (
	goto startdeploy
) else if /i "%choice%"=="N" (
	echo deploy�𒆎~���܂����B
	goto enddeploy
) else (
	echo Y �܂��� N ����͂��Ă��������B
	goto inputdeploy
)

:startdeploy
REM ���s���Ă���o�b�`�t�@�C���̃f�B���N�g���p�X���擾����
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM log�t�@�C���p�ɍ����̓������擾���Đ��`����
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%
REM log�t�@�C���쐬
set LogFile=%batch_dir%\log\deploy\deploy_%today%_%currenttime%.log

echo %DATE% %TIME% -----Start deploy_start.bat-----
echo %DATE% %TIME% -----Start deploy_start.bat-----  >> "%logfile%"

REM �g�D�ւ̃��O�C��
Call login_org_sfdx_url.bat login >> "%logfile%"

REM �G���[����і߂�l��1�̏ꍇ�͏����I��
if %ERRORLEVEL% equ 1 (
	echo %DATE% %TIME% ���O�C���Ɏ��s���܂����B �������I�����܂��B
	echo %DATE% %TIME% ���O�C���Ɏ��s���܂����B �������I�����܂��B >> "%logfile%
	goto canceldeploy
)

REM authorization info
Call authorization_info_list.bat logint_check > %batch_dir%\log\sfcommandresults.txt
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { get-content -Encoding UTF8 %batch_dir%\log\sfcommandresults.txt | Set-Content %batch_dir%\log\encodedtosjis.txt}"
type %batch_dir%\log\encodedtosjis.txt >> "%logfile%"

REM setting.ini��ǂݍ���
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
	set %%i=%%j
)

echo %DATE% %TIME% retrieve���E�E�E
echo %DATE% %TIME% retrieve_before�J�n�E�E�E >> "%logfile%

REM �t�H���_���ύX�p�ɍ����̓������擾���Đ��`����
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%

REM retrieve start
Call sf project retrieve start --api-version %SoapApiVersion% --manifest %batch_dir%\retrievemanifest\package.xml --target-metadata-dir %batch_dir%\01.retrieved_before --unzip --target-org %SfUserName% --zip-file-name %today%_%currenttime%_number.zip >> %logfile% 2>&1
if %errorlevel% neq 0 (
	echo %DATE% %TIME% retrieve�����s���܂����B �������I�����܂��B
	echo %DATE% %TIME% retrieve�����s���܂����B �������I�����܂��B >> "%logfile%
	goto canceldeploy
)

REM retrive�����t�H���_�����擾����
set "target_folder=%batch_dir%\01.retrieved_before\%today%_%currenttime%_number"

REM retrive�����t�H���_�̗L���m�F
IF exist "%target_folder%" (
	echo %DATE% %TIME% retrieve�������^�f�[�^���u%target_folder%�v�Ɋi�[���܂����B
	echo %DATE% %TIME% retrieve�������^�f�[�^���u%target_folder%�v�Ɋi�[���܂����B >> "%logfile%
) else (
	echo %DATE% %TIME% retrieve�������^�f�[�^�̊i�[�Ɏ��s���܂����B�������I�����܂��B
	echo %DATE% %TIME% retrieve�������^�f�[�^�̊i�[�Ɏ��s���܂����B�������I�����܂��B >> "%logfile%
	goto canceldeploy
)

echo %DATE% %TIME% retrieve�����E�E�E
echo %DATE% %TIME% retrieve_before�I���E�E�E >> "%logfile%

echo %DATE% %TIME% deploy���E�E�E
echo %DATE% %TIME% deploy���J�n�E�E�E >> "%logfile%"

REM testclasslist�t�@�C���̃p�X���w��
set "file_path=testclasslist.txt"
REM �ϐ���testclasslist�t�@�C���̓��e��ǂݍ���
for /f "usebackq tokens=* delims=" %%a in ("%file_path%") do (
    set "testclass=%%a"
)

REM deploy start
if "%TestLevel%" == "RunAllTestsInOrg" (
	echo �g�D���̂��ׂẴe�X�g�����s���܂��B >> "%logfile%
	Call sf project deploy start --api-version %SoapApiVersion% --metadata-dir %batch_dir%\deploycodepkg --test-level %TestLevel% --target-org %SfUserName% > %batch_dir%\log\sfcommandresults.txt 2>&1
) else if "%TestLevel%" == "RunSpecifiedTests" (
	echo deploy�p�Ƀe�X�g�N���X�u%testclass%�v���w�肵�܂����B >> "%logfile%
	Call sf project deploy start --api-version %SoapApiVersion% --metadata-dir %batch_dir%\deploycodepkg --test-level %TestLevel% --tests %testclass% --target-org %SfUserName% > %batch_dir%\log\sfcommandresults.txt 2>&1
) else (
	echo �����Ȓl���ݒ肳��Ă��邩�ATestLevel���ݒ肳��Ă��܂���B�������I�����܂��B
	echo �����Ȓl���ݒ肳��Ă��邩�ATestLevel���ݒ肳��Ă��܂���B�������I�����܂��B >> "%logfile%
	goto canceldeploy
)
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { get-content -Encoding UTF8 %batch_dir%\log\sfcommandresults.txt | Set-Content %batch_dir%\log\encodedtosjis.txt}"
type %batch_dir%\log\encodedtosjis.txt
type %batch_dir%\log\encodedtosjis.txt >> "%logfile%"

REM deploy���ʊm�F
find "Error" "%batch_dir%\log\encodedtosjis.txt" > nul
if %ERRORLEVEL% == 0 (
	echo deploy����Error���������܂����B�������I�����܂��B
	echo %DATE% %TIME% deploy����Error���������܂����B�������I�����܂��B >> "%logfile%"
	goto :canceldeploy
)
find "Warning" %batch_dir%\log\encodedtosjis.txt > nul
if %ERRORLEVEL% == 0 (
	echo deploy����Warning���������܂����B
	echo %DATE% %TIME% deploy����Warning���������܂����B >> "%logfile%"

	:ask_user
	set /p user_input=�����𑱍s���܂����H (Y/N) 
	if /i "%user_input%"=="Y" (
		echo �����𑱍s���܂��B
		echo %DATE% %TIME% �����𑱍s���܂��B >> "%logfile%"
	) else if /i "%user_input%"=="N" (
		echo �������I�����܂��B
		echo %DATE% %TIME% �������I�����܂��B >> "%logfile%"
		goto :canceldeploy
	) else (
		echo Y �܂��� N ����͂��Ă��������B
		goto :ask_user
	)
)

echo %DATE% %TIME% deploy�����E�E�E
echo %DATE% %TIME% deploy���I���E�E�E >> "%logfile%"

REM  ���s���Ă���o�b�`�t�@�C���̃f�B���N�g���p�X���擾����
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

echo %DATE% %TIME% retrieve���E�E�E
echo %DATE% %TIME% retrieve_after�J�n�E�E�E >> "%logfile%"

REM retrive�����t�H���_���ύX�p�ɍ����̓������擾���Đ��`����
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%

REM retrieve start
Call sf project retrieve start --api-version %SoapApiVersion% --manifest %batch_dir%\retrievemanifest\package.xml --target-metadata-dir %batch_dir%\02.retrieved_after --unzip --target-org %SfUserName% --zip-file-name %today%_%currenttime%_number.zip >> %logfile% 2>&1
if %errorlevel% neq 0 (
	echo %DATE% %TIME% retrieve�����s���܂����B �������I�����܂��B
	echo %DATE% %TIME% retrieve�����s���܂����B �������I�����܂��B >> "%logfile%
	goto canceldeploy
)

REM retrive�����t�H���_�����擾����
set "target_folder=%batch_dir%\02.retrieved_after\%today%_%currenttime%_number"

REM retrive�����t�H���_�̗L���m�F
IF exist "%target_folder%" (
	echo %DATE% %TIME% retrieve�������^�f�[�^���u%target_folder%�v�Ɋi�[���܂����B
	echo %DATE% %TIME% retrieve�������^�f�[�^���u%target_folder%�v�Ɋi�[���܂����B >> "%logfile%
) else (
	echo %DATE% %TIME% retrieve�������^�f�[�^�̊i�[�Ɏ��s���܂����B
	echo %DATE% %TIME% retrieve�������^�f�[�^�̊i�[�Ɏ��s���܂����B >> "%logfile%
	goto canceldeploy
)

echo %DATE% %TIME% retrieve�����E�E�E
echo %DATE% %TIME% retrieve_after�I���E�E�E >> "%logfile%"

REM logout
for /f "delims=" %%i in ('logout_org.bat') do (
	echo %%i >> %logfile%
)

REM authorization info
Call authorization_info_list.bat logout_check > %batch_dir%\log\sfcommandresults.txt
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { get-content -Encoding UTF8 %batch_dir%\log\sfcommandresults.txt | Set-Content %batch_dir%\log\encodedtosjis.txt}"
type %batch_dir%\log\encodedtosjis.txt >> "%logfile%"

:canceldeploy

REM �g�p�ς݃e�L�X�g�t�@�C���폜
if exist %batch_dir%\log\sfcommandresults.txt (
	del %batch_dir%\log\sfcommandresults.txt
)
if exist %batch_dir%\log\encodedtosjis.txt (
	del %batch_dir%\log\encodedtosjis.txt
)

echo %DATE% %TIME% -----End deploy_start.bat-----
echo %DATE% %TIME% -----End deploy_start.bat-----  >> "%logfile%"
:enddeploy
cmd /k