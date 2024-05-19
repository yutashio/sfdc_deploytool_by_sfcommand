@echo off
setlocal enabledelayedexpansion

echo %DATE% %TIME% -----Start OpenWinMerge.bat-----

rem 01.retrieved_beforeフォルダのパスを指定
set "before_target_folder=%~dp001.retrieved_before"

rem 最新のフォルダパスを格納する変数を初期化
set "left_folder="

rem フォルダの一覧を取得して、最新のフォルダを取得
for /d %%I in ("%before_target_folder%\*") do (
    set "current_folder=%%~fI"
    if not defined left_folder (
        set "left_folder=!current_folder!"
    ) else (
        for %%A in ("!current_folder!") do (
            for %%B in ("!left_folder!") do (
                if %%~tA gtr %%~tB (
                    set "left_folder=!current_folder!"
                )
            )
        )
    )
)

rem 変数が空かどうかを確認
if "%left_folder%"=="" (
    echo 01.retrieved_before内にフォルダが存在しません。
	goto end
)

rem 02.retrieved_afterフォルダのパスを指定
set "after_target_folder=%~dp002.retrieved_after"

rem 最新のフォルダパスを格納する変数を初期化
set "right_folder="

rem フォルダの一覧を取得して、最新のフォルダを取得
for /d %%I in ("%after_target_folder%\*") do (
    set "current_folder=%%~fI"
    if not defined right_folder (
        set "right_folder=!current_folder!"
    ) else (
        for %%A in ("!current_folder!") do (
            for %%B in ("!right_folder!") do (
                if %%~tA gtr %%~tB (
                    set "right_folder=!current_folder!"
                )
            )
        )
    )
)

rem 変数が空かどうかを確認
if "%right_folder%"=="" (
    echo 02.retrieved_after内にフォルダが存在しません。
	goto end
)

echo %DATE% %TIME% WinMergeを起動
cd "C:\Program Files (x86)\WinMerge\"
set "exe_file=WinMergeU.exe"
start "" "%exe_file%" /r /wl /wr "%left_folder%" "%right_folder%"

:end

echo %DATE% %TIME% -----End OpenWinMerge.bat-----