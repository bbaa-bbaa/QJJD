@Rem Made By TJU And Bbaa
%1start /max "Win7Font" "%~dp0cmd.exe" "/c %~fs0 :"&exit
@echo off 2>nul 3>nul
mode con cols=120 lines=48
setlocal enabledelayedexpansion
Set SettingDFS_DebugMode=1|| REM 1��ʾ��������0����ʾ
if !SettingDFS_DebugMode!==1 (
  set SettingDFS_Mode=Main
) else (
  set SettingDFS_Mode=DFS_Main
)
@Path %~dp0Tools;%Path%
@Curs /crv 0
ver|find "10.">nul 2>nul&&(
  reg query HKCU\Console\Win7Font>nul 2>nul|| (
    echo ��⵽����windows10ϵͳ
    echo �뵼��win10.reg�ʹ����þɰ����̨��������Ϸ
    echo �����������
    pause>nul
  )
  Set Windows10=True
)
if not exist level.txt (
  >level.txt echo 1
)
Call Update.bat
Rem 2018/01/31 ��Ŀ��ʼ����
Rem 2018/02/03 ����ܹ���д
:Draw_Title
Rem ����UI
Set image=load UI\Cover.bmp cover
Set image=load UI\title.bmp title
Set image=load UI\main.bmp main
Set image=load UI\pvpmode.bmp pvpmode
Set image=load UI\storymode.bmp storymode
Set image=load UI\choice.bmp choice
Set image=load UI\nochoice.bmp nochoice
Set image=draw title 0 0
Pause>nul
:Draw_Menu
Cls
Set choice=pvp
Set image=draw main 0 0
Set image=draw pvpmode 80 550 trans
Set image=draw storymode 80 650 trans
Set image=draw choice 40 560 trans
Set image=draw nochoice 40 660 trans
title W��Sѡ��Jȷ��
:Menu_Choose
choice /c wsjh /n >nul
if %errorlevel%==1 (
  if %choice%==story (
  Set choice=pvp
  Set image=draw choice 40 560 trans
  Set image=draw nochoice 40 660 trans
  )
)
if %errorlevel%==2 (
  if %choice%==pvp (
  Set choice=story
  Set image=draw nochoice 40 560 trans
  Set image=draw choice 40 660 trans
  )
)
if %errorlevel%==3 (
  if %choice%==pvp (
  Echo �ݲ����ţ�
  Pause
  cls
  Goto Draw_menu
  )
  if %choice%==story (
  goto :Setting
  )
)
if %errorlevel%==4 (
Call :Help
)
goto Menu_Choose
:Setting
cls
Set image=draw cover 0 0
Set /p map=<level.txt
Set CustomIndex=1
for /f %%i in ('dir /a:d /b �Զ��ؿ�') do (
  echo N!CustomIndex!.%%i
  Set CustomN!CustomIndex!=%%i
  Set /a CustomIndex+=1
)

Echo                                                ������������Ĺؿ�:
set /p stagechoose=                                            Stage��
if "!stagechoose:~0,1!"=="N" (
  if not defined Custom!stagechoose! (
    goto :Setting
  )
  Set "�Զ��ؿ�=True"
  Set "map=�Զ�:!Custom%stagechoose%!"
  Set "�Զ��ؿ���=!Custom%stagechoose%!"
) else (
  if "%map%" geq "%stagechoose%" (
    if "%stagechoose%" geq "1" (
      set "map=%stagechoose%"
    )
  ) else (
    echo ������Ĺؿ���δ����
    echo ����Ϊ����ת��������������һ��
    ping -n 2 127.0.0.1>nul 2>nul
  )
)
cls
if exist "�ֱ���ѹ��" (
  Set /p "�Զ���ֱ���="<�ֱ���ѹ��
)
Set "image=target cmd"
Set "image=cls"
Set "image=unload Main"
Set "image=buffer Main"||Rem ����Ⱦ��
Set "image=stretch Main 960 704"
Set "image=unload Space"
Set "image=buffer Space"
Set "image=stretch Space 64 64"
Set "SelectType=select"
Set "�޷�ͨ�еķ���ID=2,3,6,8,9,17"
Set SelectX=0
Set SelectY=0
Set "�з�Ѱ·ָ��=15"
:LoadLevel
setlocal
cls
Set ��Ⱦ����=0
Set �غ���=1
Set "�غ�=��λ�ƶ�"
Set EnityId=
Set �з�EnityId=
Set "PostiveAI=disable"
title �ؿ�:!map! �����������
if Not "!�Զ��ؿ�!"=="True" (
  For /f "delims=" %%i in (./maps/Story%map%.txt) do (
    echo;%%i
    pause>nul
  )
  if exist ./maps/%map%.env (
    for /f "delims=" %%i in (./maps/%map%.env) do (
      Set "%%~i"
    )
  )
) else (
  For /f "delims=" %%i in (./�Զ��ؿ�/%�Զ��ؿ���%/Story.txt) do (
    echo;%%i
    pause>nul
  )
  if exist ./�Զ��ؿ�/%�Զ��ؿ���%/%�Զ��ؿ���%.env (
    for /f "delims=" %%i in (./�Զ��ؿ�/%�Զ��ؿ���%/%�Զ��ؿ���%.env) do (
      Set "%%~i"
    )
  )
)
cls
Title ��Ϸ������.........
cls
echo ��������������
echo ���ص�λ����...
Call :LoadPlayer||Rem ���ص�λ
cls
echo ��������������������������������������
echo Ԥ����ͼƬ...
Call :LoadImage||Rem ����ͼƬ
cls
echo ��������������������������������������������������������������������������������
echo ���ص�ͼ...
Call :LoadMap_New||Rem ���ص�ͼ
cls
echo ��������������������������������������������������������������������������������������������
echo ���Ƶ�λ��...
Call :��ʼ��Ѫ����ͼ��
Call :Buf_Player||Rem ���ص�λ���Ӳ�
cls
echo ����������������������������������������������������������������������������������������������������������������������
echo OK!
pause
:Main
Set /a ��Ⱦ����+=1
Set "image=unload Main"
Set "image=buffer Main"||Rem ����Ⱦ��
Set "image=stretch Main 960 704"
if Not "!�Զ��ؿ�!"=="True" (
  if "%map%"=="1" (
    if !�غ���! gtr 20 (
      Echo �㳬����20�غϣ�������
      Goto :Lose
    )
  )
  if "%map%"=="2" (
    if !�غ���! gtr 15 (
      Echo ��ϲ��������15�غ�
      Goto :Win
    )
  )
)
if Not "!Windows10!"=="True" (
  cls
) else (
  Curs /pos 0 0
  for /l %%i in (0,1,4) do (
    echo;                                                                                                                                                                                                         
  )
  Curs /pos 0 0
)
if exist "�ֱ���ѹ��" (
  Set "image=resize Main %�Զ���ֱ���%"
)
Call :Show Map 0 0||Rem ��ʾ��ͼ������Ⱦ��
Call :Show Player trans||Rem ��ʾ��λ������Ⱦ��
Call :Show BufHealth trans
if "!�غ�!"=="��λ�ƶ�" (
  Set "�з�EnityId="
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!�غ�!"=="��λ����ѡ��" (
  Set "SelectType=decideselect"
  Set "�غ�=��λ����ѡ��"
  Call :Main_AttackSelect||Rem ���㹥����Χ
  Call :Show AttackSelect trans
) else if "!�غ�!"=="��λ����ѡ��" (
  Call :Show AttackSelect trans
) else if "!�غ�!"=="�з��ƶ���ʼ_DFS" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!�غ�!"=="DFS_Main" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!�غ�!"=="�з��ƶ�AI����" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!�غ�!"=="�з�����_ѡ�񶯻�" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show AttackSelect trans
  )
)
Set /a "ShowSelectX=!SelectX!*64"
Set /a "ShowSelectY=!SelectY!*64"
Call :Show Img%SelectType% trans !ShowSelectX! !ShowSelectY!||Rem ��ʾѡ����
if exist "�ֱ���ѹ��" (
  Set "image=stretch Main !�Զ���ֱ���!"
)
Call :Show Main 0 64||Rem ��������Ⱦ��
Set block=
Set "block=!MapList_%SelectX%_%SelectY%!"
set "����="
set "����="
if "%block%"=="0" (
  set ����=ƽԭ
  set ����=��ͨ��
)
if "%block%"=="1" (
  set ����=�ߵ�
  set ����=�ڴ˵صĵ�λ��̰뾶+1
)
if "%block%"=="2" (
  set ����=��ɽ
  set ����=�޷�ͨ��
)
if "%block%"=="3" (
  set ����=ˮ��
  set ����=�޷�ͨ��
)
if "%block%"=="4" (
  set ����=�������
  set ����=�ڴ˵صĵ�λ������+1
)
if "%block%"=="5" (
  set ����=����
  set ����=��ͨ��
)
if "%block%"=="6" (
  set ����=��ά�ռ�
  set "����=error on Line 32768:wrong with 'null'"
) else if "%block%"=="" (
  set ����=��ά�ռ�
  set "����=error on Line 32768:wrong with 'null'"
)
if "%block%"=="7" (
  set ����=�ݵ�
  set ����=��ͨ��
)
if "%block%"=="8" (
  set ����=ɭ��
  set ����=����ͨ��
)
if "%block%"=="9" (
  set ����=��ɽ
  set ����=����ͨ��
)
if "%block%"=="10" (
  set ����=����
  set ����=�ڴ˵صĵ�λ��̰뾶+1
)
if "%block%"=="11" (
  set ����=����
  set ����=�������λפ���ĵ�λÿ�غϻָ�1����
)
if "%block%"=="12" (
  set ����=����
  set ����=��ͨ��
)
if "%block%"=="13" (
  set ����=�������
  set ����=�ڴ˵صĵ�λ������+1
)
if "%block%"=="15" (
  set ����=�ػ�
  set ����=Arknights ������
)
if "%block%"=="16" (
  set ����=ѩ��
  set ����=��������-1 ���20%��������
)
if "%block%"=="6" (
  set ����=ѩɽ
  set ����=�޷�ͨ��
)
Set "SPlayer_Id="
if defined Player_%SelectX%_%SelectY% (
  Set "SPlayer_Id=!Player_%SelectX%_%SelectY%!"
)
if defined SPlayer_Id (
  Set "��λ��Ϣ=����:!NamePlayer_%SPlayer_Id%_����! Ѫ��:!NamePlayer_%SPlayer_Id%_Ѫ��! ��Ӫ:!NamePlayer_%SPlayer_Id%_��Ӫ!"
) else (
  Set "��λ��Ϣ=�˴��޵�λ"
)
echo;����:%����% ����:%����% %��λ��Ϣ%
echo;��ǰ����:x:%SelectX% y:%SelectY%
echo;�ؿ�:!map! �غ�:!�غ�! �غ���:!�غ���!  ʣ��з���λ:!�з���λ����! ʣ���ҷ���λ:!�ҷ���λ����!
if defined MoreText (
  for %%a in (%MoreText%) do (
    echo;%%a
  )
  Set "MoreText="
)
If Not "!�غ�:~0,2!"=="�з�" (
  if Not "!�غ�:~0,3!"=="DFS" (
    Goto :KeyDown
  )
) else (
  if "!�غ�!"=="�з��ƶ�" (
    Goto :�з��ƶ�
  ) else if "!�غ�!"=="�з��ƶ���ʼ" (
    Goto :�з��ƶ���ʼ
  ) else if "!�غ�!"=="�з��ƶ�AI����" (
    Goto :�з��ƶ�AI����
  ) else if "!�غ�!"=="�з��ƶ�ѡ��" (
    Goto :�з��ƶ�ѡ��
  ) else if "!�غ�!"=="�з�����ѡ��"  (
    Goto :�з�����ѡ��
  ) else if "!�غ�!"=="�з�����_ѡ�񶯻�" (
    Goto :�з�����_ѡ�񶯻�
  ) else if "!�غ�!"=="�з�����_����˺�" (
    Goto :�з�����_����˺�
  )
)
Goto :!�غ�!
:Main_MoveA
If "%SelectX%"=="!NamePlayer_%EnityId%_X!" (
  If "%SelectY%"=="!NamePlayer_%EnityId%_Y!" (
    echo ��Ҫ�ƶ��������ԭ�ش���������ѡ��������λ[d,q]��
    choice /c dq /n>nul 2>nul
    if errorlevel 2 (
      set "SelectType=select"
      Set "�غ�=��λ�ƶ�"
      Goto Main
    ) else (
      set "SelectType=select"
      Set "�غ�=��λ����ѡ��"
      Goto Main
    )
  )
)  2>nul
Set "SelectType=select"
Call :��λ�ƶ� !NamePlayer_%EnityId%_X! !NamePlayer_%EnityId%_Y! !SelectX! !SelectY!
Call :�ƶ�Ѫ���� !NamePlayer_%EnityId%_X! !NamePlayer_%EnityId%_Y! !SelectX! !SelectY! !NamePlayer_%EnityId%_����!
Set "Player_!NamePlayer_%EnityId%_X!_!NamePlayer_%EnityId%_Y!="
Set "NamePlayer_!EnityId!_X=!SelectX!"
Set "NamePlayer_!EnityId!_Y=!SelectY!"
Set "Player_!SelectX!_!SelectY!=!EnityId!"
Set "�غ�=��λ����ѡ��"
Goto :Main
:Main_MoveSelect
Set "image=unload MoveSelect"
Set image=buffer MoveSelect||Rem �ٽ���buf �ô���
Set image=stretch MoveSelect 960 704
Set image=target MoveSelect
Set "EnityId=!Player_%SelectX%_%SelectY%!"
Set "EnityId_�ƶ�����=!NamePlayer_%EnityId%_�ƶ�����!"
Set /a "EnityId_�ƶ���ʼX=!SelectX!-!EnityId_�ƶ�����!"
Set /a "EnityId_�ƶ���ʼY=!SelectY!-!EnityId_�ƶ�����!"
Set /a "EnityId_�ƶ�����X=!SelectX!+!EnityId_�ƶ�����!"
Set /a "EnityId_�ƶ�����Y=!SelectY!+!EnityId_�ƶ�����!"
for /l %%a in (%EnityId_�ƶ���ʼY%,1,%EnityId_�ƶ�����Y%) do (
  for /l %%b in (%EnityId_�ƶ���ʼX%,1,%EnityId_�ƶ�����X%) do (
    Set "IsWalk=True"
    for %%c in (%�޷�ͨ�еķ���ID%) do (
      if "!MapList_%%b_%%a!"=="%%c" (
        Set "IsWalk=False"
      )
    )
    if "!IsWalk!"=="True" (
      if not defined Player_%%b_%%a (
        Set /a "DrawDecideSelectX=%%b*64"
        Set /a "DrawDecideSelectY=%%a*64"
        Set "image=draw Imgmoverange !DrawDecideSelectX! !DrawDecideSelectY!"
      )
    )
  )
) 2>nul
Set image=target cmd
Goto :Main
:Main_AttackSelect
Rem TJU:��ȫ�հ�bbaa�ƶ������˼·
Set "EnityId=!Player_%SelectX%_%SelectY%!"
Set "image=unload AttackSelect"
Set image=buffer AttackSelect||Rem �ٽ���buf �ô���
Set image=stretch AttackSelect 960 704
Set image=target AttackSelect
Set "EnityId=!Player_%SelectX%_%SelectY%!"
If !MapList_%SelectX%_%SelectY%!==1 (
  Set /a "EnityId_��������=!NamePlayer_%EnityId%_��������!+1"
) else if !MapList_%SelectX%_%SelectY%!==10 (
  Set /a "EnityId_��������=!NamePlayer_%EnityId%_��������!+1"
) else if !MapList_%SelectX%_%SelectY%!==16 (
  Set /a "EnityId_��������=!NamePlayer_%EnityId%_��������!-1"
) else (
  Set "EnityId_��������=!NamePlayer_%EnityId%_��������!"
)
Set "EnityId_X=!SelectX!"
Set "EnityId_X=!SelectY!"
Set /a "EnityId_������ʼX=!SelectX!-!EnityId_��������!"
Set /a "EnityId_������ʼY=!SelectY!-!EnityId_��������!"
Set /a "EnityId_��������X=!SelectX!+!EnityId_��������!"
Set /a "EnityId_��������Y=!SelectY!+!EnityId_��������!"
Set /a "EnityId_�˺�=!NamePlayer_%EnityId%_�˺�!"
Set /a "�ɹ�����λ����=0"
for /l %%a in (%EnityId_������ʼY%,1,%EnityId_��������Y%) do (
  for /l %%b in (%EnityId_������ʼX%,1,%EnityId_��������X%) do (
    if defined Player_%%b_%%a (
      Call :Get_Ver TmpEnityId Player_%%b_%%a
      Call :Get_Ver TmpEnityId NamePlayer_!TmpEnityId!_��Ӫ
      if "!TmpEnityId!"=="�з�" (
        Set /a �ɹ�����λ����+=1
        Set /a "DrawAttackSelectX=%%b*64"
        Set /a "DrawAttackSelectY=%%a*64"
        Set "image=draw Imgattackrange !DrawAttackSelectX! !DrawAttackSelectY!"
      )
    )
  )
) 2>nul
Set image=target cmd
if !�ɹ�����λ����!==0 (
  REM û�п� ���� ��λʱ������
  set "SelectType=select"
  Set "�غ�=�з��ƶ�"
)
Goto :Eof
Rem �����Ƿ�����
:LoadPlayer
Rem ����Player��Ϣ
Set ��λ����=0
Set �з���λ����=0
Set �ҷ���λ����=0
Set "����ļ���=./maps/mapdata/map%map%/Players.csv"
if "!�Զ��ؿ�!"=="True" (
  Set "����ļ���=./�Զ��ؿ�/%�Զ��ؿ���%/Players.csv"
)
for /f "eol=# Tokens=1-10 delims=," %%a in (%����ļ���%) do (
  if %%d gtr 0 (
    Set /a ��λ����+=1
    Set "Player_%%a_%%b=!��λ����!"
    Set "NamePlayer_!��λ����!_X=%%a"
    Set "NamePlayer_!��λ����!_Y=%%b"
    Set "NamePlayer_!��λ����!_����=%%c"
    Set "NamePlayer_!��λ����!_Ѫ��=%%d"
    Set "NamePlayer_!��λ����!_��Ѫ��=%%d"
    Set "NamePlayer_!��λ����!_����=%%e"
    if /i "%%f"=="e" (
      Set "NamePlayer_!��λ����!_��Ӫ=�з�"
      Set /a �з���λ����+=1
      Set "�з���λ_!�з���λ����!=!��λ����!"
    ) else (
      Set "NamePlayer_!��λ����!_��Ӫ=�ҷ�"
      Set /a �ҷ���λ����+=1
      Set "�ҷ���λ_!�ҷ���λ����!=!��λ����!"
    )
    Set "NamePlayer_!��λ����!_��������=%%g"
    Set "NamePlayer_!��λ����!_�ƶ�����=%%h"
    Set "NamePlayer_!��λ����!_�˺�=%%i"
    Set "NamePlayer_!��λ����!_����=%%j"
    Set "NamePlayer_!��λ����!_����=False"
  )
)
Goto :eof
:LoadImage
Rem ��������ͼƬ ������
cd image 2>nul
for %%a in (*.bmp) do (
  Set "image=load %%~nxa Img%%~na"
  Call Mirror Img%%~na MirrorImg%%~na
)
Set "image=target cmd"
cd.. 2>nul
Goto :Eof
:LoadMap_New
Rem ���ص�ͼ
Set "image=unload Map"
Set "image=buffer Map"||Rem �½�����ͼ������-ֱ�Ӵ洢��ͼ
Set "image=stretch Map 960 704"
Set "image=target Map"
Set MapX=0
Set MapY=0
Set MapSizeX=0
Set MapSizeY=-1
Rem ֮ǰ����Ƿ��
if Not "!�Զ��ؿ�!"=="True" (
  for /f "delims=" %%a in (./maps/%map%.map) do (
    Set MapX=0
    for %%b in (%%a) do (
      Set /a Draw_MapX=!MapX!*64
      Set /a Draw_MapY=!MapY!*64
      Set "image=draw Img%%b !Draw_MapX! !Draw_MapY!"
      Set "MapList_!MapX!_!MapY!=%%b"
      Set /a MapX+=1
    )
    Set /a MapY+=1
    Set /a MapSizeY+=1
  )
) else (
  for /f "delims=" %%a in (./�Զ��ؿ�/%�Զ��ؿ���%/Main.map) do (
    Set MapX=0
    for %%b in (%%a) do (
      Set /a Draw_MapX=!MapX!*64
      Set /a Draw_MapY=!MapY!*64
      Set "image=draw Img%%b !Draw_MapX! !Draw_MapY!"
      Set "MapList_!MapX!_!MapY!=%%b"
      Set /a MapX+=1
    )
    Set /a MapY+=1
    Set /a MapSizeY+=1
  )
)
Set /a MapSizeX=!MapX!-1
Set "image=target cmd"
Goto :Eof
:Buf_Player
Rem ����Player���Ӳ�
Set "image=unload Player"
Set "image=buffer Player"
Set "image=stretch Player 960 704"
Set "image=target Player"
Set Player 1>var/Player.env
for /f "delims== Tokens=1-2" %%a in (var/Player.env) do (
  Set /a "ShowPlayer_X=!NamePlayer_%%b_X!*64" 
  Set /a "ShowPlayer_Y=!NamePlayer_%%b_Y!*64"
  Call :����Ѫ���� %%b
  Set "image=target Player"
  if /i "!NamePlayer_%%b_����!"=="True" (
    Set "image=draw MirrorImg!NamePlayer_%%b_����! !ShowPlayer_X! !ShowPlayer_Y! trans"
  ) else (
    Set "image=draw Img!NamePlayer_%%b_����! !ShowPlayer_X! !ShowPlayer_Y! trans"
  )
  if "!�з���λ����!"=="0" (
    Goto :Win
  )
  if "!�ҷ���λ����!"=="0" (
    Goto :Lose
  )
) 2>nul
Set "image=target cmd"
Goto :eof
:Show
Rem Show���� ���÷�ʽ Call :Show Buffer�� [trans] [x] [y]
if "%~3"=="" (
  Set "DrawMainX=0"
  Set "DrawMainY=0"
) else (
  if "%~2"=="trans" (
    Set "DrawMainX=%~3"
    Set "DrawMainY=%~4"
  ) else (
    Set "DrawMainX=%~2"
    Set "DrawMainY=%~3"
  )
)
Set "BufName=%~1"
if Not "!BufName!"=="Main" (
  Set "image=target Main"
) else (
  Set "image=target cmd"
)
Title ����ʱ�� draw !BufName! !DrawMainX! !DrawMainY! �غ�:!�غ�! �غ���:!�غ���! ��Ⱦ����:!��Ⱦ����!
if "%~2"=="trans" (
  Set "image=draw !BufName! !DrawMainX! !DrawMainY! trans"
) else (
  Set "image=draw !BufName! !DrawMainX! !DrawMainY!"
)
if Not "!BufName!"=="Main" (
  Set "image=target cmd"
)
Goto :Eof
:KeyDown
choice /c wsadj /n>nul 2>nul
if !errorlevel!==1 (
  Rem Up
  if !SelectY! geq 1 (
    Set /a "SelectY-=1"
    if /i "!�غ�!"=="��λ�ƶ�" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectY+=1"
        )
      )
    ) else (
      if "%�غ�%"=="��λ����ѡ��" (
        Call :IsAttackMove
        if "!IsAttackMove!"=="False" (
          Set /a "SelectY+=1"
        )
      )
    )
  )
)
if  !errorlevel!==2 (
Rem �����ѡ��λģʽ
  Rem Down
  if !SelectY! lss !MapSizeY! (
    Set /a "SelectY+=1"
    Rem ������ƶ�ģʽ
    if /i "!�غ�!"=="��λ�ƶ�" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectY-=1"
        )
      )
    ) else (
      Rem ����ǹ���ģʽ
      if "%�غ�%"=="��λ����ѡ��" (
        Call :IsAttackMove
        if "!IsAttackMove!"=="False" (
          Set /a "SelectY-=1"
        )
      )
    )
  )
)
if  !errorlevel!==3 (
  Rem Left
  if !SelectX! gtr 0 (
    Set /a "SelectX-=1"
    if /i "!�غ�!"=="��λ�ƶ�" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectX+=1"
        )
      )
    ) else (
      if "%�غ�%"=="��λ����ѡ��" (
        Call :IsAttackMove
        if "!IsAttackMove!"=="False" (
          Set /a "SelectX+=1"
        )
      )
    )
  )
)
if !errorlevel!==4 (
  Rem Right
  if !SelectX! lss !MapSizeX! (
    Set /a "SelectX+=1"
    if /i "!�غ�!"=="��λ�ƶ�" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectX-=1"
        )
      )
    ) else (
      if "%�غ�%"=="��λ����ѡ��" (
        Call :IsAttackMove
        if "!IsAttackMove!"=="False" (
          Set /a "SelectX-=1"
        )
      )
    )
  )
)
if !errorlevel!==5 (
  Rem ѡ��
  if /i "!SelectType!"=="Select" (
    if defined Player_%SelectX%_%SelectY% (
      if !NamePlayer_%SPlayer_Id%_��Ӫ!==�ҷ� (
        Set "SelectType=decideselect"
        Goto :Main_MoveSelect
      ) else (
        Set "MoreText=!MoreText!��ѡ�еĿ��ܲ�����һ���ҷ���λ,"
      )
    ) else (
      Set "MoreText=!MoreText!��û��ѡ��λ"
    )
  ) else (
    if "!�غ�!"=="��λ�ƶ�" (
      Call :IsWalk
      if "!IsWalk!"=="True" (
        Goto :Main_MoveA
      )
      Set "MoreText=!MoreText!����ܳ�����ѡ��ı߽�,"
    )
  )
  If "%�غ�%"=="��λ����ѡ��" (
      if "!NamePlayer_%SPlayer_Id%_��Ӫ!"=="�з�" (
        Set "SelectType=select"
        Set "�غ�=�з��ƶ�"
        Set /a "EnityId_�˺�=!NamePlayer_%EnityId%_�˺�!"
        Set /a "EnityId_X=!NamePlayer_%EnityId%_X!"
        if !SelectX! lss !EnityId_X! (
          Set "NamePlayer_%EnityId%_����=True"
        ) else (
          Set "NamePlayer_%EnityId%_����=False"
        )
        Set "EnityId=!Player_%SelectX%_%SelectY%!"
        Call :Get_Ver ������������ NamePlayer_!EnityId!_����
        Set "��������X=%SelectX%"
        Set "��������Y=%SelectY%"
        Call :Get_Ver �����������·��� MapList_!��������X!_!��������Y!
        if "!�����������·���!"=="4" (
          Set /a ������������+=1
        ) else if "!�����������·���!"=="13" (
          Set /a ������������+=1
        ) else if "!�����������·���!"=="16" (
          set �Ƿ�����=!random!%%4
          if !�Ƿ�����!==0 (
            Goto :Main
          )
        ) 
        Set /a "NamePlayer_!EnityId!_Ѫ��-=!EnityId_�˺�!"
        if !������������! leq !EnityId_�˺�! (
           Set /a "NamePlayer_!EnityId!_Ѫ��+=!������������!"
        ) else (
            Set /a "NamePlayer_!EnityId!_Ѫ��+=!������������!"
        )
        Call :��������ж� !EnityId!
        if Not "!������!"=="����" (
          Call :Ѫ�������� !EnityId!
          Set "�������ĵз���λEnityId=!EnityId!"
        )
      ) else (
        if "!NamePlayer_%EnityId%_X!"=="!SelectX!" if "!NamePlayer_%EnityId%_Y!"=="!SelectY!" (
          Set "SelectType=select"
          Set "�غ�=�з��ƶ�"
          Goto :Main
        )
        Set "MoreText=!MoreText!��ѡ�еĿ��ܲ�����һ���з���λ,"
        Goto Main
      )
    )
  )
Goto :Main
:IsWalk
Set "IsWalk=True"
if !SelectX! lss !EnityId_�ƶ���ʼX! (
  Set "IsWalk=False"
)
if !SelectX! gtr !EnityId_�ƶ�����X! (
  Set "IsWalk=False"
)
if !SelectY! lss !EnityId_�ƶ���ʼY! (
  Set "IsWalk=False"
)
if !SelectY! gtr !EnityId_�ƶ�����Y! (
  Set "IsWalk=False"
)
for %%a in (%�޷�ͨ�еķ���ID%) do (
  if "!MapList_%SelectX%_%SelectY%!"=="%%a" (
    Set "IsWalk=False"
  )
)
if defined Player_!SelectX!_!SelectY! (
    Set "IsWalk=False"
)
if "!SelectX!"=="!NamePlayer_%EnityId%_X!" (
  if "!SelectY!"=="!NamePlayer_%EnityId%_Y!" (
    Set "IsWalk=True"
  )
)
Goto :eof
:IsAttackMove
Set "IsAttackMove=True"
if !SelectX! lss !EnityId_������ʼX! (
  Set "IsAttackMove=False"
)
if !SelectX! gtr !EnityId_��������X! (
  Set "IsAttackMove=False"
)
if !SelectY! lss !EnityId_������ʼY! (
  Set "IsAttackMove=False"
)
if !SelectY! gtr !EnityId_��������Y! (
  Set "IsAttackMove=False"
)
Goto :Eof
:Get_Ver
Set "%~1=!%~2!"
Goto :Eof
:��������ж�
REM Call :��������ж� <���ID> <Ѫ��> 
Set "������=û��"
Set "EId=%~1"
if not "%~2"=="" (
  Set "Math_��λ��Ѫ��=%~2"
) else (
  Set "Math_��λ��Ѫ��=!NamePlayer_%EId%_Ѫ��!"
)
if !Math_��λ��Ѫ��! leq 0 (
  REM �����λ�Ѿ�����
  Set "���˵�Player_X=!NamePlayer_%EId%_X!"
  Set "���˵�Player_Y=!NamePlayer_%EId%_Y!"
  Set "���˵�Player_����=!NamePlayer_%EId%_����!"
  Set "Player_!���˵�Player_X!_!���˵�Player_Y!="
  Set Tmp_��λ����=0
  if "!NamePlayer_%EId%_��Ӫ!"=="�з�" (
    Set �з���λ_ 1>var/�з���λ_.env
    for /f "Tokens=1-2 delims==" %%y in (var/�з���λ_.env) do (
      if not "%%z"=="!EId!" (
        Set /a Tmp_��λ����+=1
        Set "�з���λ_!Tmp_��λ����!=%%z"
      )
    )
    Set "�з���λ_!�з���λ����!="
    Set /a "�з���λ����=!Tmp_��λ����!"
  ) else (
    Set �ҷ���λ_ 1>var/�ҷ���λ_.env
    for /f "Tokens=1-2 delims==" %%y in (var/�ҷ���λ_.env) do (
      if not "%%z"=="!EId!" (
        Set /a Tmp_��λ����+=1
        Set "�ҷ���λ_!Tmp_��λ����!=%%z"
      )
    )
    Set "�ҷ���λ_!�ҷ���λ����!="
    Set /a "�ҷ���λ����=!Tmp_��λ����!"
  )
  Set NamePlayer_%EId%_ 1>var/NamePlayer_%EId%_.env
  for /f "Tokens=1 delims==" %%z in (var/NamePlayer_%EId%_.env) do (
    Set "%%~z="
  )
  Set /a "������X=(!���˵�Player_X!)*64"
  Set /a "������Y=!���˵�Player_Y!*64"
  Set "image=target Player"
  Set "image=draw Space !������X! !������Y! "
  if "!���˵�Player_����:~2,2!"=="sb" (
    Set /a ������Y=!������Y!-7
  ) else if /i "!���˵�Player_����!"=="Zombie" (
    Set /a ������Y=!������Y!-3
  ) else (
    Set /a ������Y=!������Y!
  )
  Set /a ������X+=6
  Set "image=target BufHealth"
  Set "image=draw SpaceHealth !������X! !������Y!"
  Set "image=target Player"
  Set /a ��λ����-=1
  Set "������=����"
  if "!�з���λ����!"=="0" (
    Goto :Win
  )
  if "!�ҷ���λ����!"=="0" (
    Goto :Lose
  )
)
Goto :Eof
:����Ѫ����
Rem ��ʼ���ú���
Set EId=%~1
Set "Math_��λ����=!NamePlayer_%EId%_����!"
Set "Math_��λ��Ѫ��=!NamePlayer_%EId%_��Ѫ��!"
Set "Math_��λ��Ѫ��=!NamePlayer_%EId%_Ѫ��!"
Set "Math=round(!Math_��λ��Ѫ��!/!Math_��λ��Ѫ��!*49)"
calc %Math%>var\Hp.calcresult
Set /p "Math="<var\Hp.calcresult
if /i "!Math!"=="NAN" (
  Set "Math=49"
)
if "!Math_��λ����:~2,2!"=="sb" (
  Set /a ShowѪ��Y=!ShowPlayer_Y!-7
) else if /i "!Math_��λ����!"=="Zombie" (
  Set /a ShowѪ��Y=!ShowPlayer_Y!-3
) else (
  Set /a ShowѪ��Y=!ShowPlayer_Y!
)
Set /a ShowѪ��X=!ShowPlayer_X!+6
Set "image=unload Health"
Set "image=buffer Health"
Set "image=stretch Health !Math! 4"
Set "image=target Health"
Set "image=draw ImgHp 0 0"
Set "image=target BufHealth"
Set "image=draw ImgHPlabel !ShowѪ��X! !ShowѪ��Y! trans"
Set /a ShowѪ��X+=1
Set /a ShowѪ��Y+=1
Set "image=draw Health !ShowѪ��X! !ShowѪ��Y!"
Set EId=
Goto :Eof
:��ʼ��Ѫ����ͼ��
Set "image=buffer BufHealth"
Set "image=stretch BufHealth 960 704"
Set "image=buffer SpaceHealth"
Set "image=stretch SpaceHealth 51 6"
Goto :Eof
:�ƶ�Ѫ����
Title �ƶ�Ѫ����
REM Call :ThisFunction <x1> <y1> <x2> <y2> <Type>
Set "Type=%5"
if "!Type:~2,2!"=="sb" (
  Set /a "ԭX=%1*64+6"
  Set /a "ԭY=(%2*64)-7"
  Set /a "��X=%3*64+6"
  Set /a "��Y=%4*64-7"
) else if /i "%5"=="Zombie" (
  Set /a "ԭX=%1*64+6"
  Set /a "ԭY=(%2*64)-3"
  Set /a "��X=%3*64+6"
  Set /a "��Y=%4*64-3"
) else (
  Set /a "ԭX=%1*64+6"
  Set /a "ԭY=(%2*64)"
  Set /a "��X=%3*64+6"
  Set /a "��Y=%4*64"
)
Set /a ԭX*=-1
Set /a ԭY*=-1
Set "image=buffer TmpHealth"
Set "image=stretch TmpHealth 51 6"
set "image=target TmpHealth"
set "image=draw BufHealth !ԭX! !ԭY!"
Set /a ԭX*=-1
Set /a ԭY*=-1
set "image=target BufHealth"
set "image=draw SpaceHealth !ԭX! !ԭY!"
set "image=draw TmpHealth !��X! !��Y!"
Goto :Eof
:Ѫ��������
Title Ѫ�������� Eid:%~1
Rem Call :ThisFunction <EnityId>
Set EId=%~1
Set /a "Ѫ����X=(!NamePlayer_%EId%_X!)*64+6"
if "!NamePlayer_%EId%_����:~2,2!"=="sb" (
  Set /a "Ѫ����Y=!NamePlayer_%EId%_Y!*64-7"
) else if /i "!NamePlayer_%EId%_����!"=="Zombie" (
  Set /a "Ѫ����Y=!NamePlayer_%EId%_Y!*64-3"
) else (
  Set /a "Ѫ����Y=!NamePlayer_%EId%_Y!*64"
)
set "image=target BufHealth"
set "image=draw SpaceHealth !Ѫ����X! !Ѫ����Y!"
Set "Math=round(!NamePlayer_%EId%_Ѫ��!/!NamePlayer_%EId%_��Ѫ��!*49)"
calc %Math%>var\Hp.calcresult
Set /p "Math="<var\Hp.calcresult
if /i "!Math!"=="NAN" (
  Set "Math=49"
)
Set "image=unload Health"
Set "image=buffer Health"
Set "image=stretch Health !Math! 4"
Set "image=target Health"
Set "image=draw ImgHp 0 0"
Set "image=target BufHealth"
Set "image=draw ImgHPlabel !Ѫ����X! !Ѫ����Y! trans"
Set /a Ѫ����X+=1
Set /a Ѫ����Y+=1
Set "image=draw Health !Ѫ����X! !Ѫ����Y!"
Goto :Eof
:��λ�ƶ�
Rem Call :ThisFunction <x1> <y1> <x2> <y2>
Set /a "ԭX=(%1)*-64"
Set /a "ԭY=%2*-64"
Set /a "��X=(%3)*64"
Set /a "��Y=%4*64"
Set "image=buffer TmpPlayer"
Set "image=stretch TmpPlayer 64 64"
set "image=target TmpPlayer"
set "image=draw Player !ԭX! !ԭY!"
set "image=target Player"
Set /a ԭX*=-1
Set /a ԭY*=-1
set "image=draw Space !ԭX! !ԭY!"
set "image=draw TmpPlayer !��X! !��Y!"
Goto :Eof
:Ѱ��ѡ�����м�ֵ�ĵз���λ
Set /a ��ʷ��ֵ = -10000
for /l %%i in (1,1,%�з���λ����%) do (
  for /l %%j in (1,1,%�ҷ���λ����%) do (
    call call Set "���빫ʽ=sqrt((%%%%NamePlayer_%%�з���λ_%%i%%_X%%%%-%%%%NamePlayer_%%�ҷ���λ_%%j%%_X%%%%)*(%%%%NamePlayer_%%�з���λ_%%i%%_X%%%% - %%%%NamePlayer_%%�ҷ���λ_%%j%%_X%%%%)+(%%%%NamePlayer_%%�з���λ_%%i%%_Y%%%% - %%%%NamePlayer_%%�ҷ���λ_%%j%%_Y%%%%)*(%%%%NamePlayer_%%�з���λ_%%i%%_Y%%%% - %%%%NamePlayer_%%�ҷ���λ_%%j%%_Y%%%%))"
    calc "!���빫ʽ!" 1>var/����.calcresult
    Set /p ����=<var/����.calcresult
    call call set "��ֵ��ʽ=floor((1/!����! + 1/(%%%%NamePlayer_%%�ҷ���λ_%%j%%_Ѫ��%%%% / (%%%%NamePlayer_%%�з���λ_%%j%%_�˺�%%%% - %%%%NamePlayer_%%�ҷ���λ_%%j%%_����%%%%)))*10000)" 
    calc "!��ֵ��ʽ!" 1>var/��ֵ.calcresult
    Set /a ��ֵ=<var/��ֵ.calcresult
    if !��ֵ! gtr !��ʷ��ֵ! (
      set /a �з�EnityId=!�з���λ_%%i!
      set ��ʷ��ֵ=!��ֵ!
    )
  )
)
Goto :Eof
:�з��ƶ�
If Not Defined �з�EnityId (
  if Defined �������ĵз���λEnityId (
    if defined NamePlayer_!�������ĵз���λEnityId!_Ѫ�� (
      if !NamePlayer_%�������ĵз���λEnityId%_Ѫ��! gtr 0 (
        ::׷���趨
        Set /a "�з�EnityId=!�������ĵз���λEnityId!"
        Set "�������ĵз���λEnityId="
      ) else (
        Call :Ѱ��ѡ�����м�ֵ�ĵз���λ
      )
    ) else (
      Call :Ѱ��ѡ�����м�ֵ�ĵз���λ
    )
  ) else (
    Call :Ѱ��ѡ�����м�ֵ�ĵз���λ
  )
  Set "�з�ѡ�����=t"
)
if "!�з�ѡ�����!"=="t" (
  Set "�з���λX=!NamePlayer_%�з�EnityId%_X!"
  Set "�з���λY=!NamePlayer_%�з�EnityId%_Y!"
  Set "�з�EnityId_�ƶ�����=!NamePlayer_%�з�EnityId%_�ƶ�����!"
  Set /a "�з�EnityId_�ƶ���ʼX=!�з���λX!-!�з�EnityId_�ƶ�����!"
  Set /a "�з�EnityId_�ƶ���ʼY=!�з���λY!-!�з�EnityId_�ƶ�����!"
  Set /a "�з�EnityId_�ƶ�����X=!�з���λX!+!�з�EnityId_�ƶ�����!"
  Set /a "�з�EnityId_�ƶ�����Y=!�з���λY!+!�з�EnityId_�ƶ�����!"
  Set TempXY=
  Set TempX=
  Set TempY=
  Set ��������XY��=100000
  Set �������ĵ�λId=
  Set �Ƿ��滻=
  Set /a "����Ѫ��=!NamePlayer_%�з�EnityId%_��Ѫ��!/3+1"
  Set "׷����Ӫ=�ҷ�"
  if !NamePlayer_%�з�EnityId%_Ѫ��! leq !����Ѫ��! (
    if !�з���λ����! geq 2 (
      Set "׷����Ӫ=�з�"
    )
  )
  if !PostiveAI!=="Enable" (
    Set "׷����Ӫ=�ҷ�"
  )
  Set !׷����Ӫ!��λ_ 1>var/!׷����Ӫ!��λ_.env
  for /f "Tokens=1-2 delims==" %%i in (var/!׷����Ӫ!��λ_.env) do (
    if not %%j==!�з�EnityId! (
      Set /a "TempX=!NamePlayer_%%j_X!-!�з���λX!"
      Set /a "TempY=!NamePlayer_%%j_Y!-!�з���λY!"
      Set /a "TempXY=!TempX!*!TempX!+!TempY!*!TempY!"
      if !TempXY! lss !��������XY��! (
        Set ��������XY��=!TempXY!
        Set �������ĵ�λId=%%j
        Set �����λX=!NamePlayer_%%j_X!
        Set �����λY=!NamePlayer_%%j_Y!
      ) else if !TempXY!==!��������XY��! (
        Set /a "�Ƿ��滻=!random! %% 2"
        if !�Ƿ��滻!==1 (
          Set ��������XY��=!TempXY!
          Set �������ĵ�λId=%%j
          Set �����λX=!NamePlayer_%%j_X!
          Set �����λY=!NamePlayer_%%j_Y!
        )
      )
    )
  )
  Set TempXY=
  Set TempX=
  Set TempY=
  Set �ƶ���������С��XY��=100000
  Set �ƶ�����������XY��=0
  Set "�з��ƶ�����=0"
  Set �з��ƶ�������Сλ��=
  Set �з��ƶ��������λ��=
  Set �з��ƶ������б�=
)
if defined �з�EnityId (
  Set "�з�ѡ�����=f"
  Call :�з��ƶ�_����
)
Goto :Main
:�з��ƶ�_����
if Not "!SelectX!"=="!�з���λX!" (
  if !SelectX! gtr !�з���λX! (
    Set /a "SelectX-=1"
  ) else (
    Set /a "SelectX+=1"
  )
) else (
  if Not "!SelectY!"=="!�з���λY!" (
    if !SelectY! gtr !�з���λY! (
      Set /a "SelectY-=1"
    ) else (
      Set /a "SelectY+=1"
    )
  )
)
if "!SelectX!"=="!�з���λX!" (
  if "!SelectY!"=="!�з���λY!" (
    Set "SelectType=decideselect"
    Set �غ�=�з��ƶ���ʼ_DFS
    Call :�з��ƶ�������Ⱦ
  )
)
Goto :Eof
:�з��ƶ�������Ⱦ
Set "image=unload MoveSelect"
Set image=buffer MoveSelect||Rem �ٽ���buf �ô���
Set image=stretch MoveSelect 960 704
Set image=target MoveSelect
for /l %%a in (%�з�EnityId_�ƶ���ʼY%,1,%�з�EnityId_�ƶ�����Y%) do (
  for /l %%b in (%�з�EnityId_�ƶ���ʼX%,1,%�з�EnityId_�ƶ�����X%) do (
    Set "IsWalk=True"
    for %%c in (%�޷�ͨ�еķ���ID%) do (
      if "!MapList_%%b_%%a!"=="%%c" (
        Set "IsWalk=False"
      )
    )
    if "!IsWalk!"=="True" (
      if not defined Player_%%b_%%a (
        Set /a "DrawDecideSelectX=%%b*64"
        Set /a "DrawDecideSelectY=%%a*64"
        Set "image=draw Imgmoverange !DrawDecideSelectX! !DrawDecideSelectY!"
      )
    )
  )
) 2>nul
Goto :Eof
:�з��ƶ���ʼ_DFS
Set DFS 1>var/DFS.env
for /f "tokens=1 delims==" %%i in (var/DFS.env) do (
  Set "%%~i="
)
Set "DFSMoveX=+0+0-1+1" || REM ��0��1��2��3
Set "DFSMoveY=-1+1+0+0"
Set /a XDis=!�����λX!-!�з���λX!
Set /a YDis=!�����λY!-!�з���λY!
if !XDis! gtr 0 (
  ::Ŀ�����Ҳ�
  if !YDis! gtr 0 (
    ::Ŀ�����·�
    if !YDis! gtr !XDis! (
      Set DFS_MoveRule=1302 || Rem ��������
    ) else (
      Set DFS_MoveRule=3120 || Rem ��������
    )
  ) else (
    ::Ŀ�����·�
    if -!YDis! gtr !XDis! (
      Set DFS_MoveRule=0312 || Rem ��������
    ) else (
      Set DFS_MoveRule=3021 || Rem ��������
    )
  )
) else (
  ::Ŀ�������
  if !YDis! gtr 0 (
    ::Ŀ�����·�
    if !YDis! gtr -!XDis! (
      Set DFS_MoveRule=1203 || Rem ��������
    ) else (
      Set DFS_MoveRule=2130 || Rem ��������
    )
  ) else (
    ::Ŀ�����Ϸ�
    if -!YDis! gtr -!XDis! (
      Set DFS_MoveRule=0213 || Rem ��������
    ) else (
      Set DFS_MoveRule=2031 || Rem ��������
    )
  )
)
Set "DFS_HistoryX=" || Rem 121110+9+8+7
Set "DFS_HistoryY=" || Rem 121110+9+8+7
Set "DFS_HistoryStep="
Set /a DFS_HistoryLength=0
Set DFS_X=!SelectX!
Set DFS_Y=!SelectY!
Set DFS_Step=0
Set �غ�=DFS_Main
:DFS_Main
if !DFS_X!==!�����λX! (
  if !DFS_Y!==!�����λY! (
    Goto :DFS_Found
  )
)
Set /a NextRule=!DFS_MoveRule:~%DFS_Step%,1!*2
call Set Next_DFS_X=!DFS_X!%%DFSMoveX:~!NextRule!,2%%
Set /a Next_DFS_X=!Next_DFS_X!
call Set Next_DFS_Y=!DFS_Y!%%DFSMoveY:~!NextRule!,2%%
Set /a Next_DFS_Y=!Next_DFS_Y!
Set "IsWalk=True"
if !Next_DFS_X! GEQ 0 (
  if !Next_DFS_Y! GEQ 0 (
    if !Next_DFS_X! Lss 15 (
      if !Next_DFS_Y! Lss 11 (
        for %%a in (%�޷�ͨ�еķ���ID%) do (
          if "!MapList_%Next_DFS_X%_%Next_DFS_Y%!"=="%%a" (
            Set "IsWalk=False"
          )
        )
        if defined Player_!Next_DFS_X!_!Next_DFS_Y! (
            Set "IsWalk=False"
        )
        if "!Next_DFS_X!"=="!NamePlayer_%�з�EnityId%_X!" (
          if "!Next_DFS_Y!"=="!NamePlayer_%�з�EnityId%_Y!" (
            Set "IsWalk=True"
          )
        )
        if "!Next_DFS_X!"=="!NamePlayer_%�������ĵ�λId%_X!" (
          if "!Next_DFS_Y!"=="!NamePlayer_%�������ĵ�λId%_Y!" (
            Set "IsWalk=True"
          )
        )
      ) else (
        Set "IsWalk=False"
      )
    ) else (
      Set "IsWalk=False"
    )
  ) else (
    Set "IsWalk=False"
  )
) else (
  Set "IsWalk=False"
)
if NOT Defined DFS_Walked_!Next_DFS_X!_!Next_DFS_Y! (
    if "!IsWalk!"=="True" (
      set "DFS_Walked_!Next_DFS_X!_!Next_DFS_Y!=True"
      if !DFS_X! lss 10 (
        Set "DFS_HistoryX=!DFS_HistoryX!+!DFS_X!"
      ) else (
        Set "DFS_HistoryX=!DFS_HistoryX!!DFS_X!"
      )
      if !DFS_Y! lss 10 (
        Set "DFS_HistoryY=!DFS_HistoryY!+!DFS_Y!"
      ) else (
        Set "DFS_HistoryY=!DFS_HistoryY!!DFS_Y!"
      )
      Set "DFS_HistoryStep=!DFS_HistoryStep!!DFS_Step!"
      Set DFS_X=!Next_DFS_X!
      Set DFS_Y=!Next_DFS_Y!
      Set SelectX=!DFS_X!
      Set SelectY=!DFS_Y!
      Set DFS_Step=0
      Set /a DFS_HistoryLength+=1
      goto :!SettingDFS_Mode!
  )
)
if !DFS_Step! lss 3 (
  set /a DFS_Step+=1
) else (
  Goto :DFS_Back
)
Goto :!SettingDFS_Mode!
:DFS_Back
REM ����״̬
if !DFS_HistoryLength! equ 0 (
  Set "�غ�=�з��ƶ�ѡ��"
  Set SelectX=!NamePlayer_%�з�EnityId%_X!
  Set SelectY=!NamePlayer_%�з�EnityId%_Y!
  Goto :Main
)
set "DFS_Walked_!DFS_X!_!DFS_Y!="
Set /a DFS_HistoryLength-=1
Set /a DFS_X=!DFS_HistoryX:~-2,2!
Set /a DFS_Y=!DFS_HistoryY:~-2,2!
Set SelectX=!DFS_X!
Set SelectY=!DFS_Y!
Set /a DFS_Step=!DFS_HistoryStep:~-1,1!+1
Set "DFS_HistoryX=!DFS_HistoryX:~0,-2!"
Set "DFS_HistoryY=!DFS_HistoryY:~0,-2!"
Set "DFS_HistoryStep=!DFS_HistoryStep:~0,-1!"
if !DFS_Step! geq 4 (
  goto :DFS_Back
)
goto :!SettingDFS_Mode!
:DFS_Found
set "�غ�=�з��ƶ�AI����"
Set /a DFS_MoveStep=0
goto :Main
:�з��ƶ�AI����
if !DFS_HistoryLength!==!DFS_MoveStep! (
  Set "�غ�=�з��ƶ�ѡ��"
  Goto :Main
)
Set /a DFS_MoveTempX=!DFS_HistoryX:~0,2!
Set /a DFS_MoveTempY=!DFS_HistoryY:~0,2!
if !DFS_MoveTempX! lss !�з�EnityId_�ƶ���ʼX! (
  Set "�غ�=�з��ƶ�ѡ��"
  Goto :Main
)
if !DFS_MoveTempX! gtr !�з�EnityId_�ƶ�����X! (
  Set "�غ�=�з��ƶ�ѡ��"
  Goto :Main
)
if !DFS_MoveTempY! lss !�з�EnityId_�ƶ���ʼY! (
  Set "�غ�=�з��ƶ�ѡ��"
  Goto :Main
)
if !DFS_MoveTempY! gtr !�з�EnityId_�ƶ�����Y! (
  Set "�غ�=�з��ƶ�ѡ��"
  Goto :Main
)
Set /a SelectX=!DFS_MoveTempX!
Set /a SelectY=!DFS_MoveTempY!
Set "DFS_HistoryX=!DFS_HistoryX:~2!"
Set "DFS_HistoryY=!DFS_HistoryY:~2!"
Set /a DFS_MoveStep+=1
Goto :Main
:�з��ƶ�ѡ��
Set "SelectType=select"
Call :��λ�ƶ� !NamePlayer_%�з�EnityId%_X! !NamePlayer_%�з�EnityId%_Y! !SelectX! !SelectY!
Call :�ƶ�Ѫ���� !NamePlayer_%�з�EnityId%_X! !NamePlayer_%�з�EnityId%_Y! !SelectX! !SelectY! !NamePlayer_%�з�EnityId%_����!
Set "Player_!NamePlayer_%�з�EnityId%_X!_!NamePlayer_%�з�EnityId%_Y!="
Set "NamePlayer_!�з�EnityId!_X=!SelectX!"
Set "NamePlayer_!�з�EnityId!_Y=!SelectY!"
Set "Player_!SelectX!_!SelectY!=!�з�EnityId!"
Set "�غ�=�з�����ѡ��"
Goto :Main
:�з�����ѡ��
Set "image=unload AttackSelect"
Set image=buffer AttackSelect||Rem �ٽ���buf �ô���
Set image=stretch AttackSelect 960 704
Set image=target AttackSelect
Set "SelectType=decideselect"
Set "�з�EnityId=!Player_%SelectX%_%SelectY%!"
If !MapList_%SelectX%_%SelectY%!==1 (
  Set /a "�з�EnityId_��������=!NamePlayer_%�з�EnityId%_��������!+1"
) else if "!MapList_%SelectX%_%SelectY%!"=="10" (
  Set /a "�з�EnityId_��������=!NamePlayer_%�з�EnityId%_��������!+1"
) else if !MapList_%SelectX%_%SelectY%!==10 (
  Set /a "�з�EnityId_��������=!NamePlayer_%�з�EnityId%_��������!+1"
) else (
  Set "�з�EnityId_��������=!NamePlayer_%�з�EnityId%_��������!"
)
Set /a "�з�EnityId_������ʼX=!SelectX!-!�з�EnityId_��������!"
Set /a "�з�EnityId_������ʼY=!SelectY!-!�з�EnityId_��������!"
Set /a "�з�EnityId_��������X=!SelectX!+!�з�EnityId_��������!"
Set /a "�з�EnityId_��������Y=!SelectY!+!�з�EnityId_��������!"
Set /a "�з�EnityId_�˺�=!NamePlayer_%�з�EnityId%_�˺�!"
Set /a "�ɹ�����λ����=0"
for /l %%a in (%�з�EnityId_������ʼY%,1,%�з�EnityId_��������Y%) do (
  for /l %%b in (%�з�EnityId_������ʼX%,1,%�з�EnityId_��������X%) do (
    if defined Player_%%b_%%a (
      Call :Get_Ver Tmp�з�EnityId Player_%%b_%%a
      Call :Get_Ver Tmp�з�EnityId NamePlayer_!Tmp�з�EnityId!_��Ӫ
      if "!Tmp�з�EnityId!"=="�ҷ�" (
        Set /a �ɹ�����λ����+=1
        Set "�з��ɹ�����λ_!�ɹ�����λ����!=!Player_%%b_%%a!"
        Set /a "DrawAttackSelectX=%%b*64"
        Set /a "DrawAttackSelectY=%%a*64"
        Set "image=draw Imgattackrange !DrawAttackSelectX! !DrawAttackSelectY!"
      )
    )
  )
) 2>nul
Set image=target cmd
if !�ɹ�����λ����!==0 (
  REM û�п� ���� ��λʱ������
  set "SelectType=select"
  Set "�غ�=��λ�ƶ�"
  Set /a �غ���+=1
  Call :�غϽ�������
  Set "�з�EnityId="
) else (
  Set "�غ�=�з�����_ѡ�񶯻�"
  Set /a "��������λEnityId=!Random! %% !�ɹ�����λ����! + 1"
  Call :Get_Ver ��������λEnityId �з��ɹ�����λ_!��������λEnityId!
)
Goto :Main
:�з�����_ѡ�񶯻�
Set ��������λX=!NamePlayer_%��������λEnityId%_X!
Set ��������λY=!NamePlayer_%��������λEnityId%_Y!
if Not "!SelectX!"=="!��������λX!" (
  if !SelectX! gtr !��������λX! (
    Set /a "SelectX-=1"
  ) else (
    Set /a "SelectX+=1"
  )
) else (
  if Not "!SelectY!"=="!��������λY!" (
    if !SelectY! gtr !��������λY! (
      Set /a "SelectY-=1"
    ) else (
      Set /a "SelectY+=1"
    )
  )
)
if "!SelectX!"=="!��������λX!" (
  if "!SelectY!"=="!��������λY!" (
    Set "�غ�=�з�����_����˺�"
  )
)
Goto :Main
:�з�����_����˺�
Set "EnityId=!Player_%SelectX%_%SelectY%!"
if "!MapList_%��������λX%_%��������λY%!"=="4" (
  Set /a ������������=!NamePlayer_%��������λEnityId%_����!+1
) else if "!MapList_%��������λX%_%��������λY%!"=="13" (
  Set /a ������������=!NamePlayer_%��������λEnityId%_����!+1
) else if "!MapList_%��������λX%_%��������λY%!"=="16" (
  set �Ƿ�����=!random!%%4
  if !�Ƿ�����!==0 (
    set "SelectType=select"
    Set "�غ�=��λ�ƶ�"
    Set /a �غ���+=1
    Call :�غϽ�������
    Set "�з�EnityId="
    Goto :Main
  )
) else (
  Set /a ������������=!NamePlayer_%��������λEnityId%_����!
)
Set EnityId_�˺�=!NamePlayer_%�з�EnityId%_�˺�!
Set /a "NamePlayer_!��������λEnityId!_Ѫ��-=!EnityId_�˺�!"
if !������������! leq !EnityId_�˺�! (
  Set /a "NamePlayer_!��������λEnityId!_Ѫ��+=!������������!"
) else (
  Set /a "NamePlayer_!��������λEnityId!_Ѫ��+=!������������!"
)
Call :��������ж� !��������λEnityId!
if Not "!������!"=="����" (
  Call :Ѫ�������� !��������λEnityId!
)
set "SelectType=select"
Set "�غ�=��λ�ƶ�"
Set /a �غ���+=1
Call :�غϽ�������
Set "�з�EnityId="
Goto :Main
:Win
set image=target cmd
set image=cls
cls
if Not "!�Զ��ؿ�!"=="True" (
  if not %map%==5 (
    Echo ��Ӯ�ˣ������������һ��
    echo �غ���:!�غ���!
    Set /a map+=1
    >level.txt echo !map!
    pause>nul
    Endlocal
    Goto :Loadlevel
  ) else (
    Set /a map+=1
    >level.txt echo !map!
    Echo ��Ӯ�ˣ����Ѿ�ͨ���˱���Ϸ�����ڴ�����Ϸ���£���л��
    pause>nul
  )
) else (
  Echo ��ϲ����Ӯ��%�Զ��ؿ���%����Զ��ؿ���
  pause>nul
)
exit
:Lose
set image=target cmd
set image=cls
Endlocal
cls
if Not "!�Զ��ؿ�!"=="True" (
  echo �����ˣ����������
  pause>nul
) else (
  echo ����������Զ��ؿ������������
  pause>nul
)
Goto :Loadlevel
exit
:Help
Set image=draw cover 0 0
echo �����:
echo 21����50��������羭�ø��ٷ�չ��ȫ��һ�廯�Ȳ��ƽ�
echo �������Ļ����£���ʱ�����ƻ���ƽ���¼���ʱ�з���
echo ����ΪA��ά�Ͳ���ָ�ӹ٣�������ά�����Ұ�ȫ�����Σ�A����ƽ��ȫ�����Ӣ�����ǻۣ�
echo.
echo ��������:
echo W A S D ����ѡ����
echo J��ȷ��ѡ��
echo.
echo ��ϷĿ��
echo ������ˣ�ÿ���ؿ����в�ͬ����Ҫ��
echo.
echo ��������:
echo ����:bbaa TJUGERKFER
echo ����:TJUGERKFER
echo ����:TJUGERKFER
echo ��ͼ����:TJUGERKFER bbaa
echo Debug:bbaa TJUGERKFER
echo ����:bbaa
echo.
echo ����������أ�
Pause>nul
Goto Draw_Menu
:�غϽ�������
Set Player_ 1>var/Player_.env
for /f "Tokens=2 delims==" %%i in (var/Player_.env) do (
  if !NamePlayer_%%i_Ѫ��! gtr 0 (
      Call :Get_Ver ����Id MapList_!NamePlayer_%%i_X!_!NamePlayer_%%i_Y!
      if "!����Id!"=="11" (
        if !NamePlayer_%%i_Ѫ��! lss !NamePlayer_%%i_��Ѫ��! (
         Set /a NamePlayer_%%i_Ѫ��+=1
        )
      )
      if "!����Id!"=="15" (
        Set /a NamePlayer_%%i_Ѫ��-=1
        Call :��������ж� %%i
      )
      Call :Ѫ�������� %%i
  ) else (
    Call :��������ж� %%i
    Call :Ѫ�������� %%i
  )
)
Goto :Eof
:drawMain
Call :Show Main 0 64||Rem ��������Ⱦ��
Goto :EOF