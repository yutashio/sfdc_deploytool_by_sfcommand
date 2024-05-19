@echo off

echo %DATE% %TIME% 初回組織への認証・ログインとSfdxAuthUrlの確認

REM 実行しているバッチファイルのディレクトリパスを取得する
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.iniを読み込み
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
  set %%i=%%j
)

REM salseforceへログイン chromeで開く
Call sf org login web --instance-url %SfMyDomain% --browser chrome

if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% login時にErrorが発生しました。処理を終了します。
	pause
    goto :end
)

REM Sfdx Auth Url確認
Call sf org display --target-org %SfUserName% --verbose

if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% 組織の情報表示時にErrorが発生しました。処理を終了します。
    pause
	goto :end
) else {
	pause
}

Call logout_org.bat

:end