@echo off

echo %DATE% %TIME% -----Start login_org_sfdx_url.bat-----

REM 実行しているバッチファイルのディレクトリパスを取得する
for %%A in ("%~dp0.") do set "batch_dir=%%~fA"

REM setting.iniを読み込み
for /F "delims== tokens=1,2" %%i in (%batch_dir%\config\setting.ini) do (
  set %%i=%%j
)

REM ログイン開始
Call sf org login sfdx-url --sfdx-url-file %batch_dir%\config\%SfdxAuthUrl% 2>&1

if "%~1"=="" (
    rem 引数が存在しない場合は、cmd /kコマンドを実行
	if %errorlevel% neq 0 (
    	echo Login failed!
	) else (
		echo Login successful
	)
	cmd /k
) else (
    rem 引数が存在する場合は、なにもしない
	if %errorlevel% neq 0 (
    	echo Login failed!
		rem エラーの場合は1を返却
		exit /b 1
	) else (
		echo Login successful
	)
)

echo %DATE% %TIME% -----End login_org_sfdx_url.bat-----