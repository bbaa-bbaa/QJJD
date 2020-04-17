@Rem Made By Bbaa
@echo off 2>nul 3>nul
Set ImgName=%~1
Set ReturnName=%~2
:Mirror_Main
Set image=info !ImgName!
Set Size=%image%
for /f "Tokens=1-2" %%i in ("%Size%") do (
	Set X=%%i
	Set Y=%%j
)
Set image=unload !ReturnName!
Set image=buffer !ReturnName!
Set image=stretch !ReturnName! !Size!
Set image=buffer MirrorTmp
Set image=stretch MirrorTmp 1 !Y!
for /l %%i in (0,1,%X%) do (
	Set image=target MirrorTmp
	Set /a MX=0-!X!+%%i+1
	Set image=draw !ImgName! !MX! 0
	Set image=target !ReturnName!
	Set image=draw MirrorTmp %%i 0
)
Set image=unload MirrorTmp
Goto :Eof