@echo off

echo %DATE% %TIME% -----Start authorization_info_list.bat-----

REM �F�؍ς̑g�D�ꗗ
Call sf org list auth

echo %DATE% %TIME% -----End authorization_info_list.bat-----

if "%~1"=="" (
    rem ���������݂��Ȃ��ꍇ�́Acmd /k�R�}���h�����s
	cmd /k
) else (
    rem ���������݂���ꍇ�́A�Ȃɂ����Ȃ�
)