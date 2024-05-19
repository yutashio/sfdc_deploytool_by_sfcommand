@echo off

echo %DATE% %TIME% -----Start authorization_info_list.bat-----

REM 認証済の組織一覧
Call sf org list auth

echo %DATE% %TIME% -----End authorization_info_list.bat-----

if "%~1"=="" (
    rem 引数が存在しない場合は、cmd /kコマンドを実行
	cmd /k
) else (
    rem 引数が存在する場合は、なにもしない
)