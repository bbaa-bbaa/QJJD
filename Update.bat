@echo off 2>nul 3>nul
setlocal enabledelayedexpansion
@Path %~dp0Tools;%Path%
Set /p "Version="<SSSS_Version.txt
echo ��
echo ��������...
del /f /q Version.txt>nul 2>nul
Wget -T 5 -t 1 -q -O Version.txt "http://file.blankwings.cn/files/SSSS_Version.txt">nul 2>nul&&(
pause
	cls
	echo ����������������
	echo У��汾...
	Set /p NVersion=<Version.txt
	del /f /q Version.txt>nul 2>nul
	if Not "!NVersion!"=="!Version!" (
		cls 
		echo ����������������������������
		echo �����°汾!
		echo ��ʼΪ������...
		Wget  -T 60 -t 2 -O Update.rar "http://file.blankwings.cn/files/SSSS_Update.rar"&&(
			cls
			echo ����������������������������������������������������������������
			echo ��ѹ��
			rar x -O+ Update.rar&del /f /q Update.rar&exit
		)
	) else (
		Echo û���°�
		cls
	)
)
Endlocal
Goto :Eof