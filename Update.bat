@echo off 2>nul 3>nul
setlocal enabledelayedexpansion
@Path %~dp0Tools;%Path%
Set /p "Version="<SSSS_Version.txt
echo ■
echo 检查更新中...
del /f /q Version.txt>nul 2>nul
Wget -T 5 -t 1 -q -O Version.txt "http://file.blankwings.cn/files/SSSS_Version.txt">nul 2>nul&&(
pause
	cls
	echo ■■■■■■■■
	echo 校验版本...
	Set /p NVersion=<Version.txt
	del /f /q Version.txt>nul 2>nul
	if Not "!NVersion!"=="!Version!" (
		cls 
		echo ■■■■■■■■■■■■■■
		echo 发现新版本!
		echo 开始为您下载...
		Wget  -T 60 -t 2 -O Update.rar "http://file.blankwings.cn/files/SSSS_Update.rar"&&(
			cls
			echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
			echo 解压中
			rar x -O+ Update.rar&del /f /q Update.rar&exit
		)
	) else (
		Echo 没有新版
		cls
	)
)
Endlocal
Goto :Eof