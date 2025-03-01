@echo off

echo %DATE% %TIME% -----Start logout_org.bat-----

REM 実行しているバッチファイルのディレクトリパスを取得する
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.iniを読み込み
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
	set %%i=%%j
)

REM ログアウト
Call sf org logout --target-org %SfUserName% -p

echo %DATE% %TIME% -----End logout_org.bat-----