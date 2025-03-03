@echo off

:inputdeploy
set /p choice=deployを開始しますか? (Y/N) 
if /i "%choice%"=="Y" (
	goto startdeploy
) else if /i "%choice%"=="N" (
	echo deployを中止しました。
	goto enddeploy
) else (
	echo Y または N を入力してください。
	goto inputdeploy
)

:startdeploy
REM 実行しているバッチファイルのディレクトリパスを取得する
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM logファイル用に今日の日時を取得して整形する
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%
REM logファイル作成
set LogFile=%batch_dir%\log\deploy\deploy_%today%_%currenttime%.log

echo %DATE% %TIME% -----Start deploy_start.bat-----
echo %DATE% %TIME% -----Start deploy_start.bat-----  >> "%logfile%"

REM 組織へのログイン
Call login_org_sfdx_url.bat login >> "%logfile%"

REM エラーおよび戻り値が1の場合は処理終了
if %ERRORLEVEL% equ 1 (
	echo %DATE% %TIME% ログインに失敗しました。 処理を終了します。
	echo %DATE% %TIME% ログインに失敗しました。 処理を終了します。 >> "%logfile%
	goto canceldeploy
)

REM authorization info
Call authorization_info_list.bat logint_check > %batch_dir%\log\sfcommandresults.txt
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { get-content -Encoding UTF8 %batch_dir%\log\sfcommandresults.txt | Set-Content %batch_dir%\log\encodedtosjis.txt}"
type %batch_dir%\log\encodedtosjis.txt >> "%logfile%"

REM setting.iniを読み込み
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
	set %%i=%%j
)

echo %DATE% %TIME% retrieve中・・・
echo %DATE% %TIME% retrieve_before開始・・・ >> "%logfile%

REM フォルダ名変更用に今日の日時を取得して整形する
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%

REM retrieve start
Call sf project retrieve start --api-version %SoapApiVersion% --manifest %batch_dir%\retrievemanifest\package.xml --target-metadata-dir %batch_dir%\01.retrieved_before --unzip --target-org %SfUserName% --zip-file-name %today%_%currenttime%_number.zip >> %logfile% 2>&1
if %errorlevel% neq 0 (
	echo %DATE% %TIME% retrieveが失敗しました。 処理を終了します。
	echo %DATE% %TIME% retrieveが失敗しました。 処理を終了します。 >> "%logfile%
	goto canceldeploy
)

REM retriveしたフォルダ名を取得する
set "target_folder=%batch_dir%\01.retrieved_before\%today%_%currenttime%_number"

REM retriveしたフォルダの有無確認
IF exist "%target_folder%" (
	echo %DATE% %TIME% retrieveしたメタデータを「%target_folder%」に格納しました。
	echo %DATE% %TIME% retrieveしたメタデータを「%target_folder%」に格納しました。 >> "%logfile%
) else (
	echo %DATE% %TIME% retrieveしたメタデータの格納に失敗しました。処理を終了します。
	echo %DATE% %TIME% retrieveしたメタデータの格納に失敗しました。処理を終了します。 >> "%logfile%
	goto canceldeploy
)

echo %DATE% %TIME% retrieve完了・・・
echo %DATE% %TIME% retrieve_before終了・・・ >> "%logfile%

echo %DATE% %TIME% deploy中・・・
echo %DATE% %TIME% deployを開始・・・ >> "%logfile%"

REM testclasslistファイルのパスを指定
set "file_path=testclasslist.txt"
REM 変数にtestclasslistファイルの内容を読み込む
for /f "usebackq tokens=* delims=" %%a in ("%file_path%") do (
    set "testclass=%%a"
)

REM deploy start
if "%TestLevel%" == "RunAllTestsInOrg" (
	echo 組織内のすべてのテストを実行します。 >> "%logfile%
	Call sf project deploy start --api-version %SoapApiVersion% --metadata-dir %batch_dir%\deploycodepkg --test-level %TestLevel% --target-org %SfUserName% > %batch_dir%\log\sfcommandresults.txt 2>&1
) else if "%TestLevel%" == "RunSpecifiedTests" (
	echo deploy用にテストクラス「%testclass%」を指定しました。 >> "%logfile%
	Call sf project deploy start --api-version %SoapApiVersion% --metadata-dir %batch_dir%\deploycodepkg --test-level %TestLevel% --tests %testclass% --target-org %SfUserName% > %batch_dir%\log\sfcommandresults.txt 2>&1
) else (
	echo 無効な値が設定されているか、TestLevelが設定されていません。処理を終了します。
	echo 無効な値が設定されているか、TestLevelが設定されていません。処理を終了します。 >> "%logfile%
	goto canceldeploy
)
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { get-content -Encoding UTF8 %batch_dir%\log\sfcommandresults.txt | Set-Content %batch_dir%\log\encodedtosjis.txt}"
type %batch_dir%\log\encodedtosjis.txt
type %batch_dir%\log\encodedtosjis.txt >> "%logfile%"

REM deploy結果確認
find "Error" "%batch_dir%\log\encodedtosjis.txt" > nul
if %ERRORLEVEL% == 0 (
	echo deploy時にErrorが発生しました。処理を終了します。
	echo %DATE% %TIME% deploy時にErrorが発生しました。処理を終了します。 >> "%logfile%"
	goto :canceldeploy
)
find "Warning" %batch_dir%\log\encodedtosjis.txt > nul
if %ERRORLEVEL% == 0 (
	echo deploy時にWarningが発生しました。
	echo %DATE% %TIME% deploy時にWarningが発生しました。 >> "%logfile%"

	:ask_user
	set /p user_input=処理を続行しますか？ (Y/N) 
	if /i "%user_input%"=="Y" (
		echo 処理を続行します。
		echo %DATE% %TIME% 処理を続行します。 >> "%logfile%"
	) else if /i "%user_input%"=="N" (
		echo 処理を終了します。
		echo %DATE% %TIME% 処理を終了します。 >> "%logfile%"
		goto :canceldeploy
	) else (
		echo Y または N を入力してください。
		goto :ask_user
	)
)

echo %DATE% %TIME% deploy完了・・・
echo %DATE% %TIME% deployを終了・・・ >> "%logfile%"

REM  実行しているバッチファイルのディレクトリパスを取得する
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

echo %DATE% %TIME% retrieve中・・・
echo %DATE% %TIME% retrieve_after開始・・・ >> "%logfile%"

REM retriveしたフォルダ名変更用に今日の日時を取得して整形する
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%

REM retrieve start
Call sf project retrieve start --api-version %SoapApiVersion% --manifest %batch_dir%\retrievemanifest\package.xml --target-metadata-dir %batch_dir%\02.retrieved_after --unzip --target-org %SfUserName% --zip-file-name %today%_%currenttime%_number.zip >> %logfile% 2>&1
if %errorlevel% neq 0 (
	echo %DATE% %TIME% retrieveが失敗しました。 処理を終了します。
	echo %DATE% %TIME% retrieveが失敗しました。 処理を終了します。 >> "%logfile%
	goto canceldeploy
)

REM retriveしたフォルダ名を取得する
set "target_folder=%batch_dir%\02.retrieved_after\%today%_%currenttime%_number"

REM retriveしたフォルダの有無確認
IF exist "%target_folder%" (
	echo %DATE% %TIME% retrieveしたメタデータを「%target_folder%」に格納しました。
	echo %DATE% %TIME% retrieveしたメタデータを「%target_folder%」に格納しました。 >> "%logfile%
) else (
	echo %DATE% %TIME% retrieveしたメタデータの格納に失敗しました。
	echo %DATE% %TIME% retrieveしたメタデータの格納に失敗しました。 >> "%logfile%
	goto canceldeploy
)

echo %DATE% %TIME% retrieve完了・・・
echo %DATE% %TIME% retrieve_after終了・・・ >> "%logfile%"

REM logout
for /f "delims=" %%i in ('logout_org.bat') do (
	echo %%i >> %logfile%
)

REM authorization info
Call authorization_info_list.bat logout_check > %batch_dir%\log\sfcommandresults.txt
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { get-content -Encoding UTF8 %batch_dir%\log\sfcommandresults.txt | Set-Content %batch_dir%\log\encodedtosjis.txt}"
type %batch_dir%\log\encodedtosjis.txt >> "%logfile%"

:canceldeploy

REM 使用済みテキストファイル削除
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