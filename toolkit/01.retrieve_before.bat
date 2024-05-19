@echo off

echo %DATE% %TIME% -----Start 01.retrieve_before.bat-----

REM 組織へのログイン
Call login_org_sfdx_url.bat login

REM エラーおよび戻り値が1の場合は処理終了
if %ERRORLEVEL% equ 1 (
    echo %DATE% %TIME% ログインに失敗しました。 処理を終了します。
	goto end
)

REM 実行しているバッチファイルのディレクトリパスを取得する
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.iniを読み込み
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
  set %%i=%%j
)

echo %DATE% %TIME% retrieve中・・・

REM フォルダ名変更用に今日の日時を取得して整形する
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set today=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set currenttime=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%

REM retrieve start
Call sf project retrieve start --api-version %SoapApiVersion% --manifest %batch_dir%\retrievemanifest\package.xml --target-metadata-dir %batch_dir%\01.retrieved_before --unzip --target-org %SfUserName% --zip-file-name %today%_%currenttime%_number.zip
if %errorlevel% neq 0 (
	echo %DATE% %TIME% retrieveが失敗しました。 処理を終了します。
	goto endwithlogout
)

REM retriveしたフォルダ名を取得する
set "target_folder=%batch_dir%\01.retrieved_before\%today%_%currenttime%_number"

REM retriveしたフォルダの有無確認
IF exist "%target_folder%" (
	echo %DATE% %TIME% retrieveしたメタデータを「%target_folder%」に格納しました。
) else (
    echo %DATE% %TIME% retrieveしたメタデータの格納に失敗しました。処理を終了します。
	goto endwithlogout
)

:endwithlogout

REM 組織からログアウト
Call logout_org.bat

:end

echo -----End 01.retrieve_before.bat-----
cmd /k