@Rem Made By TJU And Bbaa
%1start /max "Win7Font" "%~dp0cmd.exe" "/c %~fs0 :"&exit
@echo off 2>nul 3>nul
mode con cols=120 lines=48
setlocal enabledelayedexpansion
Set SettingDFS_DebugMode=1|| REM 1显示搜索过程0不显示
if !SettingDFS_DebugMode!==1 (
  set SettingDFS_Mode=Main
) else (
  set SettingDFS_Mode=DFS_Main
)
@Path %~dp0Tools;%Path%
@Curs /crv 0
ver|find "10.">nul 2>nul&&(
  reg query HKCU\Console\Win7Font>nul 2>nul|| (
    echo 检测到你是windows10系统
    echo 请导入win10.reg和打开启用旧版控制台后重启游戏
    echo 按任意键继续
    pause>nul
  )
  Set Windows10=True
)
if not exist level.txt (
  >level.txt echo 1
)
Call Update.bat
Rem 2018/01/31 项目开始开发
Rem 2018/02/03 整体架构重写
:Draw_Title
Rem 加载UI
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
title W和S选择，J确定
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
  Echo 暂不开放！
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
for /f %%i in ('dir /a:d /b 自定关卡') do (
  echo N!CustomIndex!.%%i
  Set CustomN!CustomIndex!=%%i
  Set /a CustomIndex+=1
)

Echo                                                请输入想游玩的关卡:
set /p stagechoose=                                            Stage：
if "!stagechoose:~0,1!"=="N" (
  if not defined Custom!stagechoose! (
    goto :Setting
  )
  Set "自定关卡=True"
  Set "map=自定:!Custom%stagechoose%!"
  Set "自定关卡名=!Custom%stagechoose%!"
) else (
  if "%map%" geq "%stagechoose%" (
    if "%stagechoose%" geq "1" (
      set "map=%stagechoose%"
    )
  ) else (
    echo 你输入的关卡暂未开放
    echo 现在为您跳转到您可游玩的最后一关
    ping -n 2 127.0.0.1>nul 2>nul
  )
)
cls
if exist "分辨率压缩" (
  Set /p "自定义分辨率="<分辨率压缩
)
Set "image=target cmd"
Set "image=cls"
Set "image=unload Main"
Set "image=buffer Main"||Rem 主渲染层
Set "image=stretch Main 960 704"
Set "image=unload Space"
Set "image=buffer Space"
Set "image=stretch Space 64 64"
Set "SelectType=select"
Set "无法通行的方块ID=2,3,6,8,9,17"
Set SelectX=0
Set SelectY=0
Set "敌方寻路指数=15"
:LoadLevel
setlocal
cls
Set 渲染次数=0
Set 回合数=1
Set "回合=单位移动"
Set EnityId=
Set 敌方EnityId=
Set "PostiveAI=disable"
title 关卡:!map! 按任意键继续
if Not "!自定关卡!"=="True" (
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
  For /f "delims=" %%i in (./自定关卡/%自定关卡名%/Story.txt) do (
    echo;%%i
    pause>nul
  )
  if exist ./自定关卡/%自定关卡名%/%自定关卡名%.env (
    for /f "delims=" %%i in (./自定关卡/%自定关卡名%/%自定关卡名%.env) do (
      Set "%%~i"
    )
  )
)
cls
Title 游戏加载中.........
cls
echo ■■■■■■■
echo 加载单位数据...
Call :LoadPlayer||Rem 加载单位
cls
echo ■■■■■■■■■■■■■■■■■■■
echo 预缓存图片...
Call :LoadImage||Rem 加载图片
cls
echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
echo 加载地图...
Call :LoadMap_New||Rem 加载地图
cls
echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
echo 绘制单位层...
Call :初始化血量条图层
Call :Buf_Player||Rem 加载单位叠加层
cls
echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
echo OK!
pause
:Main
Set /a 渲染次数+=1
Set "image=unload Main"
Set "image=buffer Main"||Rem 主渲染层
Set "image=stretch Main 960 704"
if Not "!自定关卡!"=="True" (
  if "%map%"=="1" (
    if !回合数! gtr 20 (
      Echo 你超过了20回合，你输了
      Goto :Lose
    )
  )
  if "%map%"=="2" (
    if !回合数! gtr 15 (
      Echo 恭喜，你坚持了15回合
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
if exist "分辨率压缩" (
  Set "image=resize Main %自定义分辨率%"
)
Call :Show Map 0 0||Rem 显示地图到主渲染层
Call :Show Player trans||Rem 显示单位到主渲染层
Call :Show BufHealth trans
if "!回合!"=="单位移动" (
  Set "敌方EnityId="
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!回合!"=="单位攻击选择" (
  Set "SelectType=decideselect"
  Set "回合=单位攻击选定"
  Call :Main_AttackSelect||Rem 计算攻击范围
  Call :Show AttackSelect trans
) else if "!回合!"=="单位攻击选定" (
  Call :Show AttackSelect trans
) else if "!回合!"=="敌方移动开始_DFS" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!回合!"=="DFS_Main" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!回合!"=="敌方移动AI处理" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show MoveSelect trans
  )
) else if "!回合!"=="敌方攻击_选择动画" (
  if /i "!SelectType!"=="decideselect" (
    Call :Show AttackSelect trans
  )
)
Set /a "ShowSelectX=!SelectX!*64"
Set /a "ShowSelectY=!SelectY!*64"
Call :Show Img%SelectType% trans !ShowSelectX! !ShowSelectY!||Rem 显示选择区
if exist "分辨率压缩" (
  Set "image=stretch Main !自定义分辨率!"
)
Call :Show Main 0 64||Rem 加载主渲染层
Set block=
Set "block=!MapList_%SelectX%_%SelectY%!"
set "地形="
set "属性="
if "%block%"=="0" (
  set 地形=平原
  set 属性=可通行
)
if "%block%"=="1" (
  set 地形=高地
  set 属性=在此地的单位射程半径+1
)
if "%block%"=="2" (
  set 地形=高山
  set 属性=无法通行
)
if "%block%"=="3" (
  set 地形=水域
  set 属性=无法通行
)
if "%block%"=="4" (
  set 地形=防御阵地
  set 属性=在此地的单位防御力+1
)
if "%block%"=="5" (
  set 地形=桥梁
  set 属性=可通行
)
if "%block%"=="6" (
  set 地形=四维空间
  set "属性=error on Line 32768:wrong with 'null'"
) else if "%block%"=="" (
  set 地形=四维空间
  set "属性=error on Line 32768:wrong with 'null'"
)
if "%block%"=="7" (
  set 地形=草地
  set 属性=可通行
)
if "%block%"=="8" (
  set 地形=森林
  set 属性=不可通行
)
if "%block%"=="9" (
  set 地形=高山
  set 属性=不可通行
)
if "%block%"=="10" (
  set 地形=丘陵
  set 属性=在此地的单位射程半径+1
)
if "%block%"=="11" (
  set 地形=城市
  set 属性=在这个单位驻扎的单位每回合恢复1体力
)
if "%block%"=="12" (
  set 地形=桥梁
  set 属性=可通行
)
if "%block%"=="13" (
  set 地形=防御阵地
  set 属性=在此地的单位防御力+1
)
if "%block%"=="15" (
  set 地形=地火
  set 属性=Arknights 破碎大道
)
if "%block%"=="16" (
  set 地形=雪地
  set 属性=攻击距离-1 获得20%概率闪避
)
if "%block%"=="6" (
  set 地形=雪山
  set 属性=无法通行
)
Set "SPlayer_Id="
if defined Player_%SelectX%_%SelectY% (
  Set "SPlayer_Id=!Player_%SelectX%_%SelectY%!"
)
if defined SPlayer_Id (
  Set "单位信息=名称:!NamePlayer_%SPlayer_Id%_名称! 血量:!NamePlayer_%SPlayer_Id%_血量! 阵营:!NamePlayer_%SPlayer_Id%_阵营!"
) else (
  Set "单位信息=此处无单位"
)
echo;地形:%地形% 属性:%属性% %单位信息%
echo;当前坐标:x:%SelectX% y:%SelectY%
echo;关卡:!map! 回合:!回合! 回合数:!回合数!  剩余敌方单位:!敌方单位数量! 剩余我方单位:!我方单位数量!
if defined MoreText (
  for %%a in (%MoreText%) do (
    echo;%%a
  )
  Set "MoreText="
)
If Not "!回合:~0,2!"=="敌方" (
  if Not "!回合:~0,3!"=="DFS" (
    Goto :KeyDown
  )
) else (
  if "!回合!"=="敌方移动" (
    Goto :敌方移动
  ) else if "!回合!"=="敌方移动开始" (
    Goto :敌方移动开始
  ) else if "!回合!"=="敌方移动AI处理" (
    Goto :敌方移动AI处理
  ) else if "!回合!"=="敌方移动选定" (
    Goto :敌方移动选定
  ) else if "!回合!"=="敌方攻击选择"  (
    Goto :敌方攻击选择
  ) else if "!回合!"=="敌方攻击_选择动画" (
    Goto :敌方攻击_选择动画
  ) else if "!回合!"=="敌方攻击_造成伤害" (
    Goto :敌方攻击_造成伤害
  )
)
Goto :!回合!
:Main_MoveA
If "%SelectX%"=="!NamePlayer_%EnityId%_X!" (
  If "%SelectY%"=="!NamePlayer_%EnityId%_Y!" (
    echo 是要移动到这儿（原地待命）还是选择其他单位[d,q]？
    choice /c dq /n>nul 2>nul
    if errorlevel 2 (
      set "SelectType=select"
      Set "回合=单位移动"
      Goto Main
    ) else (
      set "SelectType=select"
      Set "回合=单位攻击选择"
      Goto Main
    )
  )
)  2>nul
Set "SelectType=select"
Call :单位移动 !NamePlayer_%EnityId%_X! !NamePlayer_%EnityId%_Y! !SelectX! !SelectY!
Call :移动血量条 !NamePlayer_%EnityId%_X! !NamePlayer_%EnityId%_Y! !SelectX! !SelectY! !NamePlayer_%EnityId%_类型!
Set "Player_!NamePlayer_%EnityId%_X!_!NamePlayer_%EnityId%_Y!="
Set "NamePlayer_!EnityId!_X=!SelectX!"
Set "NamePlayer_!EnityId!_Y=!SelectY!"
Set "Player_!SelectX!_!SelectY!=!EnityId!"
Set "回合=单位攻击选择"
Goto :Main
:Main_MoveSelect
Set "image=unload MoveSelect"
Set image=buffer MoveSelect||Rem 再建个buf 好处理
Set image=stretch MoveSelect 960 704
Set image=target MoveSelect
Set "EnityId=!Player_%SelectX%_%SelectY%!"
Set "EnityId_移动距离=!NamePlayer_%EnityId%_移动距离!"
Set /a "EnityId_移动起始X=!SelectX!-!EnityId_移动距离!"
Set /a "EnityId_移动起始Y=!SelectY!-!EnityId_移动距离!"
Set /a "EnityId_移动结束X=!SelectX!+!EnityId_移动距离!"
Set /a "EnityId_移动结束Y=!SelectY!+!EnityId_移动距离!"
for /l %%a in (%EnityId_移动起始Y%,1,%EnityId_移动结束Y%) do (
  for /l %%b in (%EnityId_移动起始X%,1,%EnityId_移动结束X%) do (
    Set "IsWalk=True"
    for %%c in (%无法通行的方块ID%) do (
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
Rem TJU:完全照办bbaa移动代码的思路
Set "EnityId=!Player_%SelectX%_%SelectY%!"
Set "image=unload AttackSelect"
Set image=buffer AttackSelect||Rem 再建个buf 好处理
Set image=stretch AttackSelect 960 704
Set image=target AttackSelect
Set "EnityId=!Player_%SelectX%_%SelectY%!"
If !MapList_%SelectX%_%SelectY%!==1 (
  Set /a "EnityId_攻击距离=!NamePlayer_%EnityId%_攻击距离!+1"
) else if !MapList_%SelectX%_%SelectY%!==10 (
  Set /a "EnityId_攻击距离=!NamePlayer_%EnityId%_攻击距离!+1"
) else if !MapList_%SelectX%_%SelectY%!==16 (
  Set /a "EnityId_攻击距离=!NamePlayer_%EnityId%_攻击距离!-1"
) else (
  Set "EnityId_攻击距离=!NamePlayer_%EnityId%_攻击距离!"
)
Set "EnityId_X=!SelectX!"
Set "EnityId_X=!SelectY!"
Set /a "EnityId_攻击起始X=!SelectX!-!EnityId_攻击距离!"
Set /a "EnityId_攻击起始Y=!SelectY!-!EnityId_攻击距离!"
Set /a "EnityId_攻击结束X=!SelectX!+!EnityId_攻击距离!"
Set /a "EnityId_攻击结束Y=!SelectY!+!EnityId_攻击距离!"
Set /a "EnityId_伤害=!NamePlayer_%EnityId%_伤害!"
Set /a "可攻击单位数量=0"
for /l %%a in (%EnityId_攻击起始Y%,1,%EnityId_攻击结束Y%) do (
  for /l %%b in (%EnityId_攻击起始X%,1,%EnityId_攻击结束X%) do (
    if defined Player_%%b_%%a (
      Call :Get_Ver TmpEnityId Player_%%b_%%a
      Call :Get_Ver TmpEnityId NamePlayer_!TmpEnityId!_阵营
      if "!TmpEnityId!"=="敌方" (
        Set /a 可攻击单位数量+=1
        Set /a "DrawAttackSelectX=%%b*64"
        Set /a "DrawAttackSelectY=%%a*64"
        Set "image=draw Imgattackrange !DrawAttackSelectX! !DrawAttackSelectY!"
      )
    )
  )
) 2>nul
Set image=target cmd
if !可攻击单位数量!==0 (
  REM 没有可 攻击 单位时做的事
  set "SelectType=select"
  Set "回合=敌方移动"
)
Goto :Eof
Rem 下面是方法区
:LoadPlayer
Rem 加载Player信息
Set 单位数量=0
Set 敌方单位数量=0
Set 我方单位数量=0
Set "玩家文件名=./maps/mapdata/map%map%/Players.csv"
if "!自定关卡!"=="True" (
  Set "玩家文件名=./自定关卡/%自定关卡名%/Players.csv"
)
for /f "eol=# Tokens=1-10 delims=," %%a in (%玩家文件名%) do (
  if %%d gtr 0 (
    Set /a 单位数量+=1
    Set "Player_%%a_%%b=!单位数量!"
    Set "NamePlayer_!单位数量!_X=%%a"
    Set "NamePlayer_!单位数量!_Y=%%b"
    Set "NamePlayer_!单位数量!_名称=%%c"
    Set "NamePlayer_!单位数量!_血量=%%d"
    Set "NamePlayer_!单位数量!_总血量=%%d"
    Set "NamePlayer_!单位数量!_类型=%%e"
    if /i "%%f"=="e" (
      Set "NamePlayer_!单位数量!_阵营=敌方"
      Set /a 敌方单位数量+=1
      Set "敌方单位_!敌方单位数量!=!单位数量!"
    ) else (
      Set "NamePlayer_!单位数量!_阵营=我方"
      Set /a 我方单位数量+=1
      Set "我方单位_!我方单位数量!=!单位数量!"
    )
    Set "NamePlayer_!单位数量!_攻击距离=%%g"
    Set "NamePlayer_!单位数量!_移动距离=%%h"
    Set "NamePlayer_!单位数量!_伤害=%%i"
    Set "NamePlayer_!单位数量!_防御=%%j"
    Set "NamePlayer_!单位数量!_镜像=False"
  )
)
Goto :eof
:LoadImage
Rem 批量加载图片 暴力法
cd image 2>nul
for %%a in (*.bmp) do (
  Set "image=load %%~nxa Img%%~na"
  Call Mirror Img%%~na MirrorImg%%~na
)
Set "image=target cmd"
cd.. 2>nul
Goto :Eof
:LoadMap_New
Rem 加载地图
Set "image=unload Map"
Set "image=buffer Map"||Rem 新建个地图缓冲区-直接存储地图
Set "image=stretch Map 960 704"
Set "image=target Map"
Set MapX=0
Set MapY=0
Set MapSizeX=0
Set MapSizeY=-1
Rem 之前智商欠费
if Not "!自定关卡!"=="True" (
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
  for /f "delims=" %%a in (./自定关卡/%自定关卡名%/Main.map) do (
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
Rem 加载Player叠加层
Set "image=unload Player"
Set "image=buffer Player"
Set "image=stretch Player 960 704"
Set "image=target Player"
Set Player 1>var/Player.env
for /f "delims== Tokens=1-2" %%a in (var/Player.env) do (
  Set /a "ShowPlayer_X=!NamePlayer_%%b_X!*64" 
  Set /a "ShowPlayer_Y=!NamePlayer_%%b_Y!*64"
  Call :加载血量条 %%b
  Set "image=target Player"
  if /i "!NamePlayer_%%b_镜像!"=="True" (
    Set "image=draw MirrorImg!NamePlayer_%%b_类型! !ShowPlayer_X! !ShowPlayer_Y! trans"
  ) else (
    Set "image=draw Img!NamePlayer_%%b_类型! !ShowPlayer_X! !ShowPlayer_Y! trans"
  )
  if "!敌方单位数量!"=="0" (
    Goto :Win
  )
  if "!我方单位数量!"=="0" (
    Goto :Lose
  )
) 2>nul
Set "image=target cmd"
Goto :eof
:Show
Rem Show方法 调用方式 Call :Show Buffer名 [trans] [x] [y]
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
Title 生死时速 draw !BufName! !DrawMainX! !DrawMainY! 回合:!回合! 回合数:!回合数! 渲染次数:!渲染次数!
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
    if /i "!回合!"=="单位移动" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectY+=1"
        )
      )
    ) else (
      if "%回合%"=="单位攻击选定" (
        Call :IsAttackMove
        if "!IsAttackMove!"=="False" (
          Set /a "SelectY+=1"
        )
      )
    )
  )
)
if  !errorlevel!==2 (
Rem 如果是选择单位模式
  Rem Down
  if !SelectY! lss !MapSizeY! (
    Set /a "SelectY+=1"
    Rem 如果是移动模式
    if /i "!回合!"=="单位移动" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectY-=1"
        )
      )
    ) else (
      Rem 如果是攻击模式
      if "%回合%"=="单位攻击选定" (
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
    if /i "!回合!"=="单位移动" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectX+=1"
        )
      )
    ) else (
      if "%回合%"=="单位攻击选定" (
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
    if /i "!回合!"=="单位移动" (
      if "!SelectType!"=="decideselect" (
        Call :IsWalk
        if "!IsWalk!"=="False" (
          Set /a "SelectX-=1"
        )
      )
    ) else (
      if "%回合%"=="单位攻击选定" (
        Call :IsAttackMove
        if "!IsAttackMove!"=="False" (
          Set /a "SelectX-=1"
        )
      )
    )
  )
)
if !errorlevel!==5 (
  Rem 选定
  if /i "!SelectType!"=="Select" (
    if defined Player_%SelectX%_%SelectY% (
      if !NamePlayer_%SPlayer_Id%_阵营!==我方 (
        Set "SelectType=decideselect"
        Goto :Main_MoveSelect
      ) else (
        Set "MoreText=!MoreText!你选中的可能并不是一个我方单位,"
      )
    ) else (
      Set "MoreText=!MoreText!你没有选择单位"
    )
  ) else (
    if "!回合!"=="单位移动" (
      Call :IsWalk
      if "!IsWalk!"=="True" (
        Goto :Main_MoveA
      )
      Set "MoreText=!MoreText!你可能超出了选择的边界,"
    )
  )
  If "%回合%"=="单位攻击选定" (
      if "!NamePlayer_%SPlayer_Id%_阵营!"=="敌方" (
        Set "SelectType=select"
        Set "回合=敌方移动"
        Set /a "EnityId_伤害=!NamePlayer_%EnityId%_伤害!"
        Set /a "EnityId_X=!NamePlayer_%EnityId%_X!"
        if !SelectX! lss !EnityId_X! (
          Set "NamePlayer_%EnityId%_镜像=True"
        ) else (
          Set "NamePlayer_%EnityId%_镜像=False"
        )
        Set "EnityId=!Player_%SelectX%_%SelectY%!"
        Call :Get_Ver 被攻击方防御 NamePlayer_!EnityId!_防御
        Set "被攻击方X=%SelectX%"
        Set "被攻击方Y=%SelectY%"
        Call :Get_Ver 被攻击方脚下方块 MapList_!被攻击方X!_!被攻击方Y!
        if "!被攻击方脚下方块!"=="4" (
          Set /a 被攻击方防御+=1
        ) else if "!被攻击方脚下方块!"=="13" (
          Set /a 被攻击方防御+=1
        ) else if "!被攻击方脚下方块!"=="16" (
          set 是否闪避=!random!%%4
          if !是否闪避!==0 (
            Goto :Main
          )
        ) 
        Set /a "NamePlayer_!EnityId!_血量-=!EnityId_伤害!"
        if !被攻击方防御! leq !EnityId_伤害! (
           Set /a "NamePlayer_!EnityId!_血量+=!被攻击方防御!"
        ) else (
            Set /a "NamePlayer_!EnityId!_血量+=!被攻击方防御!"
        )
        Call :玩家死亡判断 !EnityId!
        if Not "!凉了吗!"=="凉了" (
          Call :血量条重算 !EnityId!
          Set "被攻击的敌方单位EnityId=!EnityId!"
        )
      ) else (
        if "!NamePlayer_%EnityId%_X!"=="!SelectX!" if "!NamePlayer_%EnityId%_Y!"=="!SelectY!" (
          Set "SelectType=select"
          Set "回合=敌方移动"
          Goto :Main
        )
        Set "MoreText=!MoreText!你选中的可能并不是一个敌方单位,"
        Goto Main
      )
    )
  )
Goto :Main
:IsWalk
Set "IsWalk=True"
if !SelectX! lss !EnityId_移动起始X! (
  Set "IsWalk=False"
)
if !SelectX! gtr !EnityId_移动结束X! (
  Set "IsWalk=False"
)
if !SelectY! lss !EnityId_移动起始Y! (
  Set "IsWalk=False"
)
if !SelectY! gtr !EnityId_移动结束Y! (
  Set "IsWalk=False"
)
for %%a in (%无法通行的方块ID%) do (
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
if !SelectX! lss !EnityId_攻击起始X! (
  Set "IsAttackMove=False"
)
if !SelectX! gtr !EnityId_攻击结束X! (
  Set "IsAttackMove=False"
)
if !SelectY! lss !EnityId_攻击起始Y! (
  Set "IsAttackMove=False"
)
if !SelectY! gtr !EnityId_攻击结束Y! (
  Set "IsAttackMove=False"
)
Goto :Eof
:Get_Ver
Set "%~1=!%~2!"
Goto :Eof
:玩家死亡判断
REM Call :玩家死亡判断 <玩家ID> <血量> 
Set "凉了吗=没凉"
Set "EId=%~1"
if not "%~2"=="" (
  Set "Math_单位现血量=%~2"
) else (
  Set "Math_单位现血量=!NamePlayer_%EId%_血量!"
)
if !Math_单位现血量! leq 0 (
  REM 这个单位已经凉了
  Set "凉了的Player_X=!NamePlayer_%EId%_X!"
  Set "凉了的Player_Y=!NamePlayer_%EId%_Y!"
  Set "凉了的Player_类型=!NamePlayer_%EId%_类型!"
  Set "Player_!凉了的Player_X!_!凉了的Player_Y!="
  Set Tmp_单位数量=0
  if "!NamePlayer_%EId%_阵营!"=="敌方" (
    Set 敌方单位_ 1>var/敌方单位_.env
    for /f "Tokens=1-2 delims==" %%y in (var/敌方单位_.env) do (
      if not "%%z"=="!EId!" (
        Set /a Tmp_单位数量+=1
        Set "敌方单位_!Tmp_单位数量!=%%z"
      )
    )
    Set "敌方单位_!敌方单位数量!="
    Set /a "敌方单位数量=!Tmp_单位数量!"
  ) else (
    Set 我方单位_ 1>var/我方单位_.env
    for /f "Tokens=1-2 delims==" %%y in (var/我方单位_.env) do (
      if not "%%z"=="!EId!" (
        Set /a Tmp_单位数量+=1
        Set "我方单位_!Tmp_单位数量!=%%z"
      )
    )
    Set "我方单位_!我方单位数量!="
    Set /a "我方单位数量=!Tmp_单位数量!"
  )
  Set NamePlayer_%EId%_ 1>var/NamePlayer_%EId%_.env
  for /f "Tokens=1 delims==" %%z in (var/NamePlayer_%EId%_.env) do (
    Set "%%~z="
  )
  Set /a "清除玩家X=(!凉了的Player_X!)*64"
  Set /a "清除玩家Y=!凉了的Player_Y!*64"
  Set "image=target Player"
  Set "image=draw Space !清除玩家X! !清除玩家Y! "
  if "!凉了的Player_类型:~2,2!"=="sb" (
    Set /a 清除玩家Y=!清除玩家Y!-7
  ) else if /i "!凉了的Player_类型!"=="Zombie" (
    Set /a 清除玩家Y=!清除玩家Y!-3
  ) else (
    Set /a 清除玩家Y=!清除玩家Y!
  )
  Set /a 清除玩家X+=6
  Set "image=target BufHealth"
  Set "image=draw SpaceHealth !清除玩家X! !清除玩家Y!"
  Set "image=target Player"
  Set /a 单位数量-=1
  Set "凉了吗=凉了"
  if "!敌方单位数量!"=="0" (
    Goto :Win
  )
  if "!我方单位数量!"=="0" (
    Goto :Lose
  )
)
Goto :Eof
:加载血量条
Rem 初始化用函数
Set EId=%~1
Set "Math_单位类型=!NamePlayer_%EId%_类型!"
Set "Math_单位总血量=!NamePlayer_%EId%_总血量!"
Set "Math_单位现血量=!NamePlayer_%EId%_血量!"
Set "Math=round(!Math_单位现血量!/!Math_单位总血量!*49)"
calc %Math%>var\Hp.calcresult
Set /p "Math="<var\Hp.calcresult
if /i "!Math!"=="NAN" (
  Set "Math=49"
)
if "!Math_单位类型:~2,2!"=="sb" (
  Set /a Show血量Y=!ShowPlayer_Y!-7
) else if /i "!Math_单位类型!"=="Zombie" (
  Set /a Show血量Y=!ShowPlayer_Y!-3
) else (
  Set /a Show血量Y=!ShowPlayer_Y!
)
Set /a Show血量X=!ShowPlayer_X!+6
Set "image=unload Health"
Set "image=buffer Health"
Set "image=stretch Health !Math! 4"
Set "image=target Health"
Set "image=draw ImgHp 0 0"
Set "image=target BufHealth"
Set "image=draw ImgHPlabel !Show血量X! !Show血量Y! trans"
Set /a Show血量X+=1
Set /a Show血量Y+=1
Set "image=draw Health !Show血量X! !Show血量Y!"
Set EId=
Goto :Eof
:初始化血量条图层
Set "image=buffer BufHealth"
Set "image=stretch BufHealth 960 704"
Set "image=buffer SpaceHealth"
Set "image=stretch SpaceHealth 51 6"
Goto :Eof
:移动血量条
Title 移动血量条
REM Call :ThisFunction <x1> <y1> <x2> <y2> <Type>
Set "Type=%5"
if "!Type:~2,2!"=="sb" (
  Set /a "原X=%1*64+6"
  Set /a "原Y=(%2*64)-7"
  Set /a "现X=%3*64+6"
  Set /a "现Y=%4*64-7"
) else if /i "%5"=="Zombie" (
  Set /a "原X=%1*64+6"
  Set /a "原Y=(%2*64)-3"
  Set /a "现X=%3*64+6"
  Set /a "现Y=%4*64-3"
) else (
  Set /a "原X=%1*64+6"
  Set /a "原Y=(%2*64)"
  Set /a "现X=%3*64+6"
  Set /a "现Y=%4*64"
)
Set /a 原X*=-1
Set /a 原Y*=-1
Set "image=buffer TmpHealth"
Set "image=stretch TmpHealth 51 6"
set "image=target TmpHealth"
set "image=draw BufHealth !原X! !原Y!"
Set /a 原X*=-1
Set /a 原Y*=-1
set "image=target BufHealth"
set "image=draw SpaceHealth !原X! !原Y!"
set "image=draw TmpHealth !现X! !现Y!"
Goto :Eof
:血量条重算
Title 血量条重算 Eid:%~1
Rem Call :ThisFunction <EnityId>
Set EId=%~1
Set /a "血量条X=(!NamePlayer_%EId%_X!)*64+6"
if "!NamePlayer_%EId%_类型:~2,2!"=="sb" (
  Set /a "血量条Y=!NamePlayer_%EId%_Y!*64-7"
) else if /i "!NamePlayer_%EId%_类型!"=="Zombie" (
  Set /a "血量条Y=!NamePlayer_%EId%_Y!*64-3"
) else (
  Set /a "血量条Y=!NamePlayer_%EId%_Y!*64"
)
set "image=target BufHealth"
set "image=draw SpaceHealth !血量条X! !血量条Y!"
Set "Math=round(!NamePlayer_%EId%_血量!/!NamePlayer_%EId%_总血量!*49)"
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
Set "image=draw ImgHPlabel !血量条X! !血量条Y! trans"
Set /a 血量条X+=1
Set /a 血量条Y+=1
Set "image=draw Health !血量条X! !血量条Y!"
Goto :Eof
:单位移动
Rem Call :ThisFunction <x1> <y1> <x2> <y2>
Set /a "原X=(%1)*-64"
Set /a "原Y=%2*-64"
Set /a "现X=(%3)*64"
Set /a "现Y=%4*64"
Set "image=buffer TmpPlayer"
Set "image=stretch TmpPlayer 64 64"
set "image=target TmpPlayer"
set "image=draw Player !原X! !原Y!"
set "image=target Player"
Set /a 原X*=-1
Set /a 原Y*=-1
set "image=draw Space !原X! !原Y!"
set "image=draw TmpPlayer !现X! !现Y!"
Goto :Eof
:寻找选择最有价值的敌方单位
Set /a 历史价值 = -10000
for /l %%i in (1,1,%敌方单位数量%) do (
  for /l %%j in (1,1,%我方单位数量%) do (
    call call Set "距离公式=sqrt((%%%%NamePlayer_%%敌方单位_%%i%%_X%%%%-%%%%NamePlayer_%%我方单位_%%j%%_X%%%%)*(%%%%NamePlayer_%%敌方单位_%%i%%_X%%%% - %%%%NamePlayer_%%我方单位_%%j%%_X%%%%)+(%%%%NamePlayer_%%敌方单位_%%i%%_Y%%%% - %%%%NamePlayer_%%我方单位_%%j%%_Y%%%%)*(%%%%NamePlayer_%%敌方单位_%%i%%_Y%%%% - %%%%NamePlayer_%%我方单位_%%j%%_Y%%%%))"
    calc "!距离公式!" 1>var/距离.calcresult
    Set /p 距离=<var/距离.calcresult
    call call set "价值公式=floor((1/!距离! + 1/(%%%%NamePlayer_%%我方单位_%%j%%_血量%%%% / (%%%%NamePlayer_%%敌方单位_%%j%%_伤害%%%% - %%%%NamePlayer_%%我方单位_%%j%%_防御%%%%)))*10000)" 
    calc "!价值公式!" 1>var/价值.calcresult
    Set /a 价值=<var/价值.calcresult
    if !价值! gtr !历史价值! (
      set /a 敌方EnityId=!敌方单位_%%i!
      set 历史价值=!价值!
    )
  )
)
Goto :Eof
:敌方移动
If Not Defined 敌方EnityId (
  if Defined 被攻击的敌方单位EnityId (
    if defined NamePlayer_!被攻击的敌方单位EnityId!_血量 (
      if !NamePlayer_%被攻击的敌方单位EnityId%_血量! gtr 0 (
        ::追击设定
        Set /a "敌方EnityId=!被攻击的敌方单位EnityId!"
        Set "被攻击的敌方单位EnityId="
      ) else (
        Call :寻找选择最有价值的敌方单位
      )
    ) else (
      Call :寻找选择最有价值的敌方单位
    )
  ) else (
    Call :寻找选择最有价值的敌方单位
  )
  Set "敌方选择完毕=t"
)
if "!敌方选择完毕!"=="t" (
  Set "敌方单位X=!NamePlayer_%敌方EnityId%_X!"
  Set "敌方单位Y=!NamePlayer_%敌方EnityId%_Y!"
  Set "敌方EnityId_移动距离=!NamePlayer_%敌方EnityId%_移动距离!"
  Set /a "敌方EnityId_移动起始X=!敌方单位X!-!敌方EnityId_移动距离!"
  Set /a "敌方EnityId_移动起始Y=!敌方单位Y!-!敌方EnityId_移动距离!"
  Set /a "敌方EnityId_移动结束X=!敌方单位X!+!敌方EnityId_移动距离!"
  Set /a "敌方EnityId_移动结束Y=!敌方单位Y!+!敌方EnityId_移动距离!"
  Set TempXY=
  Set TempX=
  Set TempY=
  Set 离得最近的XY积=100000
  Set 离得最近的单位Id=
  Set 是否替换=
  Set /a "溜走血量=!NamePlayer_%敌方EnityId%_总血量!/3+1"
  Set "追踪阵营=我方"
  if !NamePlayer_%敌方EnityId%_血量! leq !溜走血量! (
    if !敌方单位数量! geq 2 (
      Set "追踪阵营=敌方"
    )
  )
  if !PostiveAI!=="Enable" (
    Set "追踪阵营=我方"
  )
  Set !追踪阵营!单位_ 1>var/!追踪阵营!单位_.env
  for /f "Tokens=1-2 delims==" %%i in (var/!追踪阵营!单位_.env) do (
    if not %%j==!敌方EnityId! (
      Set /a "TempX=!NamePlayer_%%j_X!-!敌方单位X!"
      Set /a "TempY=!NamePlayer_%%j_Y!-!敌方单位Y!"
      Set /a "TempXY=!TempX!*!TempX!+!TempY!*!TempY!"
      if !TempXY! lss !离得最近的XY积! (
        Set 离得最近的XY积=!TempXY!
        Set 离得最近的单位Id=%%j
        Set 最近单位X=!NamePlayer_%%j_X!
        Set 最近单位Y=!NamePlayer_%%j_Y!
      ) else if !TempXY!==!离得最近的XY积! (
        Set /a "是否替换=!random! %% 2"
        if !是否替换!==1 (
          Set 离得最近的XY积=!TempXY!
          Set 离得最近的单位Id=%%j
          Set 最近单位X=!NamePlayer_%%j_X!
          Set 最近单位Y=!NamePlayer_%%j_Y!
        )
      )
    )
  )
  Set TempXY=
  Set TempX=
  Set TempY=
  Set 移动过程中最小的XY积=100000
  Set 移动过程中最大的XY积=0
  Set "敌方移动步数=0"
  Set 敌方移动步数最小位置=
  Set 敌方移动步数最大位置=
  Set 敌方移动逆向列表=
)
if defined 敌方EnityId (
  Set "敌方选择完毕=f"
  Call :敌方移动_处理
)
Goto :Main
:敌方移动_处理
if Not "!SelectX!"=="!敌方单位X!" (
  if !SelectX! gtr !敌方单位X! (
    Set /a "SelectX-=1"
  ) else (
    Set /a "SelectX+=1"
  )
) else (
  if Not "!SelectY!"=="!敌方单位Y!" (
    if !SelectY! gtr !敌方单位Y! (
      Set /a "SelectY-=1"
    ) else (
      Set /a "SelectY+=1"
    )
  )
)
if "!SelectX!"=="!敌方单位X!" (
  if "!SelectY!"=="!敌方单位Y!" (
    Set "SelectType=decideselect"
    Set 回合=敌方移动开始_DFS
    Call :敌方移动区域渲染
  )
)
Goto :Eof
:敌方移动区域渲染
Set "image=unload MoveSelect"
Set image=buffer MoveSelect||Rem 再建个buf 好处理
Set image=stretch MoveSelect 960 704
Set image=target MoveSelect
for /l %%a in (%敌方EnityId_移动起始Y%,1,%敌方EnityId_移动结束Y%) do (
  for /l %%b in (%敌方EnityId_移动起始X%,1,%敌方EnityId_移动结束X%) do (
    Set "IsWalk=True"
    for %%c in (%无法通行的方块ID%) do (
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
:敌方移动开始_DFS
Set DFS 1>var/DFS.env
for /f "tokens=1 delims==" %%i in (var/DFS.env) do (
  Set "%%~i="
)
Set "DFSMoveX=+0+0-1+1" || REM 上0下1左2右3
Set "DFSMoveY=-1+1+0+0"
Set /a XDis=!最近单位X!-!敌方单位X!
Set /a YDis=!最近单位Y!-!敌方单位Y!
if !XDis! gtr 0 (
  ::目标在右侧
  if !YDis! gtr 0 (
    ::目标在下方
    if !YDis! gtr !XDis! (
      Set DFS_MoveRule=1302 || Rem 下右上左
    ) else (
      Set DFS_MoveRule=3120 || Rem 右下左上
    )
  ) else (
    ::目标在下方
    if -!YDis! gtr !XDis! (
      Set DFS_MoveRule=0312 || Rem 上右下左
    ) else (
      Set DFS_MoveRule=3021 || Rem 右上左下
    )
  )
) else (
  ::目标在左侧
  if !YDis! gtr 0 (
    ::目标在下方
    if !YDis! gtr -!XDis! (
      Set DFS_MoveRule=1203 || Rem 下左上右
    ) else (
      Set DFS_MoveRule=2130 || Rem 左下右上
    )
  ) else (
    ::目标在上方
    if -!YDis! gtr -!XDis! (
      Set DFS_MoveRule=0213 || Rem 上左下右
    ) else (
      Set DFS_MoveRule=2031 || Rem 左上右下
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
Set 回合=DFS_Main
:DFS_Main
if !DFS_X!==!最近单位X! (
  if !DFS_Y!==!最近单位Y! (
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
        for %%a in (%无法通行的方块ID%) do (
          if "!MapList_%Next_DFS_X%_%Next_DFS_Y%!"=="%%a" (
            Set "IsWalk=False"
          )
        )
        if defined Player_!Next_DFS_X!_!Next_DFS_Y! (
            Set "IsWalk=False"
        )
        if "!Next_DFS_X!"=="!NamePlayer_%敌方EnityId%_X!" (
          if "!Next_DFS_Y!"=="!NamePlayer_%敌方EnityId%_Y!" (
            Set "IsWalk=True"
          )
        )
        if "!Next_DFS_X!"=="!NamePlayer_%离得最近的单位Id%_X!" (
          if "!Next_DFS_Y!"=="!NamePlayer_%离得最近的单位Id%_Y!" (
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
REM 回溯状态
if !DFS_HistoryLength! equ 0 (
  Set "回合=敌方移动选定"
  Set SelectX=!NamePlayer_%敌方EnityId%_X!
  Set SelectY=!NamePlayer_%敌方EnityId%_Y!
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
set "回合=敌方移动AI处理"
Set /a DFS_MoveStep=0
goto :Main
:敌方移动AI处理
if !DFS_HistoryLength!==!DFS_MoveStep! (
  Set "回合=敌方移动选定"
  Goto :Main
)
Set /a DFS_MoveTempX=!DFS_HistoryX:~0,2!
Set /a DFS_MoveTempY=!DFS_HistoryY:~0,2!
if !DFS_MoveTempX! lss !敌方EnityId_移动起始X! (
  Set "回合=敌方移动选定"
  Goto :Main
)
if !DFS_MoveTempX! gtr !敌方EnityId_移动结束X! (
  Set "回合=敌方移动选定"
  Goto :Main
)
if !DFS_MoveTempY! lss !敌方EnityId_移动起始Y! (
  Set "回合=敌方移动选定"
  Goto :Main
)
if !DFS_MoveTempY! gtr !敌方EnityId_移动结束Y! (
  Set "回合=敌方移动选定"
  Goto :Main
)
Set /a SelectX=!DFS_MoveTempX!
Set /a SelectY=!DFS_MoveTempY!
Set "DFS_HistoryX=!DFS_HistoryX:~2!"
Set "DFS_HistoryY=!DFS_HistoryY:~2!"
Set /a DFS_MoveStep+=1
Goto :Main
:敌方移动选定
Set "SelectType=select"
Call :单位移动 !NamePlayer_%敌方EnityId%_X! !NamePlayer_%敌方EnityId%_Y! !SelectX! !SelectY!
Call :移动血量条 !NamePlayer_%敌方EnityId%_X! !NamePlayer_%敌方EnityId%_Y! !SelectX! !SelectY! !NamePlayer_%敌方EnityId%_类型!
Set "Player_!NamePlayer_%敌方EnityId%_X!_!NamePlayer_%敌方EnityId%_Y!="
Set "NamePlayer_!敌方EnityId!_X=!SelectX!"
Set "NamePlayer_!敌方EnityId!_Y=!SelectY!"
Set "Player_!SelectX!_!SelectY!=!敌方EnityId!"
Set "回合=敌方攻击选择"
Goto :Main
:敌方攻击选择
Set "image=unload AttackSelect"
Set image=buffer AttackSelect||Rem 再建个buf 好处理
Set image=stretch AttackSelect 960 704
Set image=target AttackSelect
Set "SelectType=decideselect"
Set "敌方EnityId=!Player_%SelectX%_%SelectY%!"
If !MapList_%SelectX%_%SelectY%!==1 (
  Set /a "敌方EnityId_攻击距离=!NamePlayer_%敌方EnityId%_攻击距离!+1"
) else if "!MapList_%SelectX%_%SelectY%!"=="10" (
  Set /a "敌方EnityId_攻击距离=!NamePlayer_%敌方EnityId%_攻击距离!+1"
) else if !MapList_%SelectX%_%SelectY%!==10 (
  Set /a "敌方EnityId_攻击距离=!NamePlayer_%敌方EnityId%_攻击距离!+1"
) else (
  Set "敌方EnityId_攻击距离=!NamePlayer_%敌方EnityId%_攻击距离!"
)
Set /a "敌方EnityId_攻击起始X=!SelectX!-!敌方EnityId_攻击距离!"
Set /a "敌方EnityId_攻击起始Y=!SelectY!-!敌方EnityId_攻击距离!"
Set /a "敌方EnityId_攻击结束X=!SelectX!+!敌方EnityId_攻击距离!"
Set /a "敌方EnityId_攻击结束Y=!SelectY!+!敌方EnityId_攻击距离!"
Set /a "敌方EnityId_伤害=!NamePlayer_%敌方EnityId%_伤害!"
Set /a "可攻击单位数量=0"
for /l %%a in (%敌方EnityId_攻击起始Y%,1,%敌方EnityId_攻击结束Y%) do (
  for /l %%b in (%敌方EnityId_攻击起始X%,1,%敌方EnityId_攻击结束X%) do (
    if defined Player_%%b_%%a (
      Call :Get_Ver Tmp敌方EnityId Player_%%b_%%a
      Call :Get_Ver Tmp敌方EnityId NamePlayer_!Tmp敌方EnityId!_阵营
      if "!Tmp敌方EnityId!"=="我方" (
        Set /a 可攻击单位数量+=1
        Set "敌方可攻击单位_!可攻击单位数量!=!Player_%%b_%%a!"
        Set /a "DrawAttackSelectX=%%b*64"
        Set /a "DrawAttackSelectY=%%a*64"
        Set "image=draw Imgattackrange !DrawAttackSelectX! !DrawAttackSelectY!"
      )
    )
  )
) 2>nul
Set image=target cmd
if !可攻击单位数量!==0 (
  REM 没有可 攻击 单位时做的事
  set "SelectType=select"
  Set "回合=单位移动"
  Set /a 回合数+=1
  Call :回合结束处理
  Set "敌方EnityId="
) else (
  Set "回合=敌方攻击_选择动画"
  Set /a "被攻击单位EnityId=!Random! %% !可攻击单位数量! + 1"
  Call :Get_Ver 被攻击单位EnityId 敌方可攻击单位_!被攻击单位EnityId!
)
Goto :Main
:敌方攻击_选择动画
Set 被攻击单位X=!NamePlayer_%被攻击单位EnityId%_X!
Set 被攻击单位Y=!NamePlayer_%被攻击单位EnityId%_Y!
if Not "!SelectX!"=="!被攻击单位X!" (
  if !SelectX! gtr !被攻击单位X! (
    Set /a "SelectX-=1"
  ) else (
    Set /a "SelectX+=1"
  )
) else (
  if Not "!SelectY!"=="!被攻击单位Y!" (
    if !SelectY! gtr !被攻击单位Y! (
      Set /a "SelectY-=1"
    ) else (
      Set /a "SelectY+=1"
    )
  )
)
if "!SelectX!"=="!被攻击单位X!" (
  if "!SelectY!"=="!被攻击单位Y!" (
    Set "回合=敌方攻击_造成伤害"
  )
)
Goto :Main
:敌方攻击_造成伤害
Set "EnityId=!Player_%SelectX%_%SelectY%!"
if "!MapList_%被攻击单位X%_%被攻击单位Y%!"=="4" (
  Set /a 被攻击方防御=!NamePlayer_%被攻击单位EnityId%_防御!+1
) else if "!MapList_%被攻击单位X%_%被攻击单位Y%!"=="13" (
  Set /a 被攻击方防御=!NamePlayer_%被攻击单位EnityId%_防御!+1
) else if "!MapList_%被攻击单位X%_%被攻击单位Y%!"=="16" (
  set 是否闪避=!random!%%4
  if !是否闪避!==0 (
    set "SelectType=select"
    Set "回合=单位移动"
    Set /a 回合数+=1
    Call :回合结束处理
    Set "敌方EnityId="
    Goto :Main
  )
) else (
  Set /a 被攻击方防御=!NamePlayer_%被攻击单位EnityId%_防御!
)
Set EnityId_伤害=!NamePlayer_%敌方EnityId%_伤害!
Set /a "NamePlayer_!被攻击单位EnityId!_血量-=!EnityId_伤害!"
if !被攻击方防御! leq !EnityId_伤害! (
  Set /a "NamePlayer_!被攻击单位EnityId!_血量+=!被攻击方防御!"
) else (
  Set /a "NamePlayer_!被攻击单位EnityId!_血量+=!被攻击方防御!"
)
Call :玩家死亡判断 !被攻击单位EnityId!
if Not "!凉了吗!"=="凉了" (
  Call :血量条重算 !被攻击单位EnityId!
)
set "SelectType=select"
Set "回合=单位移动"
Set /a 回合数+=1
Call :回合结束处理
Set "敌方EnityId="
Goto :Main
:Win
set image=target cmd
set image=cls
cls
if Not "!自定关卡!"=="True" (
  if not %map%==5 (
    Echo 你赢了，任意键进入下一关
    echo 回合数:!回合数!
    Set /a map+=1
    >level.txt echo !map!
    pause>nul
    Endlocal
    Goto :Loadlevel
  ) else (
    Set /a map+=1
    >level.txt echo !map!
    Echo 你赢了，你已经通关了本游戏，请期待本游戏更新，感谢！
    pause>nul
  )
) else (
  Echo 恭喜，你赢了%自定关卡名%这个自定关卡！
  pause>nul
)
exit
:Lose
set image=target cmd
set image=cls
Endlocal
cls
if Not "!自定关卡!"=="True" (
  echo 你输了，任意键重玩
  pause>nul
) else (
  echo 你输了这个自定关卡，任意键重玩
  pause>nul
)
Goto :Loadlevel
exit
:Help
Set image=draw cover 0 0
echo 世界观:
echo 21世纪50年代，世界经济高速发展，全球一体化稳步推进
echo 在这样的环境下，逆时代的破坏和平的事件仍时有发生
echo 你作为A国维和部队指挥官，负有有维护国家安全的责任，A国和平，全靠你的英勇与智慧！
echo.
echo 操作方法:
echo W A S D 控制选择光标
echo J键确认选择
echo.
echo 游戏目标
echo 歼灭敌人，每个关卡会有不同具体要求
echo.
echo 制作名单:
echo 程序:bbaa TJUGERKFER
echo 美工:TJUGERKFER
echo 剧情:TJUGERKFER
echo 地图制作:TJUGERKFER bbaa
echo Debug:bbaa TJUGERKFER
echo 发布:bbaa
echo.
echo 按任意键返回！
Pause>nul
Goto Draw_Menu
:回合结束处理
Set Player_ 1>var/Player_.env
for /f "Tokens=2 delims==" %%i in (var/Player_.env) do (
  if !NamePlayer_%%i_血量! gtr 0 (
      Call :Get_Ver 方块Id MapList_!NamePlayer_%%i_X!_!NamePlayer_%%i_Y!
      if "!方块Id!"=="11" (
        if !NamePlayer_%%i_血量! lss !NamePlayer_%%i_总血量! (
         Set /a NamePlayer_%%i_血量+=1
        )
      )
      if "!方块Id!"=="15" (
        Set /a NamePlayer_%%i_血量-=1
        Call :玩家死亡判断 %%i
      )
      Call :血量条重算 %%i
  ) else (
    Call :玩家死亡判断 %%i
    Call :血量条重算 %%i
  )
)
Goto :Eof
:drawMain
Call :Show Main 0 64||Rem 加载主渲染层
Goto :EOF