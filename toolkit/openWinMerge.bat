@echo off
setlocal enabledelayedexpansion

echo %DATE% %TIME% -----Start OpenWinMerge.bat-----

rem 01.retrieved_before�t�H���_�̃p�X���w��
set "before_target_folder=%~dp001.retrieved_before"

rem �ŐV�̃t�H���_�p�X���i�[����ϐ���������
set "left_folder="

rem �t�H���_�̈ꗗ���擾���āA�ŐV�̃t�H���_���擾
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

rem �ϐ����󂩂ǂ������m�F
if "%left_folder%"=="" (
    echo 01.retrieved_before���Ƀt�H���_�����݂��܂���B
	goto end
)

rem 02.retrieved_after�t�H���_�̃p�X���w��
set "after_target_folder=%~dp002.retrieved_after"

rem �ŐV�̃t�H���_�p�X���i�[����ϐ���������
set "right_folder="

rem �t�H���_�̈ꗗ���擾���āA�ŐV�̃t�H���_���擾
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

rem �ϐ����󂩂ǂ������m�F
if "%right_folder%"=="" (
    echo 02.retrieved_after���Ƀt�H���_�����݂��܂���B
	goto end
)

echo %DATE% %TIME% WinMerge���N��
cd "C:\Program Files (x86)\WinMerge\"
set "exe_file=WinMergeU.exe"
start "" "%exe_file%" /r /wl /wr "%left_folder%" "%right_folder%"

:end

echo %DATE% %TIME% -----End OpenWinMerge.bat-----